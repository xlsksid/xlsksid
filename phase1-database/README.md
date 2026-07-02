# 香辣卤味管理系统 — 阶段1：数据库设计与迁移

## 目录结构

```
phase1-database/
├── migrations/                          # Flyway 风格迁移脚本（按序执行）
│   ├── V1__create_database.sql          # 建库 + 文件组 + 排序规则
│   ├── V2__create_users.sql             # 用户表（角色/积分/余额/乐观锁）
│   ├── V3__create_categories.sql        # 商品分类表
│   ├── V4__create_products.sql          # 商品表（库存/辣度/乐观锁）
│   ├── V5__create_orders.sql            # 订单表（状态机/金额明细）
│   ├── V6__create_order_details.sql     # 订单明细表
│   ├── V7__create_payments.sql          # 支付记录表
│   ├── V8__create_feedback.sql          # 反馈/评价表
│   ├── V9__create_points_record.sql     # 积分变动记录表
│   ├── V10__create_coupon_template.sql  # 优惠券模板表
│   ├── V11__create_user_coupon.sql      # 用户优惠券表
│   └── V12__create_indexes_procs.sql    # 补充索引 + 库存扣减存储过程
│
├── seed/
│   └── V13__seed_data.sql               # 每表 5 条初始化数据
│
├── docs/
│   ├── er_diagram.puml                  # PlantUML ER 图
│   ├── order_transaction_example.sql    # 完整下单事务 + 乐观锁示例
│   ├── partitioning_archiving.sql       # 分区函数/归档表/性能索引建议
│   └── backup_restore_export_import.sql # 备份恢复/bcp导出导入/sqlpackage示例
│
└── README.md                            # 本文件
```

## 10 张表速览

| 表名 | 说明 | 关键特性 |
|------|------|----------|
| `users` | 用户（管理员/店员/顾客） | 密码哈希、积分、余额、rowversion 乐观锁 |
| `categories` | 商品分类 | 排序权重、软删 |
| `products` | 商品 | 价格 DECIMAL(10,2)、库存、辣度 1-5、rowversion |
| `orders` | 订单 | 7 种状态、折扣/积分/实付明细、rowversion |
| `order_details` | 订单明细 | 单价快照 |
| `payments` | 支付记录 | 微信/支付宝/现金/储值/积分 |
| `feedback` | 评价 | 1-5 星、关联订单 |
| `points_record` | 积分记录 | 正数赚/负数花 |
| `coupon_template` | 优惠券模板 | 折扣券 vs 满减券、发放限额 |
| `user_coupon` | 用户持有优惠券 | 唯一约束（1人1模板1未用） |

## 技术决策

| 决策项 | 选择 | 原因 |
|--------|------|------|
| 金额类型 | `DECIMAL(10,2)` | 精确十进制，避免浮点误差 |
| 时间类型 | `DATETIME2(0)` | 秒级精度、UTC 存储、无夏令时问题 |
| 乐观锁 | `ROWVERSION` | SQL Server 原生支持、自动递增、无需应用维护 |
| 软删除 | `is_deleted BIT` | 数据可恢复、配合过滤索引优化性能 |
| 隔离级别 | `READ_COMMITTED_SNAPSHOT ON` | 读写不互斥、减少阻塞 |
| 排序规则 | `Chinese_PRC_CI_AS` | 中文友好、大小写不敏感 |
| 迁移工具 | Flyway 命名风格 | 按版本号顺序执行、可逆、跨平台 |

## 本地导入步骤（SQL Server）

### 前置条件
- SQL Server 2022+（Developer/Express 均可）
- 可选：Azure Data Studio / SSMS
- 可选：Flyway CLI 或 sqlcmd

### 方法一：sqlcmd 逐文件导入

```bash
# 按顺序执行所有迁移脚本
for f in migrations/V*.sql seed/V*.sql; do
  sqlcmd -S localhost -U sa -P "YourPassword" -i "$f"
done
```

### 方法二：SSMS / Azure Data Studio 手动执行

1. 打开工具，连接到 SQL Server 实例
2. 按 V1 → V13 顺序打开每个 `.sql` 文件
3. 逐个执行（注意每个文件开头有 `USE SpicyBraiseDB`）

### 方法三：Flyway CLI

```bash
flyway -url="jdbc:sqlserver://localhost:1433;databaseName=SpicyBraiseDB;encrypt=false" \
       -user=sa -password="YourPassword" \
       -locations="filesystem:./migrations,filesystem:./seed" \
       migrate
```

### 验证导入

```sql
USE SpicyBraiseDB;
GO
SELECT 'users' AS tbl, COUNT(*) AS rows FROM dbo.users
UNION ALL SELECT 'categories',      COUNT(*) FROM dbo.categories
UNION ALL SELECT 'products',        COUNT(*) FROM dbo.products
UNION ALL SELECT 'orders',          COUNT(*) FROM dbo.orders
UNION ALL SELECT 'order_details',   COUNT(*) FROM dbo.order_details
UNION ALL SELECT 'payments',        COUNT(*) FROM dbo.payments
UNION ALL SELECT 'feedback',        COUNT(*) FROM dbo.feedback
UNION ALL SELECT 'points_record',   COUNT(*) FROM dbo.points_record
UNION ALL SELECT 'coupon_template', COUNT(*) FROM dbo.coupon_template
UNION ALL SELECT 'user_coupon',     COUNT(*) FROM dbo.user_coupon;
GO
```

## ER 图

PlantUML 文件位于 `docs/er_diagram.puml`。

在线查看：复制内容到 https://www.plantuml.com/plantuml/uml/ 或安装 VS Code PlantUML 插件。

## 并发控制说明

1. **乐观锁** — `users / categories / products / orders / payments / feedback / user_coupon` 均含 `ROWVERSION` 列，应用层更新时带 `WHERE rowversion = @expected` 判断是否被并发修改
2. **库存行级锁** — `dbo.usp_DeductStock` 使用 `WITH (ROWLOCK, UPDLOCK)` 防止超卖
3. **完整下单事务** — `dbo.usp_PlaceOrder` 封装：库存锁定 → 优惠券锁定 → 积分扣减 → 订单创建 → 支付记录，任一失败自动回滚
4. 详见 `docs/order_transaction_example.sql`

---

## 阶段完结询问

> 阶段1已完成：DDL、迁移脚本、ER 图与 seed 数据已交付。是否进入第2阶段：后端实现？
>
> 回复：**进入第2阶段** / **修改第1阶段** / **停止**
