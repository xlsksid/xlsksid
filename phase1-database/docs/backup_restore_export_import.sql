-- ============================================================
-- 备份 / 恢复 / 导出 / 导入 操作示例
-- 香辣卤味管理系统 — SQL Server
-- ============================================================

-- ============================================================
-- 1. 完整备份 (FULL BACKUP)
-- ============================================================
BACKUP DATABASE SpicyBraiseDB
TO DISK = N'D:\Backups\SpicyBraiseDB_Full_20250120.bak'
WITH
    NAME     = N'SpicyBraiseDB-Full-20250120',
    CHECKSUM,
    COMPRESSION,              -- SQL Server 企业版/标准版2016SP1+ 支持压缩
    STATS    = 10;            -- 每 10% 输出进度
GO

-- ============================================================
-- 2. 差异备份 (DIFFERENTIAL BACKUP) — 基于上次完整备份的增量
-- ============================================================
BACKUP DATABASE SpicyBraiseDB
TO DISK = N'D:\Backups\SpicyBraiseDB_Diff_20250121.bak'
WITH
    DIFFERENTIAL,
    NAME     = N'SpicyBraiseDB-Diff-20250121',
    CHECKSUM,
    COMPRESSION,
    STATS    = 10;
GO

-- ============================================================
-- 3. 事务日志备份 (LOG BACKUP) — 每 15 分钟一次
-- ============================================================
BACKUP LOG SpicyBraiseDB
TO DISK = N'D:\Backups\SpicyBraiseDB_Log_20250121_1200.trn'
WITH
    NAME     = N'SpicyBraiseDB-Log-20250121-1200',
    CHECKSUM,
    COMPRESSION;
GO

-- ============================================================
-- 4. 完整恢复流程
-- ============================================================

-- 步骤 A：将数据库设为单用户模式
ALTER DATABASE SpicyBraiseDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- 步骤 B：从完整备份恢复（NORECOVERY 表示后续还有差异/日志要还原）
RESTORE DATABASE SpicyBraiseDB
FROM DISK = N'D:\Backups\SpicyBraiseDB_Full_20250120.bak'
WITH
    FILE  = 1,
    NORECOVERY,
    STATS = 10;
GO

-- 步骤 C：还原差异备份
RESTORE DATABASE SpicyBraiseDB
FROM DISK = N'D:\Backups\SpicyBraiseDB_Diff_20250121.bak'
WITH
    NORECOVERY,
    STATS = 10;
GO

-- 步骤 D：还原所有日志备份（按时间顺序）
RESTORE LOG SpicyBraiseDB
FROM DISK = N'D:\Backups\SpicyBraiseDB_Log_20250121_1200.trn'
WITH
    NORECOVERY,
    STATS = 10;
GO

-- 步骤 E：恢复完成，数据库可用
RESTORE DATABASE SpicyBraiseDB WITH RECOVERY;
GO

-- 步骤 F：恢复多用户模式
ALTER DATABASE SpicyBraiseDB SET MULTI_USER;
GO


-- ============================================================
-- 5. 导出/导入 — bcp 命令行（需在 cmd/shell 中执行）
-- ============================================================

/*
REM === 导出 users 表到 CSV ===
bcp "SELECT * FROM SpicyBraiseDB.dbo.users" queryout users_export.csv \
    -S localhost -U sa -P "YourPassword" \
    -c -t"," -C 65001          -- -c=字符模式, -t=逗号分隔, -C=UTF-8

REM === 导出全表（含列头） ===
bcp SpicyBraiseDB.dbo.products out products_export.csv \
    -S localhost -U sa -P "YourPassword" \
    -c -t"," -C 65001

REM === 导入 CSV 到临时表（先建 staging 表） ===
bcp SpicyBraiseDB.dbo.products_staging in products_import.csv \
    -S localhost -U sa -P "YourPassword" \
    -c -t"," -C 65001
*/


-- ============================================================
-- 6. 导出/导入 — sqlcmd / sqlpackage（命令行示例）
-- ============================================================

/*
REM === sqlcmd 执行 .sql 脚本 ===
sqlcmd -S localhost -U sa -P "YourPassword" -d SpicyBraiseDB \
       -i "D:\Deploy\migrations\V1__create_database.sql" \
       -o "D:\Logs\deploy_output.log"

REM === sqlpackage 导出 bacpac（包含 schema + data） ===
sqlpackage.exe /Action:Export \
    /SourceServerName:localhost /SourceDatabaseName:SpicyBraiseDB \
    /SourceUser:sa /SourcePassword:"YourPassword" \
    /TargetFile:"D:\Backups\SpicyBraiseDB.bacpac"

REM === sqlpackage 导入 bacpac ===
sqlpackage.exe /Action:Import \
    /TargetServerName:localhost /TargetDatabaseName:SpicyBraiseDB_New \
    /TargetUser:sa /TargetPassword:"YourPassword" \
    /SourceFile:"D:\Backups\SpicyBraiseDB.bacpac"
*/


-- ============================================================
-- 7. 自动化备份作业（SQL Agent — T-SQL 作业步骤）
-- ============================================================

/*
-- 每日完整备份（凌晨 2:00）
USE msdb;
GO
EXEC dbo.sp_add_job @job_name=N'Daily Full Backup - SpicyBraiseDB';

EXEC dbo.sp_add_jobstep @job_name=N'Daily Full Backup - SpicyBraiseDB',
    @step_name=N'Full Backup Step',
    @command=N'
        DECLARE @path NVARCHAR(512) = CONCAT(
            N''D:\Backups\SpicyBraiseDB_Full_`,
            FORMAT(SYSUTCDATETIME(),''yyyyMMdd''), N''.bak'');
        BACKUP DATABASE SpicyBraiseDB TO DISK = @path
        WITH NAME = CONCAT(N''SpicyBraiseDB-Full-'',FORMAT(SYSUTCDATETIME(),''yyyyMMdd'')),
             CHECKSUM, COMPRESSION;
    ';

EXEC dbo.sp_add_schedule @job_name=N'Daily Full Backup - SpicyBraiseDB',
    @name=N'Daily 2AM',
    @freq_type=4, @freq_interval=1, @active_start_time=20000;

EXEC dbo.sp_add_jobserver @job_name=N'Daily Full Backup - SpicyBraiseDB';
GO
*/


-- ============================================================
-- 8. 备份保留策略建议（注释）
-- ============================================================

/*
-- 推荐策略：
--   - 完整备份：每日 1 次，保留 30 天
--   - 差异备份：每 6 小时 1 次，保留 7 天
--   - 日志备份：每 15 分钟 1 次，保留 3 天
--   - 异地备份：每日完整备份同步到 Azure Blob / AWS S3 / 异地 NAS
--   - 定期验证：每月执行一次 RESTORE VERIFYONLY 验证备份完整性
--   - 清理脚本（放到 SQL Agent 作业）：
*/

-- 清理 30 天前的完整备份文件
/*
DECLARE @cmd NVARCHAR(2000) = 'powershell.exe -Command `
    "Get-ChildItem D:\Backups\SpicyBraiseDB_Full_*.bak `
     | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } `
     | Remove-Item -Force"';
EXEC xp_cmdshell @cmd;
*/

PRINT N'备份/恢复/导出/导入演示完成！';
GO
