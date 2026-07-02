SET QUOTED_IDENTIFIER ON;
GO
DECLARE @oid BIGINT, @ono NVARCHAR(32);
EXEC dbo.usp_PlaceOrder
    @user_id = 5,
    @items_json = N'[{"product_id":4,"quantity":3}]',
    @coupon_id = NULL,
    @use_points = 200,
    @remark = N'Test order via stored procedure',
    @new_order_id = @oid OUTPUT,
    @new_order_no = @ono OUTPUT;
SELECT @oid AS order_id, @ono AS order_no;
GO

SELECT * FROM dbo.orders WHERE user_id = 5 ORDER BY id DESC;
GO
SELECT * FROM dbo.order_details WHERE order_id = (SELECT MAX(id) FROM dbo.orders WHERE user_id = 5);
GO
SELECT * FROM dbo.payments WHERE order_id = (SELECT MAX(id) FROM dbo.orders WHERE user_id = 5);
GO
SELECT id, points FROM dbo.users WHERE id = 5;
GO
SELECT id, stock FROM dbo.products WHERE id = 4;
GO
