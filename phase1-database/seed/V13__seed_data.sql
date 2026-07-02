-- ============================================================
-- V13: Seed 数据 — 每表 5 条初始化数据
-- 密码哈希均为 "password123" 的 bcrypt 哈希（展示用）
-- ============================================================

USE SpicyBraiseDB;
GO

SET IDENTITY_INSERT dbo.users ON;
INSERT INTO dbo.users (id, username, password_hash, email, phone, role, avatar, balance, points)
VALUES
(1, N'admin',     N'$2a$10$dummy_hash_admin_placeholder_12345', N'admin@spicy.com',     N'13800000001', 'admin',    NULL, 0.00, 0),
(2, N'staff01',   N'$2a$10$dummy_hash_staff_placeholder_12345', N'staff01@spicy.com',   N'13800000002', 'staff',    NULL, 0.00, 0),
(3, N'staff02',   N'$2a$10$dummy_hash_staff_placeholder_67890', N'staff02@spicy.com',   N'13800000003', 'staff',    NULL, 0.00, 0),
(4, N'customer01',N'$2a$10$dummy_hash_cust1_placeholder_12345', N'cust01@example.com',  N'13900000001', 'customer', NULL, 200.00, 1500),
(5, N'customer02',N'$2a$10$dummy_hash_cust2_placeholder_67890', N'cust02@example.com',  N'13900000002', 'customer', NULL, 50.00,  300);
SET IDENTITY_INSERT dbo.users OFF;
GO

SET IDENTITY_INSERT dbo.categories ON;
INSERT INTO dbo.categories (id, name, description, sort_order, image_url)
VALUES
(1, N'卤味荤菜', N'鸭脖、鸭翅、鸡爪等肉类卤制品', 1, N'/images/cat-meat.png'),
(2, N'卤味素菜', N'卤藕片、卤豆干、卤海带等素卤', 2, N'/images/cat-veg.png'),
(3, N'凉拌系列', N'凉拌黄瓜、凉拌木耳等', 3, N'/images/cat-salad.png'),
(4, N'套餐组合', N'荤素搭配套餐', 4, N'/images/cat-combo.png'),
(5, N'饮品', N'酸梅汤、绿豆汤等解辣饮品', 5, N'/images/cat-drink.png');
SET IDENTITY_INSERT dbo.categories OFF;
GO

SET IDENTITY_INSERT dbo.products ON;
INSERT INTO dbo.products (id, name, description, price, cost_price, stock, unit, image_url, category_id, spiciness, is_available)
VALUES
(1,  N'招牌辣鸭脖', N'精选鸭脖，秘制卤料，香辣入味', 18.00, 8.00, 500, N'份', N'/images/prod-duck-neck.png', 1, 4, 1),
(2,  N'香辣鸭翅',   N'卤制鸭翅中段，麻辣鲜香', 15.00, 6.00, 300, N'份', N'/images/prod-duck-wing.png', 1, 3, 1),
(3,  N'卤鸡爪',     N'软糯Q弹卤鸡爪，回味无穷', 12.00, 5.00, 400, N'份', N'/images/prod-chicken-feet.png', 1, 2, 1),
(4,  N'卤藕片',     N'脆爽卤藕，微辣开胃', 8.00,  3.00, 200, N'份', N'/images/prod-lotus-root.png', 2, 2, 1),
(5,  N'卤豆干',     N'五香卤豆干，口感扎实', 6.00,  2.50, 350, N'份', N'/images/prod-tofu.png', 2, 1, 1),
(6,  N'凉拌黄瓜',   N'蒜泥凉拌，清爽解腻', 8.00,  3.00, 150, N'份', N'/images/prod-cucumber.png', 3, 0, 1),
(7,  N'双人卤味套餐', N'鸭脖+鸭翅+藕片+豆干+饮品', 45.00, 22.00, 100, N'套', N'/images/prod-combo2.png', 4, 3, 1),
(8,  N'酸梅汤',     N'冰镇酸梅汤，解辣神器', 5.00, 1.50, 600, N'杯', N'/images/prod-drink.png', 5, 0, 1);
SET IDENTITY_INSERT dbo.products OFF;
GO

SET IDENTITY_INSERT dbo.orders ON;
INSERT INTO dbo.orders (id, user_id, order_no, total_amount, discount_amount, points_deducted, points_amount, actual_amount, status, remark)
VALUES
(1, 4, N'20250115120000001', 39.00, 5.00,  0,   0.00,  34.00, 'completed',  N'微辣口味'),
(2, 4, N'20250116130000002', 18.00, 0.00,  100, 1.00,  17.00, 'completed',  NULL),
(3, 5, N'20250117140000003', 60.00, 10.00, 0,   0.00,  50.00, 'delivering', N'加辣'),
(4, 5, N'20250118150000004', 12.00, 0.00,  0,   0.00,  12.00, 'cancelled',  NULL),
(5, 4, N'20250119160000005', 45.00, 0.00,  0,   0.00,  45.00, 'pending',    N'双人套餐');
SET IDENTITY_INSERT dbo.orders OFF;
GO

