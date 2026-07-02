-- ============================================================
-- Master Setup: 重建全部表 + seed 数据
-- 用法: sqlcmd -S localhost\SQLEXPRESS -E -f 65001 -i setup.sql
-- ============================================================
SET QUOTED_IDENTIFIER ON;
GO

-- 删除旧库重建
IF DB_ID('SpicyBraiseDB') IS NOT NULL
BEGIN
    ALTER DATABASE SpicyBraiseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SpicyBraiseDB;
END
GO

CREATE DATABASE SpicyBraiseDB COLLATE Chinese_PRC_CI_AS;
GO

ALTER DATABASE SpicyBraiseDB SET RECOVERY FULL;
ALTER DATABASE SpicyBraiseDB SET READ_COMMITTED_SNAPSHOT ON;
GO

USE SpicyBraiseDB;
GO
PRINT '=== Database created ===';
GO

-- ============================================================
-- V2: users
-- ============================================================
CREATE TABLE dbo.users (
    id            BIGINT          NOT NULL IDENTITY(1,1),
    username      NVARCHAR(64)    NOT NULL,
    password_hash NVARCHAR(256)   NOT NULL,
    email         NVARCHAR(128)   NULL,
    phone         NVARCHAR(20)    NULL,
    role          NVARCHAR(16)    NOT NULL DEFAULT 'customer',
    avatar        NVARCHAR(512)   NULL,
    balance       DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    points        INT             NOT NULL DEFAULT 0,
    is_deleted    BIT             NOT NULL DEFAULT 0,
    created_at    DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion    ROWVERSION,

    CONSTRAINT PK_users PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_users_username UNIQUE (username),
    CONSTRAINT UQ_users_email UNIQUE (email),
    CONSTRAINT CK_users_role CHECK (role IN ('admin','staff','customer')),
    CONSTRAINT CK_users_balance CHECK (balance >= 0),
    CONSTRAINT CK_users_points CHECK (points >= 0)
);
GO

CREATE NONCLUSTERED INDEX IX_users_email ON dbo.users(email) WHERE email IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_users_role ON dbo.users(role) WHERE is_deleted = 0;
GO
PRINT '=== users created ===';
GO

