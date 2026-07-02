-- ============================================================
-- V3: 分类表 (categories)
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.categories (
    id          INT             NOT NULL IDENTITY(1,1),
    name        NVARCHAR(64)    NOT NULL,
    description NVARCHAR(256)   NULL,
    sort_order  INT             NOT NULL DEFAULT 0,   -- 排序权重（升序）
    image_url   NVARCHAR(512)   NULL,                 -- 分类图片
    is_deleted  BIT             NOT NULL DEFAULT 0,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion  ROWVERSION,

    CONSTRAINT PK_categories PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_categories_name UNIQUE (name)
);
GO

CREATE NONCLUSTERED INDEX IX_categories_sort ON dbo.categories(sort_order) WHERE is_deleted = 0;
GO
