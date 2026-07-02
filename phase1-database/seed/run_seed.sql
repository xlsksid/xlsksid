SET QUOTED_IDENTIFIER ON;
GO

USE SpicyBraiseDB;
GO

-- 清理旧 seed 数据（从子表到父表）
DELETE FROM dbo.user_coupon;
DELETE FROM dbo.feedback;
DELETE FROM dbo.points_record;
DELETE FROM dbo.payments;
DELETE FROM dbo.order_details;
DELETE FROM dbo.orders;
DELETE FROM dbo.products;
DELETE FROM dbo.categories;
DELETE FROM dbo.coupon_template;
DELETE FROM dbo.users;
GO

-- ============================================================
-- users (5 rows)
-- ============================================================
SET IDENTITY_INSERT dbo.users ON;
INSERT INTO dbo.users (id, username, password_hash, email, phone, role, avatar, balance, points)
VALUES
(1, N'admin',      N'$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0jFGnJvL7mQxGJsNnFbgFq9Y3VPNe', N'admin@spicy.com',    N'13800000001', 'admin',    NULL, 0.00, 0),
(2, N'staff01',    N'$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0jFGnJvL7mQxGJsNnFbgFq9Y3VPNe', N'staff01@spicy.com',  N'13800000002', 'staff',    NULL, 0.00, 0),
(3, N'staff02',    N'$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0jFGnJvL7mQxGJsNnFbgFq9Y3VPNe', N'staff02@spicy.com',  N'13800000003', 'staff',    NULL, 0.00, 0),
(4, N'customer01', N'$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0jFGnJvL7mQxGJsNnFbgFq9Y3VPNe', N'cust01@example.com', N'13900000001', 'customer', NULL, 200.00, 1500),
(5, N'customer02', N'$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0jFGnJvL7mQxGJsNnFbgFq9Y3VPNe', N'cust02@example.com', N'13900000002', 'customer', NULL, 50.00,  300);
SET IDENTITY_INSERT dbo.users OFF;
GO
PRINT N'users seeded';
GO

-- ============================================================
-- categories (5 rows)
-- ============================================================
SET IDENTITY_INSERT dbo.categories ON;
INSERT INTO dbo.categories (id, name, description, sort_order, image_url)
VALUES
(1, N'Luwei Meat',   N'Duck neck, wings, chicken feet', 1, N'/images/cat-meat.png'),
(2, N'Luwei Veggie', N'Lotus root, tofu, seaweed', 2, N'/images/cat-veg.png'),
(3, N'Cold Dishes',  N'Cucumber salad, wood ear salad', 3, N'/images/cat-salad.png'),
(4, N'Combo Meals',  N'Meat + veggie combos', 4, N'/images/cat-combo.png'),
(5, N'Drinks',       N'Sour plum drink, mung bean soup', 5, N'/images/cat-drink.png');
SET IDENTITY_INSERT dbo.categories OFF;
GO
PRINT N'categories seeded';
GO

-- ============================================================
-- products (8 rows)
-- ============================================================
SET IDENTITY_INSERT dbo.products ON;
INSERT INTO dbo.products (id, name, description, price, cost_price, stock, unit, image_url, category_id, spiciness, is_available)
VALUES
(1, N'Spicy Duck Neck',   N'Signature duck neck, secret marinade', 18.00, 8.00, 500, N'portion', N'/images/prod-duck-neck.png', 1, 4, 1),
(2, N'Spicy Duck Wing',   N'Marinated duck wing mid-joint', 15.00, 6.00, 300, N'portion', N'/images/prod-duck-wing.png', 1, 3, 1),
(3, N'Braised Chicken Feet', N'Tender braised chicken feet', 12.00, 5.00, 400, N'portion', N'/images/prod-chicken-feet.png', 1, 2, 1),
(4, N'Braised Lotus Root', N'Crunchy braised lotus root', 8.00,  3.00, 200, N'portion', N'/images/prod-lotus-root.png', 2, 2, 1),
(5, N'Braised Tofu',      N'Five-spice braised tofu', 6.00,  2.50, 350, N'portion', N'/images/prod-tofu.png', 2, 1, 1),
(6, N'Cucumber Salad',    N'Garlic cucumber salad', 8.00,  3.00, 150, N'portion', N'/images/prod-cucumber.png', 3, 0, 1),
(7, N'Duo Combo',         N'Duck neck + wing + lotus + tofu + drink', 45.00, 22.00, 100, N'set', N'/images/prod-combo2.png', 4, 3, 1),
(8, N'Sour Plum Drink',   N'Iced sour plum drink', 5.00, 1.50, 600, N'cup', N'/images/prod-drink.png', 5, 0, 1);
SET IDENTITY_INSERT dbo.products OFF;
GO
PRINT N'products seeded';
GO

