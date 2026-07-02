#!/bin/bash
# ============================================================
# 数据库初始化脚本（Docker 容器内执行）
# 等待 SQL Server 就绪后执行所有迁移 + seed
# ============================================================

echo "Waiting for SQL Server to start..."
for i in {1..30}; do
  /opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" &>/dev/null && break
  echo "  attempt $i/30 ..."
  sleep 3
done

echo "Running migrations..."
for f in /migrations/V*.sql; do
  echo "  $(basename $f)"
  /opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "${MSSQL_SA_PASSWORD}" -C -i "$f"
done

echo "Running seed data..."
/opt/mssql-tools18/bin/sqlcmd -S sqlserver -U sa -P "${MSSQL_SA_PASSWORD}" -C -i /seed/V13__seed_data.sql

echo "Database initialization complete!"
