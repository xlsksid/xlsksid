-- ============================================================
-- V8: 反馈/评价表 (feedback)
-- rating: 1-5 星
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.feedback (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    user_id     BIGINT          NOT NULL,
    product_id  BIGINT          NOT NULL,
    order_id    BIGINT          NOT NULL,
    rating      TINYINT         NOT NULL,                -- 1-5 星
    comment     NVARCHAR(1024)  NULL,
    is_deleted  BIT             NOT NULL DEFAULT 0,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion  ROWVERSION,

    CONSTRAINT PK_feedback PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_feedback_user FOREIGN KEY (user_id)
        REFERENCES dbo.users(id),
    CONSTRAINT FK_feedback_product FOREIGN KEY (product_id)
        REFERENCES dbo.products(id),
    CONSTRAINT FK_feedback_order FOREIGN KEY (order_id)
        REFERENCES dbo.orders(id),
    CONSTRAINT CK_feedback_rating CHECK (rating BETWEEN 1 AND 5)
);
GO

CREATE NONCLUSTERED INDEX IX_feedback_product ON dbo.feedback(product_id) WHERE is_deleted = 0;
CREATE NONCLUSTERED INDEX IX_feedback_user ON dbo.feedback(user_id) WHERE is_deleted = 0;
GO