SET IDENTITY_INSERT dbo.order_details ON;
INSERT INTO dbo.order_details (id, order_id, product_id, quantity, unit_price, subtotal)
VALUES
(1, 1, 1, 1, 18.00, 18.00),
(2, 1, 3, 1, 12.00, 12.00),
(3, 1, 5, 1, 6.00,  6.00),
(4, 2, 1, 1, 18.00, 18.00),
(5, 3, 1, 1, 18.00, 18.00),
(6, 3, 2, 1, 15.00, 15.00),
(7, 3, 4, 2, 8.00,  16.00),
(8, 5, 7, 1, 45.00, 45.00);
SET IDENTITY_INSERT dbo.order_details OFF;
GO

SET IDENTITY_INSERT dbo.payments ON;
INSERT INTO dbo.payments (id, order_id, user_id, amount, payment_method, payment_status, transaction_id, paid_at)
VALUES
(1, 1, 4, 34.00, 'wechat',  'success', N'TXN20250115120001', '2025-01-15T12:05:00'),
(2, 2, 4, 17.00, 'alipay',  'success', N'TXN20250116130002', '2025-01-16T13:05:00'),
(3, 3, 5, 50.00, 'wechat',  'success', N'TXN20250117140003', '2025-01-17T14:05:00'),
(4, 4, 5, 12.00, 'wechat',  'refunded', N'TXN20250118150004', '2025-01-18T15:05:00'),
(5, 5, 4, 45.00, 'stored', 'pending',  NULL, NULL);
SET IDENTITY_INSERT dbo.payments OFF;
GO

SET IDENTITY_INSERT dbo.feedback ON;
INSERT INTO dbo.feedback (id, user_id, product_id, order_id, rating, comment)
VALUES
(1, 4, 1, 1, 5, N'鸭脖非常入味，辣度刚好！'),
(2, 4, 3, 1, 4, N'鸡爪很软糯，下次还会买'),
(3, 5, 1, 3, 5, N'超级好吃，加辣的够劲'),
(4, 5, 2, 3, 4, N'鸭翅也不错，分量足'),
(5, 5, 4, 3, 3, N'藕片有点偏咸');
SET IDENTITY_INSERT dbo.feedback OFF;
GO

SET IDENTITY_INSERT dbo.points_record ON;
INSERT INTO dbo.points_record (id, user_id, points, type, description, order_id)
VALUES
(1, 4,  390,  'earn',  N'订单消费赠送积分', 1),
(2, 4,  180,  'earn',  N'订单消费赠送积分', 2),
(3, 4, -100,  'spend', N'抵扣现金 1.00 元', 2),
(4, 5,  600,  'earn',  N'订单消费赠送积分', 3),
(5, 4,  200,  'earn',  N'签到赠送积分', NULL);
SET IDENTITY_INSERT dbo.points_record OFF;
GO

SET IDENTITY_INSERT dbo.coupon_template ON;
INSERT INTO dbo.coupon_template (id, name, type, discount_rate, reduction_amount, min_order_amount, valid_days, total_quantity, issued_count, is_active)
VALUES
(1, N'新用户9折券',    'discount',  0.90, NULL,  0.00,   30, 1000, 56,  1),
(2, N'满50减10',       'reduction', NULL,  10.00, 50.00,  30, 500,  120, 1),
(3, N'满100减25',      'reduction', NULL,  25.00, 100.00, 30, 200,  30,  1),
(4, N'会员8折券',      'discount',  0.80, NULL,  0.00,   15, 100,  10,  1),
(5, N'下单满30减5',    'reduction', NULL,  5.00,  30.00,  7,  1000, 300, 1);
SET IDENTITY_INSERT dbo.coupon_template OFF;
GO

SET IDENTITY_INSERT dbo.user_coupon ON;
INSERT INTO dbo.user_coupon (id, user_id, coupon_template_id, status, used_order_id, valid_from, valid_to, used_at)
VALUES
(1, 4, 1, 'used',    1, '2025-01-01T00:00:00', '2025-01-31T23:59:59', '2025-01-15T12:00:00'),
(2, 4, 2, 'unused', NULL, '2025-01-10T00:00:00', '2025-02-09T23:59:59', NULL),
(3, 5, 1, 'used',    3, '2025-01-05T00:00:00', '2025-02-04T23:59:59', '2025-01-17T14:00:00'),
(4, 5, 3, 'unused', NULL, '2025-01-15T00:00:00', '2025-02-14T23:59:59', NULL),
(5, 5, 5, 'expired', NULL, '2025-01-01T00:00:00', '2025-01-08T23:59:59', NULL);
SET IDENTITY_INSERT dbo.user_coupon OFF;
GO

-- 重置自增起始值
DBCC CHECKIDENT ('users',            RESEED, 1000);
DBCC CHECKIDENT ('categories',       RESEED, 100);
DBCC CHECKIDENT ('products',         RESEED, 1000);
DBCC CHECKIDENT ('orders',           RESEED, 1000);
DBCC CHECKIDENT ('order_details',    RESEED, 1000);
DBCC CHECKIDENT ('payments',         RESEED, 1000);
DBCC CHECKIDENT ('feedback',         RESEED, 1000);
DBCC CHECKIDENT ('points_record',    RESEED, 1000);
DBCC CHECKIDENT ('coupon_template',  RESEED, 100);
DBCC CHECKIDENT ('user_coupon',      RESEED, 1000);
GO

PRINT N'Seed 数据导入完成！';
GO
