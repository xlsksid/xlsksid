-- ============================================================
-- V2: 用户表 (users)
-- 角色：admin=管理员 / staff=店员 / customer=顾客
-- 乐观锁：rowversion 字段
-- 软删：is_deleted BIT
-- ============================================================

USE SpicyBraiseDB;
GO

CREATE TABLE dbo.users (
    id            BIGINT          NOT NULL IDENTITY(1,1),
    username      NVARCHAR(64)    NOT NULL,
    password_hash NVARCHAR(256)   NOT NULL,          -- bcrypt / argon2 哈希
    email         NVARCHAR(128)   NULL,
    phone         NVARCHAR(20)    NULL,
    role          NVARCHAR(16)    NOT NULL DEFAULT 'customer', -- admin | staff | customer
    avatar        NVARCHAR(512)   NULL,              -- 头像 URL
    balance       DECIMAL(10,2)   NOT NULL DEFAULT 0.00, -- 账户余额（储值）
    points        INT             NOT NULL DEFAULT 0,     -- 积分余额
    is_deleted    BIT             NOT NULL DEFAULT 0,
    created_at    DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at    DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),
    rowversion    ROWVERSION,                         -- 乐观并发控制

    CONSTRAINT PK_users PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_users_username UNIQUE (username),
    CONSTRAINT UQ_users_email UNIQUE (email),
    CONSTRAINT CK_users_role CHECK (role IN ('admin','staff','customer')),
    CONSTRAINT CK_users_balance CHECK (balance >= 0),
    CONSTRAINT CK_users_points CHECK (points >= 0)
);
GO

-- 索引
CREATE NONCLUSTERED INDEX IX_users_email ON dbo.users(email) WHERE email IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_users_role ON dbo.users(role) WHERE is_deleted = 0;
GO
