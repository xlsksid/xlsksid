-- ============================================================
-- V4: 商品表 (products)
-- 价格/成本用 DECIMAL(10,2)；乐观锁 rowversion
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.products (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    name        NVARCHAR(128)   NOT NULL,
    description NVARCHAR(1024)  NULL,
    price       DECIMAL(10,2)   NOT NULL,              -- 售价
    cost_price  DECIMAL(10,2)   NOT NULL DEFAULT 0.00, -- 成本价
    stock       INT             NOT NULL DEFAULT 0,    -- 当前库存
    unit        NVARCHAR(16)    NOT NULL DEFAULT N'份', -- 单位：份/斤/个
    image_url   NVARCHAR(512)   NULL,
    category_id INT             NOT NULL,
    spiciness   TINYINT         NOT NULL DEFAULT 1,    -- 辣度 1-5
    is_available BIT            NOT NULL DEFAULT 1,
    is_deleted  BIT             NOT NULL DEFAULT 0,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion  ROWVERSION,

    CONSTRAINT PK_products PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_products_category FOREIGN KEY (category_id)
        REFERENCES dbo.categories(id),
    CONSTRAINT CK_products_price CHECK (price >= 0),
    CONSTRAINT CK_products_cost CHECK (cost_price >= 0),
    CONSTRAINT CK_products_stock CHECK (stock >= 0),
    CONSTRAINT CK_products_spiciness CHECK (spiciness BETWEEN 1 AND 5)
);
GO

CREATE NONCLUSTERED INDEX IX_products_category ON dbo.products(category_id) WHERE is_deleted = 0;
CREATE NONCLUSTERED INDEX IX_products_available ON dbo.products(is_available) WHERE is_deleted = 0;
GO
