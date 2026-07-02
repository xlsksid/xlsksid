# 香辣卤味管理系统 — 阶段2：Spring Boot 后端

## 技术栈

| 组件 | 版本 |
|------|------|
| Spring Boot | 3.2.5 |
| JDK | 17+ |
| MyBatis-Plus | 3.5.7 |
| SQL Server JDBC | 12.8.1 |
| jjwt | 0.12.5 |
| Lombok | latest |
| HikariCP | (内嵌) |

## 项目结构

```
src/main/java/com/spicybraise/
├── SpicyBraiseApplication.java      # 启动类 (@EnableRetry)
├── config/
│   └── SecurityConfig.java          # Spring Security + CORS + 角色权限
├── security/
│   ├── JwtTokenProvider.java        # JWT 签发/验证
│   ├── JwtAuthenticationFilter.java # 请求拦截, Bearer Token
│   └── UserDetailsServiceImpl.java  # 查 users 表
├── controller/
│   ├── AuthController.java          # POST /api/auth/register, /login
│   ├── ProductController.java       # CRUD /api/products
│   ├── CategoryController.java      # CRUD /api/categories
│   ├── OrderController.java         # POST /api/orders, GET
│   ├── CouponController.java        # 领券/查券
│   ├── PaymentController.java       # 模拟支付
│   ├── FeedbackController.java      # 评价
│   └── GlobalExceptionHandler.java  # 统一异常处理
├── service/
│   ├── AuthService.java             # 注册(bcrypt) + 登录
│   ├── OrderService.java            # ★ 完整下单事务 + 乐观锁重试
│   ├── ProductService.java          # 商品 CRUD
│   ├── CategoryService.java         # 分类 CRUD
│   ├── CouponService.java           # 领券/查券
│   ├── PaymentService.java          # 模拟支付
│   └── FeedbackService.java         # 提交评价
├── mapper/                          # MyBatis-Plus BaseMapper
│   ├── UserMapper.java
│   ├── ProductMapper.java           # + deductStock 原子SQL
│   ├── ...
│   └── UserCouponMapper.java        # + lockCoupon 原子SQL
├── domain/                          # POJO 实体 (@TableName)
│   └── User, Product, Order, ... (10个)
├── dto/request/                     # LoginRequest, RegisterRequest, PlaceOrderRequest
├── dto/response/                    # LoginResponse, OrderResponse
└── common/
    ├── ApiResponse.java             # 统一响应 {code, message, data}
    └── BusinessException.java       # 业务异常

src/main/resources/
└── application.yml                  # 数据源 + JWT 配置
```

## API 端点一览

### 认证（公开）
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/register` | 注册（角色默认 customer） |
| POST | `/api/auth/login` | 登录，返回 JWT |

### 商品/分类（GET 公开，写受限）
| 方法 | 路径 | 权限 |
|------|------|------|
| GET | `/api/products?categoryId=1` | 公开 |
| GET | `/api/products/{id}` | 公开 |
| POST | `/api/products` | ADMIN / STAFF |
| PUT | `/api/products/{id}` | ADMIN / STAFF |
| DELETE | `/api/products/{id}` | ADMIN |
| GET/POST/PUT/DELETE | `/api/categories/**` | 同上 |

### 订单（需登录）
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/orders` | 下单（库存→优惠券→积分→订单） |
| GET | `/api/orders` | 我的订单列表 |
| GET | `/api/orders/{id}` | 订单详情 |

### 支付（需登录）
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/payments/pay/{orderId}` | 模拟支付 |

### 优惠券（需登录）
| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/coupons/templates` | 可用优惠券模板 |
| POST | `/api/coupons/claim/{templateId}` | 领取优惠券 |
| GET | `/api/coupons/my` | 我的优惠券 |

### 评价（需登录）
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/feedback` | 提交评价 |
| GET | `/api/feedback/product/{productId}` | 商品评价列表 |

## 本地运行

### 前置条件
1. JDK 17+
2. Maven 3.8+
3. SQL Server 实例运行（数据库 `SpicyBraiseDB` 已在阶段1创建）

### 启动步骤

```bash
# 1. 进入后端目录
cd phase2-backend

# 2. 确认 application.yml 中的数据库连接串正确
#    → jdbc:sqlserver://localhost\\SQLEXPRESS:1433;databaseName=SpicyBraiseDB;...

# 3. 编译 + 启动
mvn clean spring-boot:run

# 4. 验证
curl http://localhost:8080/api/products
```

### Postman 测试流程

1. 导入 `postman/SpicyBraise.postman_collection.json`
2. 设置 `base_url` 变量为 `http://localhost:8080`
3. 执行流程：
   ```
   ① Login (admin)        → 自动存储 token
   ② List Products         → 查看商品
   ③ Place Order           → 下单
   ④ Simulate Pay          → 支付
   ⑤ My Orders             → 查看订单
   ```

### 测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | test123 | 管理员 |
| staff01 | test123 | 店员 |
| customer01 | test123 | 顾客 |

(注意：数据库中密码哈希为 `$2a$10$EixZaYVK1fsbw1ZfbX3OXe.P0jFGnJvL7mQxGJsNnFbgFq9Y3VPNe`，对应明文 `test123`，需用 BCryptPasswordEncoder 匹配)

## 关键设计决策

### 下单事务流程
```
① 库存行锁扣减 (deductStock SQL: WHERE stock >= qty)
② 优惠券校验 + 原子锁定 (lockCoupon SQL: WHERE status='unused')
③ 积分校验 + 扣减
④ 计算实付 → 建订单 → 明细 → 支付记录
⑤ 消费积分赠送 (1%)
→ 任一失败, @Transactional 自动回滚
→ 乐观锁冲突触发 @Retryable(3次, 200ms退避)
```

### 并发控制
- **库存**: MyBatis `UPDATE ... WHERE stock >= ?` 行级原子操作
- **优惠券**: `UPDATE ... WHERE status='unused'` 原子锁定
- **乐观锁**: @Retryable 处理并发冲突重试
- **事务隔离**: SQL Server READ_COMMITTED_SNAPSHOT（已在阶段1配置）

---

> 阶段2已完成：后端仓库、API 文档与 Postman 已交付。是否进入第3阶段：前端实现？
>
> 回复：**进入第3阶段** / **修改第2阶段** / **停止**
