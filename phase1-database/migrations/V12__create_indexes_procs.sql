-- ============================================================
-- V12: 补充索引 & 性能优化 & 事务示例
-- ============================================================

USE SpicyBraiseDB;
GO

-- ============================================================
-- 补充复合索引（高频查询路径）
-- ============================================================

-- 商品搜索：分类+辣度+可用
CREATE NONCLUSTERED INDEX IX_products_search
    ON dbo.products(category_id, spiciness, is_available)
    WHERE is_deleted = 0;
GO

-- 订单时间范围查询（后台对账）
CREATE NONCLUSTERED INDEX IX_orders_user_created
    ON dbo.orders(user_id, created_at DESC)
    WHERE is_deleted = 0;
GO

-- 支付记录按状态+时间（对账/退款）
CREATE NONCLUSTERED INDEX IX_payments_status_created
    ON dbo.payments(payment_status, created_at DESC);
GO

-- 优惠券去重领用（同一用户同一模板只能领一张未使用券）
CREATE UNIQUE NONCLUSTERED INDEX UQ_user_coupon_one_active
    ON dbo.user_coupon(user_id, coupon_template_id)
    WHERE status = 'unused';
GO

-- ============================================================
-- 库存扣减存储过程（带行级锁 + 乐观锁示例）
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.usp_DeductStock
    @product_id     BIGINT,
    @quantity       INT,
    @expected_rowversion ROWVERSION          -- 调用方传入读取时的 rowversion
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ① 行级锁定 + 乐观锁校验
        DECLARE @current_stock INT, @current_rv ROWVERSION;

        SELECT @current_stock = stock, @current_rv = rowversion
        FROM dbo.products WITH (ROWLOCK, UPDLOCK)   -- 行锁 + 更新锁，防止并发
        WHERE id = @product_id AND is_deleted = 0;

        -- 乐观锁：rowversion 对不上说明已被修改
        IF @current_rv <> @expected_rowversion
        BEGIN
            ;THROW 50001, N'库存数据已被其他事务修改，请刷新后重试', 1;
        END;

        IF @current_stock IS NULL
        BEGIN
            ;THROW 50002, N'商品不存在或已下架', 1;
        END;

        IF @current_stock < @quantity
        BEGIN
            ;THROW 50003, N'库存不足', 1;
        END;

        -- ② 扣减（rowversion 自动更新）
        UPDATE dbo.products
        SET stock = stock - @quantity, updated_at = SYSUTCDATETIME()
        WHERE id = @product_id AND stock >= @quantity;

        IF @@ROWCOUNT = 0
        BEGIN
            ;THROW 50004, N'库存扣减失败，请重试', 1;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================
-- 完整下单事务示例（文档用途，不在迁移时执行）
-- 详见 docs/order_transaction_example.sql
-- ============================================================
