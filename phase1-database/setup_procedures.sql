SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE dbo.usp_PlaceOrder
    @user_id            BIGINT,
    @items_json         NVARCHAR(MAX),
    @coupon_id          BIGINT = NULL,
    @use_points         INT    = 0,
    @remark             NVARCHAR(512) = NULL,
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

    DECLARE @items TABLE (product_id BIGINT, quantity INT);

    INSERT INTO @items (product_id, quantity)
    SELECT product_id, quantity
    FROM OPENJSON(@items_json)
    WITH (product_id BIGINT '$.product_id', quantity INT '$.quantity');

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @pid BIGINT, @qty INT, @price DECIMAL(10,2), @cur_stock INT, @rv ROWVERSION;
        DECLARE item_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT product_id, quantity FROM @items;
        OPEN item_cursor;
        FETCH NEXT FROM item_cursor INTO @pid, @qty;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @price = price, @cur_stock = stock, @rv = rowversion
            FROM dbo.products WITH (ROWLOCK, UPDLOCK)
            WHERE id = @pid AND is_deleted = 0 AND is_available = 1;

            IF @@ROWCOUNT = 0 THROW 50001, 'Product not found', 1;
            IF @cur_stock < @qty THROW 50002, 'Insufficient stock', 1;

            UPDATE dbo.products SET stock = stock - @qty, updated_at = @now
            WHERE id = @pid AND stock >= @qty;

            IF @@ROWCOUNT = 0 THROW 50003, 'Stock deduction failed', 1;

            SET @total_amount += @price * @qty;
            FETCH NEXT FROM item_cursor INTO @pid, @qty;
        END;
        CLOSE item_cursor;
        DEALLOCATE item_cursor;

        IF @coupon_id IS NOT NULL
        BEGIN
            DECLARE @ct_type NVARCHAR(16), @ct_discount DECIMAL(3,2),
                    @ct_reduction DECIMAL(10,2), @ct_min_order DECIMAL(10,2),
                    @valid_from2 DATETIME2(0), @valid_to2 DATETIME2(0),
                    @coupon_status2 NVARCHAR(16);

            SELECT @ct_type = ct.type, @ct_discount = ct.discount_rate,
                   @ct_reduction = ct.reduction_amount, @ct_min_order = ct.min_order_amount,
                   @valid_from2 = uc.valid_from, @valid_to2 = uc.valid_to,
                   @coupon_status2 = uc.status
            FROM dbo.user_coupon uc WITH (ROWLOCK, UPDLOCK)
            JOIN dbo.coupon_template ct ON uc.coupon_template_id = ct.id
            WHERE uc.id = @coupon_id AND uc.user_id = @user_id;

            IF @@ROWCOUNT = 0 THROW 50010, 'Coupon not found', 1;
            IF @coupon_status2 <> 'unused' THROW 50011, 'Coupon not available', 1;
            IF @now < @valid_from2 OR @now > @valid_to2 THROW 50012, 'Coupon expired', 1;
            IF @total_amount < @ct_min_order THROW 50013, 'Order amount too low for coupon', 1;

            IF @ct_type = 'discount'
                SET @discount_amt = @total_amount * (1 - @ct_discount);
            ELSE IF @ct_type = 'reduction'
                SET @discount_amt = @ct_reduction;

            UPDATE dbo.user_coupon SET status = 'used', used_at = @now
            WHERE id = @coupon_id AND status = 'unused';

            IF @@ROWCOUNT = 0 THROW 50014, 'Coupon lock failed', 1;
        END;

        DECLARE @user_balance_pts INT;
        SELECT @user_balance_pts = points FROM dbo.users WITH (ROWLOCK, UPDLOCK)
        WHERE id = @user_id;

        IF @use_points > 0
        BEGIN
            IF @use_points > @user_balance_pts THROW 50020, 'Insufficient points', 1;
            SET @points_amt = CAST(@use_points AS DECIMAL(10,2)) / 100.00;
            IF @points_amt > (@total_amount - @discount_amt)
                SET @points_amt = @total_amount - @discount_amt;
            UPDATE dbo.users SET points = points - @use_points WHERE id = @user_id;
            INSERT INTO dbo.points_record (user_id, points, type, description)
            VALUES (@user_id, -@use_points, 'spend', 'Points redeemed for order');
        END;

        SET @actual_amt = @total_amount - @discount_amt - @points_amt;
        IF @actual_amt < 0 SET @actual_amt = 0;
        SET @order_no = CONCAT(FORMAT(@now, 'yyyyMMddHHmmss'),
            RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS NVARCHAR(6)), 6));

        INSERT INTO dbo.orders (user_id, order_no, total_amount, discount_amount,
            points_deducted, points_amount, actual_amount, status, remark)
        VALUES (@user_id, @order_no, @total_amount, @discount_amt,
            @use_points, @points_amt, @actual_amt, 'pending', @remark);
        SET @new_order_id = SCOPE_IDENTITY();
        SET @new_order_no = @order_no;

        INSERT INTO dbo.order_details (order_id, product_id, quantity, unit_price, subtotal)
        SELECT @new_order_id, i.product_id, i.quantity, p.price, p.price * i.quantity
        FROM @items i JOIN dbo.products p ON i.product_id = p.id;

        DECLARE @pay_method NVARCHAR(16) = CASE WHEN @actual_amt = 0 THEN 'points' ELSE 'wechat' END;
        INSERT INTO dbo.payments (order_id, user_id, amount, payment_method, payment_status)
        VALUES (@new_order_id, @user_id, @actual_amt, @pay_method, 'pending');

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
PRINT 'usp_PlaceOrder created successfully';
GO
