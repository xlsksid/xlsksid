-- ============================================================
-- V10: 优惠券模板表 (coupon_template)
-- type: discount=折扣券 / reduction=满减券
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.coupon_template (
    id               INT             NOT NULL IDENTITY(1,1),
    name             NVARCHAR(64)    NOT NULL,
    type             NVARCHAR(16)    NOT NULL,               -- discount | reduction
    discount_rate    DECIMAL(3,2)    NULL,                   -- 折扣率 0.00~1.00（type=discount 时）
    reduction_amount DECIMAL(10,2)   NULL,                   -- 满减金额（type=reduction 时）
    min_order_amount DECIMAL(10,2)   NOT NULL DEFAULT 0.00,  -- 最低订单金额门槛
    valid_days       INT             NOT NULL DEFAULT 30,     -- 领取后有效天数
    total_quantity   INT             NOT NULL DEFAULT 0,      -- 发放总量（0=不限）
    issued_count     INT             NOT NULL DEFAULT 0,      -- 已领取数
    is_active        BIT             NOT NULL DEFAULT 1,
    created_at       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at       DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion       ROWVERSION,

    CONSTRAINT PK_coupon_template PRIMARY KEY CLUSTERED (id),
    CONSTRAINT CK_coupon_template_type CHECK (type IN ('discount','reduction')),
    CONSTRAINT CK_coupon_template_discount_rate
        CHECK ((type = 'discount' AND discount_rate IS NOT NULL AND discount_rate > 0 AND discount_rate <= 1)
            OR (type = 'reduction')),
    CONSTRAINT CK_coupon_template_reduction
        CHECK ((type = 'reduction' AND reduction_amount IS NOT NULL AND reduction_amount > 0)
            OR (type = 'discount')),
    CONSTRAINT CK_coupon_template_min_order CHECK (min_order_amount >= 0),
    CONSTRAINT CK_coupon_template_valid_days CHECK (valid_days > 0)
);
GO

CREATE NONCLUSTERED INDEX IX_coupon_template_active ON dbo.coupon_template(is_active) WHERE is_active = 1;
GO
