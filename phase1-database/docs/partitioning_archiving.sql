-- ============================================================
-- 分区函数 & 归档策略
-- 香辣卤味管理系统 — SQL Server
-- ============================================================

USE SpicyBraiseDB;
GO

-- ============================================================
-- 1. 订单表按月分区（高频大表）
-- ============================================================

-- 创建分区函数（按 created_at 月份）
CREATE PARTITION FUNCTION pf_Orders_Monthly (DATETIME2(0))
AS RANGE RIGHT FOR VALUES (
    '2024-01-01T00:00:00', '2024-02-01T00:00:00', '2024-03-01T00:00:00',
    '2024-04-01T00:00:00', '2024-05-01T00:00:00', '2024-06-01T00:00:00',
    '2024-07-01T00:00:00', '2024-08-01T00:00:00', '2024-09-01T00:00:00',
    '2024-10-01T00:00:00', '2024-11-01T00:00:00', '2024-12-01T00:00:00',
    '2025-01-01T00:00:00', '2025-02-01T00:00:00', '2025-03-01T00:00:00',
    '2025-04-01T00:00:00', '2025-05-01T00:00:00', '2025-06-01T00:00:00',
    '2025-07-01T00:00:00', '2025-08-01T00:00:00', '2025-09-01T00:00:00',
    '2025-10-01T00:00:00', '2025-11-01T00:00:00', '2025-12-01T00:00:00'
);
GO

-- 分区方案（生产环境建议分开文件组，此处演示统一放到 PRIMARY）
CREATE PARTITION SCHEME ps_Orders_Monthly
AS PARTITION pf_Orders_Monthly ALL TO ([PRIMARY]);
GO

/*
-- ⚠️ 将现有 orders 表迁移到分区需要重建聚集索引：

CREATE UNIQUE CLUSTERED INDEX PK_orders_partitioned
    ON dbo.orders(created_at, id)
    WITH (DROP_EXISTING = ON)
    ON ps_Orders_Monthly(created_at);
GO

-- 回退到非分区：
CREATE UNIQUE CLUSTERED INDEX PK_orders
    ON dbo.orders(id)
    WITH (DROP_EXISTING = ON)
    ON [PRIMARY];
GO
*/


-- ============================================================
-- 2. 订单归档表 & 归档存储过程
-- ============================================================
CREATE TABLE dbo.orders_archive (
    id              BIGINT          NOT NULL,
    user_id         BIGINT          NOT NULL,
    order_no        NVARCHAR(32)    NOT NULL,
    total_amount    DECIMAL(10,2)   NOT NULL,
    discount_amount DECIMAL(10,2)   NOT NULL,
    points_deducted INT             NOT NULL,
    points_amount   DECIMAL(10,2)   NOT NULL,
    actual_amount   DECIMAL(10,2)   NOT NULL,
    status          NVARCHAR(16)    NOT NULL,
    remark          NVARCHAR(512)   NULL,
    is_deleted      BIT             NOT NULL,
    created_at      DATETIME2(0)    NOT NULL,
    updated_at      DATETIME2(0)    NOT NULL,
    archived_at     DATETIME2(0)    NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_orders_archive PRIMARY KEY CLUSTERED (id, created_at)
);
GO

-- 归档存储过程：将 N 个月前的已完成/已取消订单迁移到归档表
CREATE OR ALTER PROCEDURE dbo.usp_ArchiveOldOrders
    @months_ago INT = 6        -- 默认归档 6 个月前的订单
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @cutoff DATETIME2(0) = DATEADD(MONTH, -@months_ago, SYSUTCDATETIME());

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ① 插入归档表
        INSERT INTO dbo.orders_archive (
            id, user_id, order_no, total_amount, discount_amount,
            points_deducted, points_amount, actual_amount, status, remark,
            is_deleted, created_at, updated_at
        )
        SELECT id, user_id, order_no, total_amount, discount_amount,
               points_deducted, points_amount, actual_amount, status, remark,
               is_deleted, created_at, updated_at
        FROM dbo.orders WITH (TABLOCK)
        WHERE created_at < @cutoff
          AND status IN ('completed', 'cancelled', 'refunded');

        -- ② 删除原表数据
        DELETE FROM dbo.orders
        WHERE created_at < @cutoff
          AND status IN ('completed', 'cancelled', 'refunded');

        COMMIT TRANSACTION;

        PRINT CONCAT(N'归档完成：', @@ROWCOUNT, N' 条订单已迁移到 orders_archive');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


-- ============================================================
-- 3. 性能索引建议清单（注释形式，供 DBA 评估后执行）
-- ============================================================

/*
-- ① 覆盖索引：订单列表页常用查询（避免回表）
CREATE NONCLUSTERED INDEX IX_orders_list_cover
    ON dbo.orders(user_id, status, created_at DESC)
    INCLUDE (order_no, actual_amount)
    WHERE is_deleted = 0;
GO

-- ② 支付记录对账：按交易号查询
CREATE NONCLUSTERED INDEX IX_payments_txn
    ON dbo.payments(transaction_id)
    WHERE transaction_id IS NOT NULL;
GO

-- ③ 商品全文搜索（如需模糊搜索商品名/描述）
CREATE FULLTEXT CATALOG ft_spicy AS DEFAULT;
CREATE FULLTEXT INDEX ON dbo.products(name, description)
    KEY INDEX PK_products
    ON ft_spicy
    WITH CHANGE_TRACKING AUTO;
GO

-- ④ 统计信息更新（定期维护）
UPDATE STATISTICS dbo.orders;
UPDATE STATISTICS dbo.products;
GO

-- ⑤ 索引碎片整理（定期维护，碎片率 >30% 时执行）
ALTER INDEX PK_orders ON dbo.orders REBUILD;
ALTER INDEX PK_products ON dbo.products REORGANIZE;
GO
*/

PRINT N'分区函数、归档策略、性能建议已输出完成！';
GO
