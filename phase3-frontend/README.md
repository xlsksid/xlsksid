# 香辣卤味管理系统 — 阶段3：React 前端

## 技术栈

| 组件 | 版本 |
|------|------|
| React | 18.3 |
| TypeScript | 5.4 |
| Vite | 5.2 |
| Ant Design | 5.17 |
| Redux Toolkit | 2.2 |
| React Router | 6.23 |
| Axios | 1.7 |

## 项目结构

```
src/
├── main.tsx                    # 入口：Redux Provider + Router + Antd ConfigProvider
├── App.tsx                     # 路由表（公开/顾客/管理员三级）
├── api/
│   ├── axios.ts                # Axios 实例：自动 Bearer Token + 401 跳登录
│   ├── authApi.ts              # login / register
│   ├── productApi.ts           # products + categories CRUD
│   ├── orderApi.ts             # placeOrder / myOrders / simulatePay
│   ├── couponApi.ts            # templates / claim / my
│   └── feedbackApi.ts          # submit / product reviews
├── store/
│   ├── index.ts                # configureStore
│   ├── authSlice.ts            # JWT token + username + role（localStorage 持久化）
│   └── cartSlice.ts            # 购物车（localStorage 持久化）
├── types/index.ts              # User, Product, Order, Coupon, etc.
├── components/
│   ├── AppLayout.tsx           # Header 导航 + 购物车角标 + 用户下拉菜单
│   └── ProtectedRoute.tsx      # 角色路由守卫
└── pages/
    ├── LoginPage.tsx           # 登录/注册 Tab
    ├── HomePage.tsx            # 商品卡片网格 + 分类筛选 + 辣度标签
    ├── ProductDetailPage.tsx   # 商品详情 + 加购 + 评价列表
    ├── CartPage.tsx            # 购物车管理（改数量/删除/清空）
    ├── CheckoutPage.tsx        # 下单：选优惠券 + 积分 + 模拟支付
    ├── OrdersPage.tsx          # 我的订单列表
    ├── CouponsPage.tsx         # 可用券 + 领券 + 我的券
    └── admin/
        ├── ProductManagePage.tsx  # 商品 CRUD 表格 + Modal 表单
        ├── CategoryManagePage.tsx # 分类列表
        └── CouponManagePage.tsx   # 优惠券模板列表
```

## 路由表

| 路径 | 页面 | 权限 |
|------|------|------|
| `/login` | LoginPage | 公开 |
| `/` | HomePage（商品列表） | 公开 |
| `/products/:id` | ProductDetailPage | 公开 |
| `/cart` | CartPage | customer |
| `/checkout` | CheckoutPage | customer |
| `/orders` | OrdersPage | customer |
| `/coupons` | CouponsPage | customer |
| `/admin/products` | ProductManagePage | admin/staff |
| `/admin/categories` | CategoryManagePage | admin/staff |
| `/admin/coupons` | CouponManagePage | admin/staff |

## 本地运行

### 前置条件
- Node.js 18+
- 后端已启动（`phase2-backend` 运行在 `localhost:8080`）

### 启动步骤

```bash
cd phase3-frontend
npm install
npm run dev
# → http://localhost:5173
```

### Vite 代理

`vite.config.ts` 已配置 `/api` → `http://localhost:8080`，前端无需处理跨域。

### 测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | test123 | 管理员（可管理商品/分类/券） |
| staff01 | test123 | 店员（同上） |
| customer01 | test123 | 顾客（浏览/下单/领券） |

### 完整流程测试

```
1. npm run dev → 打开 http://localhost:5173
2. 点击右上角 Login → 选择 Login Tab
3. 输入 customer01 / test123 → 登录
4. 浏览首页商品卡片 → 点击商品进入详情
5. 设置数量 → Add to Cart
6. 导航栏购物车图标 → 进入 CartPage
7. Proceed to Checkout → 选优惠券/积分 → Place Order
8. Simulate Payment → 完成支付
9. My Orders 查看订单
```

## 关键设计

- **JWT 存储**: `localStorage`，Axios 拦截器自动附加 `Authorization: Bearer`
- **401 处理**: 自动清除存储并跳转登录页
- **购物车持久化**: Redux + localStorage，刷新不丢
- **角色路由守卫**: `ProtectedRoute` 组件检查 token + role
- **Vite 代理**: 开发环境 `/api → localhost:8080`，无跨域问题
- **移动端响应式**: Ant Design Grid `xs/sm/md/lg` 断点适配

---

> 阶段3已完成：前端代码与演示页面已交付。是否进入第4阶段：容器化与 CI/CD？
>
> 回复：**进入第4阶段** / **修改第3阶段** / **停止**
