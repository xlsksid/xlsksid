-- ============================================================
-- V6: 订单明细表 (order_details)
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.order_details (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    order_id    BIGINT          NOT NULL,
    product_id  BIGINT          NOT NULL,
    quantity    INT             NOT NULL,
    unit_price  DECIMAL(10,2)   NOT NULL,              -- 下单时单价快照
    subtotal    DECIMAL(10,2)   NOT NULL,              -- quantity * unit_price
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_order_details PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_order_details_order FOREIGN KEY (order_id)
        REFERENCES dbo.orders(id),
    CONSTRAINT FK_order_details_product FOREIGN KEY (product_id)
        REFERENCES dbo.products(id),
    CONSTRAINT CK_order_details_quantity CHECK (quantity > 0),
    CONSTRAINT CK_order_details_subtotal CHECK (subtotal >= 0)
);
GO

CREATE NONCLUSTERED INDEX IX_order_details_order ON dbo.order_details(order_id);
GO