-- ============================================================
-- V3: categories
-- ============================================================
CREATE TABLE dbo.categories (
    id          INT             NOT NULL IDENTITY(1,1),
    name        NVARCHAR(64)    NOT NULL,
    description NVARCHAR(256)   NULL,
    sort_order  INT             NOT NULL DEFAULT 0,
    image_url   NVARCHAR(512)   NULL,
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
PRINT '=== categories created ===';
GO

-- ============================================================
-- V4: products
-- ============================================================
CREATE TABLE dbo.products (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    name        NVARCHAR(128)   NOT NULL,
    description NVARCHAR(1024)  NULL,
    price       DECIMAL(10,2)   NOT NULL,
    cost_price  DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    stock       INT             NOT NULL DEFAULT 0,
    unit        NVARCHAR(16)    NOT NULL DEFAULT N'fen',
    image_url   NVARCHAR(512)   NULL,
    category_id INT             NOT NULL,
    spiciness   TINYINT         NOT NULL DEFAULT 1,
    is_available BIT            NOT NULL DEFAULT 1,
    is_deleted  BIT             NOT NULL DEFAULT 0,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion  ROWVERSION,

    CONSTRAINT PK_products PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_products_category FOREIGN KEY (category_id) REFERENCES dbo.categories(id),
    CONSTRAINT CK_products_price CHECK (price >= 0),
    CONSTRAINT CK_products_cost CHECK (cost_price >= 0),
    CONSTRAINT CK_products_stock CHECK (stock >= 0),
    CONSTRAINT CK_products_spiciness CHECK (spiciness BETWEEN 1 AND 5)
);
GO

CREATE NONCLUSTERED INDEX IX_products_category ON dbo.products(category_id) WHERE is_deleted = 0;
CREATE NONCLUSTERED INDEX IX_products_available ON dbo.products(is_available) WHERE is_deleted = 0;
GO
PRINT '=== products created ===';
GO

-- ============================================================
-- V5: orders
-- ============================================================
CREATE TABLE dbo.orders (
    id              BIGINT          NOT NULL IDENTITY(1,1),
    user_id         BIGINT          NOT NULL,
    order_no        NVARCHAR(32)    NOT NULL,
    total_amount    DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    points_deducted INT             NOT NULL DEFAULT 0,
    points_amount   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    actual_amount   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    status          NVARCHAR(16)    NOT NULL DEFAULT 'pending',
    remark          NVARCHAR(512)   NULL,
    is_deleted      BIT             NOT NULL DEFAULT 0,
    created_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion      ROWVERSION,

    CONSTRAINT PK_orders PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_orders_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT UQ_orders_order_no UNIQUE (order_no),
    CONSTRAINT CK_orders_total CHECK (total_amount >= 0),
    CONSTRAINT CK_orders_discount CHECK (discount_amount >= 0),
    CONSTRAINT CK_orders_actual CHECK (actual_amount >= 0),
    CONSTRAINT CK_orders_status CHECK (status IN ('pending','confirmed','preparing','delivering','completed','cancelled','refunded'))
);
GO

CREATE NONCLUSTERED INDEX IX_orders_user ON dbo.orders(user_id);
CREATE NONCLUSTERED INDEX IX_orders_status ON dbo.orders(status) WHERE is_deleted = 0;
CREATE NONCLUSTERED INDEX IX_orders_created ON dbo.orders(created_at DESC) WHERE is_deleted = 0;
GO
PRINT '=== orders created ===';
GO

-- ============================================================
-- V6: order_details
-- ============================================================
CREATE TABLE dbo.order_details (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    order_id    BIGINT          NOT NULL,
    product_id  BIGINT          NOT NULL,
    quantity    INT             NOT NULL,
    unit_price  DECIMAL(10,2)   NOT NULL,
    subtotal    DECIMAL(10,2)   NOT NULL,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_order_details PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_order_details_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_order_details_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
    CONSTRAINT CK_order_details_quantity CHECK (quantity > 0),
    CONSTRAINT CK_order_details_subtotal CHECK (subtotal >= 0)
);
GO

CREATE NONCLUSTERED INDEX IX_order_details_order ON dbo.order_details(order_id);
GO
PRINT '=== order_details created ===';
GO

-- ============================================================
-- V7: payments
-- ============================================================
CREATE TABLE dbo.payments (
    id              BIGINT          NOT NULL IDENTITY(1,1),
    order_id        BIGINT          NOT NULL,
    user_id         BIGINT          NOT NULL,
    amount          DECIMAL(10,2)   NOT NULL,
    payment_method  NVARCHAR(16)    NOT NULL,
    payment_status  NVARCHAR(16)    NOT NULL DEFAULT 'pending',
    transaction_id  NVARCHAR(128)   NULL,
    paid_at         DATETIME2(0)    NULL,
    created_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion      ROWVERSION,

    CONSTRAINT PK_payments PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_payments_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT FK_payments_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_payments_amount CHECK (amount >= 0),
    CONSTRAINT CK_payments_method CHECK (payment_method IN ('wechat','alipay','cash','stored','points')),
    CONSTRAINT CK_payments_status CHECK (payment_status IN ('pending','success','failed','refunded'))
);
GO

CREATE NONCLUSTERED INDEX IX_payments_order ON dbo.payments(order_id);
CREATE NONCLUSTERED INDEX IX_payments_user ON dbo.payments(user_id);
GO
PRINT '=== payments created ===';
GO

-- ============================================================
-- V8: feedback
-- ============================================================
CREATE TABLE dbo.feedback (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    user_id     BIGINT          NOT NULL,
    product_id  BIGINT          NOT NULL,
    order_id    BIGINT          NOT NULL,
    rating      TINYINT         NOT NULL,
    comment     NVARCHAR(1024)  NULL,
    is_deleted  BIT             NOT NULL DEFAULT 0,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion  ROWVERSION,

    CONSTRAINT PK_feedback PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_feedback_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_feedback_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
    CONSTRAINT FK_feedback_order FOREIGN KEY (order_id) REFERENCES dbo.orders(id),
    CONSTRAINT CK_feedback_rating CHECK (rating BETWEEN 1 AND 5)
);
GO

CREATE NONCLUSTERED INDEX IX_feedback_product ON dbo.feedback(product_id) WHERE is_deleted = 0;
CREATE NONCLUSTERED INDEX IX_feedback_user ON dbo.feedback(user_id) WHERE is_deleted = 0;
GO
PRINT '=== feedback created ===';
GO

-- ============================================================
-- V9: points_record
-- ============================================================
CREATE TABLE dbo.points_record (
    id          BIGINT          NOT NULL IDENTITY(1,1),
    user_id     BIGINT          NOT NULL,
    points      INT             NOT NULL,
    type        NVARCHAR(8)     NOT NULL,
    description NVARCHAR(256)   NULL,
    order_id    BIGINT          NULL,
    created_at  DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_points_record PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_points_record_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT CK_points_record_type CHECK (type IN ('earn','spend'))
);
GO

CREATE NONCLUSTERED INDEX IX_points_record_user ON dbo.points_record(user_id, created_at DESC);
GO
PRINT '=== points_record created ===';
GO

-- ============================================================
-- V10: coupon_template
-- ============================================================
CREATE TABLE dbo.coupon_template (
    id               INT             NOT NULL IDENTITY(1,1),
    name             NVARCHAR(64)    NOT NULL,
    type             NVARCHAR(16)    NOT NULL,
    discount_rate    DECIMAL(3,2)    NULL,
    reduction_amount DECIMAL(10,2)   NULL,
    min_order_amount DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    valid_days       INT             NOT NULL DEFAULT 30,
    total_quantity   INT             NOT NULL DEFAULT 0,
    issued_count     INT             NOT NULL DEFAULT 0,
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
PRINT '=== coupon_template created ===';
GO

-- ============================================================
-- V11: user_coupon
-- ============================================================
CREATE TABLE dbo.user_coupon (
    id                  BIGINT          NOT NULL IDENTITY(1,1),
    user_id             BIGINT          NOT NULL,
    coupon_template_id  INT             NOT NULL,
    status              NVARCHAR(16)    NOT NULL DEFAULT 'unused',
    used_order_id       BIGINT          NULL,
    valid_from          DATETIME2(0)    NOT NULL,
    valid_to            DATETIME2(0)    NOT NULL,
    used_at             DATETIME2(0)    NULL,
    created_at          DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion          ROWVERSION,

    CONSTRAINT PK_user_coupon PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_user_coupon_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_user_coupon_template FOREIGN KEY (coupon_template_id) REFERENCES dbo.coupon_template(id),
    CONSTRAINT FK_user_coupon_order FOREIGN KEY (used_order_id) REFERENCES dbo.orders(id),
    CONSTRAINT CK_user_coupon_status CHECK (status IN ('unused','used','expired'))
);
GO

CREATE NONCLUSTERED INDEX IX_user_coupon_user ON dbo.user_coupon(user_id, status);
CREATE NONCLUSTERED INDEX IX_user_coupon_valid ON dbo.user_coupon(valid_to) WHERE status = 'unused';
GO
PRINT '=== user_coupon created ===';
GO

-- ============================================================
-- V12: 补充索引 + 库存扣减存储过程
-- ============================================================
CREATE NONCLUSTERED INDEX IX_products_search
    ON dbo.products(category_id, spiciness, is_available)
    WHERE is_deleted = 0;
GO

CREATE NONCLUSTERED INDEX IX_orders_user_created
    ON dbo.orders(user_id, created_at DESC)
    WHERE is_deleted = 0;
GO

CREATE NONCLUSTERED INDEX IX_payments_status_created
    ON dbo.payments(payment_status, created_at DESC);
GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_user_coupon_one_active
    ON dbo.user_coupon(user_id, coupon_template_id)
    WHERE status = 'unused';
GO

-- 库存扣减存储过程
CREATE OR ALTER PROCEDURE dbo.usp_DeductStock
    @product_id     BIGINT,
    @quantity       INT,
    @expected_rowversion ROWVERSION
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @current_stock INT, @current_rv ROWVERSION;

        SELECT @current_stock = stock, @current_rv = rowversion
        FROM dbo.products WITH (ROWLOCK, UPDLOCK)
        WHERE id = @product_id AND is_deleted = 0;

        IF @current_rv <> @expected_rowversion
        BEGIN
            ;THROW 50001, N'Stock modified by another transaction, please retry', 1;
        END;

        IF @current_stock IS NULL
        BEGIN
            ;THROW 50002, N'Product not found or unavailable', 1;
        END;

        IF @current_stock < @quantity
        BEGIN
            ;THROW 50003, N'Insufficient stock', 1;
        END;

        UPDATE dbo.products
        SET stock = stock - @quantity, updated_at = SYSUTCDATETIME()
        WHERE id = @product_id AND stock >= @quantity;

        IF @@ROWCOUNT = 0
        BEGIN
            ;THROW 50004, N'Stock deduction failed', 1;
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
PRINT '=== indexes + usp_DeductStock created ===';
GO
