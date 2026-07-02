-- ============================================================
-- V11: 用户优惠券表 (user_coupon)
-- status: unused=未使用 / used=已使用 / expired=已过期
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.user_coupon (
    id                  BIGINT          NOT NULL IDENTITY(1,1),
    user_id             BIGINT          NOT NULL,
    coupon_template_id  INT             NOT NULL,
    status              NVARCHAR(16)    NOT NULL DEFAULT 'unused', -- unused | used | expired
    used_order_id       BIGINT          NULL,
    valid_from          DATETIME2(0)    NOT NULL,
    valid_to            DATETIME2(0)    NOT NULL,
    used_at             DATETIME2(0)    NULL,
    created_at          DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion          ROWVERSION,

    CONSTRAINT PK_user_coupon PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_user_coupon_user FOREIGN KEY (user_id)
        REFERENCES dbo.users(id),
    CONSTRAINT FK_user_coupon_template FOREIGN KEY (coupon_template_id)
        REFERENCES dbo.coupon_template(id),
    CONSTRAINT FK_user_coupon_order FOREIGN KEY (used_order_id)
        REFERENCES dbo.orders(id),
    CONSTRAINT CK_user_coupon_status CHECK (status IN ('unused','used','expired'))
);
GO

CREATE NONCLUSTERED INDEX IX_user_coupon_user ON dbo.user_coupon(user_id, status);
CREATE NONCLUSTERED INDEX IX_user_coupon_valid ON dbo.user_coupon(valid_to) WHERE status = 'unused';
GO
