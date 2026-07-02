-- ============================================================
-- 完整下单事务示例
-- 流程：库存校验 → 库存锁定 → 优惠券校验与锁定 → 积分抵扣
--       → 创建订单与明细 → 支付记录 → 扣减积分
-- ============================================================

USE SpicyBraiseDB;
GO

-- ============================================================
-- 完整下单存储过程（事务+行锁+乐观锁）
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_PlaceOrder
    @user_id            BIGINT,
    @items_json         NVARCHAR(MAX),       -- JSON: [{"product_id":1,"quantity":2},...]
    @coupon_id          BIGINT = NULL,       -- 用户优惠券 id
    @use_points         INT    = 0,           -- 要抵扣的积分数
    @remark             NVARCHAR(512) = NULL,
    -- 输出
    @new_order_id       BIGINT OUTPUT,
    @new_order_no       NVARCHAR(32) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now           DATETIME2(0) = SYSUTCDATETIME();
    DECLARE @total_amount  DECIMAL(10,2) = 0;
    DECLARE @discount_amt  DECIMAL(10,2) = 0;
    DECLARE @points_amt    DECIMAL(10,2) = 0;
    DECLARE @actual_amt    DECIMAL(10,2) = 0;
    DECLARE @order_no      NVARCHAR(32);

    -- 解析 items JSON 到临时表
    DECLARE @items TABLE (product_id BIGINT, quantity INT, rowversion ROWVERSION);

    INSERT INTO @items (product_id, quantity)
    SELECT product_id, quantity
    FROM OPENJSON(@items_json)
    WITH (product_id BIGINT '$.product_id', quantity INT '$.quantity');

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ============================================================
        -- ① 库存校验 + 锁定 + 计算总额
        -- ============================================================
        DECLARE @pid BIGINT, @qty INT, @price DECIMAL(10,2), @cur_stock INT, @rv ROWVERSION;

        DECLARE item_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT product_id, quantity FROM @items;

        OPEN item_cursor;
        FETCH NEXT FROM item_cursor INTO @pid, @qty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- 行级锁定 (ROWLOCK + UPDLOCK) 防止并发超卖
            SELECT @price = price, @cur_stock = stock, @rv = rowversion
            FROM dbo.products WITH (ROWLOCK, UPDLOCK)
            WHERE id = @pid AND is_deleted = 0 AND is_available = 1;

            IF @@ROWCOUNT = 0
            BEGIN
                ;THROW 50001, CONCAT(N'商品 ID=', @pid, N' 不存在或已下架'), 1;
            END;

            IF @cur_stock < @qty
            BEGIN
                ;THROW 50002, CONCAT(N'商品 [', @pid, N'] 库存不足：剩余 ', @cur_stock, N'，需要 ', @qty), 1;
            END;

            -- 扣减库存
            UPDATE dbo.products
            SET stock = stock - @qty, updated_at = @now
            WHERE id = @pid AND stock >= @qty;

            IF @@ROWCOUNT = 0
            BEGIN
                ;THROW 50003, CONCAT(N'商品 [', @pid, N'] 库存扣减失败'), 1;
            END;

            -- 累加总金额
            SET @total_amount += @price * @qty;

            FETCH NEXT FROM item_cursor INTO @pid, @qty;
        END;

        CLOSE item_cursor;
        DEALLOCATE item_cursor;

        -- ============================================================
        -- ② 优惠券校验与锁定
        -- ============================================================
        IF @coupon_id IS NOT NULL
        BEGIN
            DECLARE @ct_type NVARCHAR(16), @ct_discount DECIMAL(3,2),
                    @ct_reduction DECIMAL(10,2), @ct_min_order DECIMAL(10,2),
                    @valid_from DT2 = NULL, @valid_to DT2 = NULL, @coupon_status NVARCHAR(16);

            SELECT @ct_type = ct.type,
                   @ct_discount = ct.discount_rate,
                   @ct_reduction = ct.reduction_amount,
                   @ct_min_order = ct.min_order_amount,
                   @valid_from = uc.valid_from,
                   @valid_to = uc.valid_to,
                   @coupon_status = uc.status
            FROM dbo.user_coupon uc WITH (ROWLOCK, UPDLOCK)
            JOIN dbo.coupon_template ct ON uc.coupon_template_id = ct.id
            WHERE uc.id = @coupon_id AND uc.user_id = @user_id;

            IF @@ROWCOUNT = 0
                ;THROW 50010, N'优惠券不存在或不属于当前用户', 1;

            IF @coupon_status <> 'unused'
                ;THROW 50011, N'优惠券不可用（已使用或已过期）', 1;

            IF @now < @valid_from OR @now > @valid_to
                ;THROW 50012, N'优惠券不在有效期内', 1;

            IF @total_amount < @ct_min_order
                ;THROW 50013, CONCAT(N'未达到最低消费金额 ', @ct_min_order, N' 元'), 1;

            -- 计算折扣金额
            IF @ct_type = 'discount'
                SET @discount_amt = @total_amount * (1 - @ct_discount);
            ELSE IF @ct_type = 'reduction'
                SET @discount_amt = @ct_reduction;

            -- 锁定优惠券（标记为已使用）
            UPDATE dbo.user_coupon
            SET status = 'used', used_at = @now
            WHERE id = @coupon_id AND status = 'unused';

            IF @@ROWCOUNT = 0
                ;THROW 50014, N'优惠券锁定失败', 1;
        END;

        -- ============================================================
        -- ③ 积分抵扣
        -- ============================================================
        DECLARE @user_balance_pts INT;
        SELECT @user_balance_pts = points FROM dbo.users WITH (ROWLOCK, UPDLOCK)
        WHERE id = @user_id;

        IF @use_points > 0
        BEGIN
            IF @use_points > @user_balance_pts
                ;THROW 50020, CONCAT(N'积分不足：可用 ', @user_balance_pts, N' 分'), 1;

            -- 积分抵扣汇率：100 积分 = 1 元
            SET @points_amt = CAST(@use_points AS DECIMAL(10,2)) / 100.00;

            -- 积分抵扣不能超过订单金额
            IF @points_amt > (@total_amount - @discount_amt)
                SET @points_amt = @total_amount - @discount_amt;

            -- 扣减用户积分
            UPDATE dbo.users SET points = points - @use_points WHERE id = @user_id;

            -- 记录积分消费
            INSERT INTO dbo.points_record (user_id, points, type, description)
            VALUES (@user_id, -@use_points, 'spend',
                    CONCAT(N'下单抵扣：', @use_points, N'分 = ', @points_amt, N'元'));
        END;

        -- ============================================================
        -- ④ 计算实付金额 & 生成订单号
        -- ============================================================
        SET @actual_amt = @total_amount - @discount_amt - @points_amt;
        IF @actual_amt < 0 SET @actual_amt = 0;

        SET @order_no = CONCAT(
            FORMAT(@now, 'yyyyMMddHHmmss'),
            RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS NVARCHAR(6)), 6)
        );

        -- ============================================================
        -- ⑤ 创建订单
        -- ============================================================
        INSERT INTO dbo.orders (
            user_id, order_no, total_amount, discount_amount,
            points_deducted, points_amount, actual_amount, status, remark
        )
        VALUES (
            @user_id, @order_no, @total_amount, @discount_amt,
            @use_points, @points_amt, @actual_amt, 'pending', @remark
        );

        SET @new_order_id = SCOPE_IDENTITY();
        SET @new_order_no = @order_no;

        -- ============================================================
        -- ⑥ 创建订单明细
        -- ============================================================
        INSERT INTO dbo.order_details (order_id, product_id, quantity, unit_price, subtotal)
        SELECT @new_order_id, i.product_id, i.quantity, p.price, p.price * i.quantity
        FROM @items i
        JOIN dbo.products p ON i.product_id = p.id;

        -- ============================================================
        -- ⑦ 创建支付记录（pending 状态）
        -- ============================================================
        DECLARE @pay_method NVARCHAR(16) = CASE
            WHEN @actual_amt = 0 THEN 'points' ELSE 'wechat' END;

        INSERT INTO dbo.payments (order_id, user_id, amount, payment_method, payment_status)
        VALUES (@new_order_id, @user_id, @actual_amt, @pay_method, 'pending');

        -- ============================================================
        -- ⑧ 更新优惠券关联订单号
        -- ============================================================
        IF @coupon_id IS NOT NULL
            UPDATE dbo.user_coupon SET used_order_id = @new_order_id WHERE id = @coupon_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- ============================================================
