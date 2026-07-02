-- ============================================================
-- V5: 订单表 (orders)
-- status: pending/confirmed/preparing/delivering/completed/cancelled/refunded
-- 乐观锁 rowversion
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.orders (
    id              BIGINT          NOT NULL IDENTITY(1,1),
    user_id         BIGINT          NOT NULL,
    order_no        NVARCHAR(32)    NOT NULL,           -- 订单号 YYYYMMDDHHMMSS+6位随机
    total_amount    DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10,2)   NOT NULL DEFAULT 0.00, -- 优惠券折扣金额
    points_deducted INT             NOT NULL DEFAULT 0,    -- 抵扣积分
    points_amount   DECIMAL(10,2)   NOT NULL DEFAULT 0.00, -- 积分抵扣金额
    actual_amount   DECIMAL(10,2)   NOT NULL DEFAULT 0.00, -- 实付金额
    status          NVARCHAR(16)    NOT NULL DEFAULT 'pending',
    remark          NVARCHAR(512)   NULL,
    is_deleted      BIT             NOT NULL DEFAULT 0,
    created_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion      ROWVERSION,

    CONSTRAINT PK_orders PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id)
        REFERENCES dbo.users(id),
    CONSTRAINT UQ_orders_order_no UNIQUE (order_no),
    CONSTRAINT CK_orders_total CHECK (total_amount >= 0),
    CONSTRAINT CK_orders_discount CHECK (discount_amount >= 0),
    CONSTRAINT CK_orders_actual CHECK (actual_amount >= 0),
    CONSTRAINT CK_orders_status CHECK (status IN (
        'pending','confirmed','preparing','delivering','completed','cancelled','refunded'
    ))
);
GO

CREATE NONCLUSTERED INDEX IX_orders_user ON dbo.orders(user_id);
CREATE NONCLUSTERED INDEX IX_orders_status ON dbo.orders(status) WHERE is_deleted = 0;
CREATE NONCLUSTERED INDEX IX_orders_created ON dbo.orders(created_at DESC) WHERE is_deleted = 0;
GO
