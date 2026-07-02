# 香辣卤味管理系统 — 阶段4：容器化与 CI/CD

## 文件清单

```
├── docker-compose.yml              # 一键启动：SQL Server + 后端 + 前端
├── init-db.sh                      # 数据库自动初始化（迁移 + seed）
├── .github/workflows/
│   ├── build.yml                   # CI：后端编译测试 + 前端构建
│   └── deploy.yml                  # CD：Docker 镜像构建 → GitHub Container Registry
├── phase2-backend/
│   └── Dockerfile                  # 后端多阶段构建：Maven → JRE
└── phase3-frontend/
    ├── Dockerfile                  # 前端多阶段构建：Vite → Nginx
    └── nginx.conf                  # 静态托管 + API 反代 + 路由 history
```

## Docker Compose 启动

```bash
# 一键启动全部服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止
docker-compose down

# 停止 + 清理数据卷
docker-compose down -v
```

启动后：

| 服务 | 地址 |
|------|------|
| 前端 | http://localhost |
| 后端 API | http://localhost:8080 |
| SQL Server | localhost:1433 (sa / SpicyBraise123!) |

## 架构图

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   frontend   │────▶│   backend    │────▶│  sqlserver   │
│  Nginx :80   │     │ Spring:8080  │     │  MSSQL:1433  │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
                      ┌─────┴─────┐
                      │  db-init   │  ← 仅启动一次
                      │ 迁移+seed  │
                      └───────────┘
```

## 容器说明

| 容器 | 镜像 | 端口 |
|------|------|------|
| `spicybraise-db` | mcr.microsoft.com/mssql/server:2022-latest | 1433 |
| `spicybraise-db-init` | 同上（一次性） | — |
| `spicybraise-backend` | 自构建（Maven多阶段） | 8080 |
| `spicybraise-frontend` | 自构建（Nginx） | 80 |

## GitHub Actions

### build.yml — 代码推送自动触发
- JDK 17 + Maven 编译后端
- SQL Server Service Container 运行测试
- Node 18 + Vite 构建前端

### deploy.yml — git tag `v*` 或手动触发
- 构建后端/前端 Docker 镜像
- 推送到 GitHub Container Registry
- 支持 GHA 缓存加速

## 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `SPRING_DATASOURCE_URL` | jdbc:sqlserver://sqlserver:1433;... | 数据库连接 |
| `SPRING_DATASOURCE_USERNAME` | sa | 数据库用户 |
| `SPRING_DATASOURCE_PASSWORD` | SpicyBraise123! | 数据库密码 |
| `APP_JWT_SECRET` | (Base64) | JWT 签名密钥 |
| `APP_JWT_EXPIRATION_MS` | 86400000 | Token 有效期 |

## 数据库迁移自动化

容器启动时 `db-init` 服务自动：
1. 等待 SQL Server 健康检查通过
2. 按序执行 `phase1-database/migrations/V*.sql`
3. 执行 `phase1-database/seed/V13__seed_data.sql`

## 回滚方案

```bash
# 回退到上一个镜像版本
docker-compose down
export BACKEND_TAG=v1.0.0
docker-compose up -d

# 数据库回滚（恢复到最近备份）
docker exec spicybraise-db /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "SpicyBraise123!" -C \
  -Q "RESTORE DATABASE SpicyBraiseDB FROM DISK='/backups/latest.bak' WITH REPLACE"
```

## 健康检查

所有容器均配置 `healthcheck`：
- **sqlserver**: `sqlcmd -Q "SELECT 1"` / 10s
- **backend**: `wget /api/products` / 30s  
- **frontend**: `wget /` / 30s

---

> 阶段4已完成：Docker + docker-compose + CI/CD 已交付。是否进入第5阶段：部署与文档？
>
> 回复：**进入第5阶段** / **修改第4阶段** / **停止**
