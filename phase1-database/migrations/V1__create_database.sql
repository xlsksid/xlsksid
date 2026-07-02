-- ============================================================
-- V1: 创建数据库
-- 香辣卤味管理系统 — SQL Server 2022 on Windows
-- ============================================================

IF DB_ID('SpicyBraiseDB') IS NULL
BEGIN
    CREATE DATABASE SpicyBraiseDB
    COLLATE Chinese_PRC_CI_AS;
END
GO

USE SpicyBraiseDB;
GO

ALTER DATABASE SpicyBraiseDB SET RECOVERY FULL;
ALTER DATABASE SpicyBraiseDB SET READ_COMMITTED_SNAPSHOT ON;
GO

PRINT N'数据库 SpicyBraiseDB 创建完成';
GO
