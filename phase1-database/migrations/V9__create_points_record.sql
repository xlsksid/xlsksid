-- ============================================================
-- V9: 积分记录表 (points_record)
-- type: earn=获得 / spend=消费
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.points_record (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    user_id     BIGINT          NOT NULL,
    points      INT             NOT NULL,                -- 正数=获得，负数=消费
    type        NVARCHAR(8)     NOT NULL,                -- earn | spend
    description NVARCHAR(256)   NULL,
    order_id    BIGINT          NULL,                    -- 关联订单（消费积分时）
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_points_record PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_points_record_user FOREIGN KEY (user_id)
        REFERENCES dbo.users(id),
    CONSTRAINT CK_points_record_type CHECK (type IN ('earn','spend'))
);
GO

CREATE NONCLUSTERED INDEX IX_points_record_user ON dbo.points_record(user_id, created_at DESC);
GO
