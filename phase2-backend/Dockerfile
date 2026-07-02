# ============================================================
# 后端多阶段 Dockerfile — Spring Boot 3.2 + JDK 17
# ============================================================

# ---- Stage 1: Build ----
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /build

# 复制 Maven Wrapper 和配置（利用 Docker 缓存层）
COPY .mvn/ .mvn/
COPY mvnw.cmd mvnw ./
COPY pom.xml ./

# 下载依赖（缓存层，源码未变时复用）
RUN chmod +x mvnw && ./mvnw dependency:resolve -q

# 复制源码
COPY src/ src/

# 编译打包
RUN ./mvnw package -DskipTests -q

# ---- Stage 2: Run ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# 创建非 root 用户
RUN addgroup -S spicy && adduser -S spicy -G spicy
USER spicy

# 复制 jar
COPY --from=builder /build/target/*.jar app.jar

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