-- ============================================================
-- orders (5 rows)
-- ============================================================
SET IDENTITY_INSERT dbo.orders ON;
INSERT INTO dbo.orders (id, user_id, order_no, total_amount, discount_amount, points_deducted, points_amount, actual_amount, status, remark)
VALUES
(1, 4, N'20250115120000001', 39.00, 5.00,  0,   0.00,  34.00, 'completed',  N'Mild spicy'),
(2, 4, N'20250116130000002', 18.00, 0.00,  100, 1.00,  17.00, 'completed',  NULL),
(3, 5, N'20250117140000003', 60.00, 10.00, 0,   0.00,  50.00, 'delivering', N'Extra spicy'),
(4, 5, N'20250118150000004', 12.00, 0.00,  0,   0.00,  12.00, 'cancelled',  NULL),
(5, 4, N'20250119160000005', 45.00, 0.00,  0,   0.00,  45.00, 'pending',    N'Duo combo');
SET IDENTITY_INSERT dbo.orders OFF;
GO
PRINT N'orders seeded';
GO

-- ============================================================
-- order_details
-- ============================================================
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
PRINT N'order_details seeded';
GO

-- ============================================================
-- payments
-- ============================================================
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
PRINT N'payments seeded';
GO

-- ============================================================
-- feedback
-- ============================================================
SET IDENTITY_INSERT dbo.feedback ON;
INSERT INTO dbo.feedback (id, user_id, product_id, order_id, rating, comment)
VALUES
(1, 4, 1, 1, 5, N'Duck neck is amazing, perfect spice level!'),
(2, 4, 3, 1, 4, N'Chicken feet very tender, will buy again'),
(3, 5, 1, 3, 5, N'Super tasty, extra spicy hits the spot'),
(4, 5, 2, 3, 4, N'Duck wings good, generous portion'),
(5, 5, 4, 3, 3, N'Lotus root a bit too salty');
SET IDENTITY_INSERT dbo.feedback OFF;
GO
PRINT N'feedback seeded';
GO

-- ============================================================
-- points_record
-- ============================================================
SET IDENTITY_INSERT dbo.points_record ON;
INSERT INTO dbo.points_record (id, user_id, points, type, description, order_id)
VALUES
(1, 4,  390,  'earn',  N'Points earned from order', 1),
(2, 4,  180,  'earn',  N'Points earned from order', 2),
(3, 4, -100,  'spend', N'Redeemed 1.00 yuan', 2),
(4, 5,  600,  'earn',  N'Points earned from order', 3),
(5, 4,  200,  'earn',  N'Daily check-in bonus', NULL);
SET IDENTITY_INSERT dbo.points_record OFF;
GO
PRINT N'points_record seeded';
GO

-- ============================================================
-- coupon_template
-- ============================================================
SET IDENTITY_INSERT dbo.coupon_template ON;
INSERT INTO dbo.coupon_template (id, name, type, discount_rate, reduction_amount, min_order_amount, valid_days, total_quantity, issued_count, is_active)
VALUES
(1, N'New User 10% Off', 'discount',  0.90, NULL,  0.00,   30, 1000, 56,  1),
(2, N'50 Minus 10',      'reduction', NULL,  10.00, 50.00,  30, 500,  120, 1),
(3, N'100 Minus 25',     'reduction', NULL,  25.00, 100.00, 30, 200,  30,  1),
(4, N'VIP 20% Off',      'discount',  0.80, NULL,  0.00,   15, 100,  10,  1),
(5, N'30 Minus 5',       'reduction', NULL,  5.00,  30.00,  7,  1000, 300, 1);
SET IDENTITY_INSERT dbo.coupon_template OFF;
GO
PRINT N'coupon_template seeded';
GO

-- ============================================================
-- user_coupon
-- ============================================================
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
PRINT N'user_coupon seeded';
GO

-- 重置自增
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

PRINT N'=== ALL SEED DATA IMPORTED ===';
GO
