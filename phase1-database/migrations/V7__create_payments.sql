-- ============================================================
-- V7: 支付记录表 (payments)
-- payment_method: wechat/alipay/cash/stored / points
-- payment_status: pending/success/failed/refunded
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.payments (
    id              BIGINT          NOT NULL IDENTITY(1,1),
    order_id        BIGINT          NOT NULL,
    user_id         BIGINT          NOT NULL,
    amount          DECIMAL(10,2)   NOT NULL,
    payment_method  NVARCHAR(16)    NOT NULL,
    payment_status  NVARCHAR(16)    NOT NULL DEFAULT 'pending',
    transaction_id  NVARCHAR(128)   NULL,                -- 第三方交易号
    paid_at         DATETIME2(0)    NULL,                -- 支付完成时间
    created_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion      ROWVERSION,

    CONSTRAINT PK_payments PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_payments_order FOREIGN KEY (order_id)
        REFERENCES dbo.orders(id),
    CONSTRAINT FK_payments_user FOREIGN KEY (user_id)
        REFERENCES dbo.users(id),
    CONSTRAINT CK_payments_amount CHECK (amount >= 0),
    CONSTRAINT CK_payments_method CHECK (payment_method IN ('wechat','alipay','cash','stored','points')),
    CONSTRAINT CK_payments_status CHECK (payment_status IN ('pending','success','failed','refunded'))
);
GO

CREATE NONCLUSTERED INDEX IX_payments_order ON dbo.payments(order_id);
CREATE NONCLUSTERED INDEX IX_payments_user ON dbo.payments(user_id);
GO