-- 调用示例（文档用途，不在此文件执行）
-- ============================================================

/*
-- 场景：用户 customer01 (id=4) 下单 2 份招牌辣鸭脖 + 1 份卤藕片，
--       使用优惠券 id=2（满50减10）+ 抵扣 500 积分

DECLARE @oid BIGINT, @ono NVARCHAR(32);

EXEC dbo.usp_PlaceOrder
    @user_id       = 4,
    @items_json    = N'[{"product_id":1,"quantity":2},{"product_id":4,"quantity":1}]',
    @coupon_id     = 2,       -- 满50减10
    @use_points    = 500,      -- 抵扣 5 元
    @remark        = N'加辣，多放芝麻',
    @new_order_id  = @oid OUTPUT,
    @new_order_no  = @ono OUTPUT;

SELECT @oid AS order_id, @ono AS order_no;

-- 验证结果
SELECT * FROM dbo.orders WHERE id = @oid;
SELECT * FROM dbo.order_details WHERE order_id = @oid;
SELECT * FROM dbo.payments WHERE order_id = @oid;
SELECT points FROM dbo.users WHERE id = 4;          -- 应减少 500
SELECT stock FROM dbo.products WHERE id IN (1,4);   -- 库存应减少
SELECT * FROM dbo.user_coupon WHERE id = 2;          -- 状态应为 'used'
*/
