-- ============================================================================
--       EDUPULSE CLOUD DATABASE HEALTH CHECK & DIAGNOSTIC SUITE (DBEAVER)
-- ============================================================================
-- Target Host : reseau.proxy.rlwy.net:32379
-- Database    : railway (MySQL 9.4.0)
-- Instructions: Open in DBeaver, select the 'railway' connection, and run (Alt+X)
-- ============================================================================

USE railway;

-- ----------------------------------------------------------------------------
-- 1. SERVER & CONNECTION HEALTH METRICS
-- ----------------------------------------------------------------------------
SELECT 
    VERSION() AS `MySQL_Version`,
    DATABASE() AS `Active_Database`,
    USER() AS `Connected_User`,
    @@global.time_zone AS `Server_Timezone`,
    @@character_set_database AS `DB_Charset`,
    @@collation_database AS `DB_Collation`,
    ROUND(VARIABLE_VALUE / 86400, 2) AS `Uptime_Days`
FROM performance_schema.global_status 
WHERE VARIABLE_NAME = 'Uptime';

-- ----------------------------------------------------------------------------
-- 2. CONNECTION POOL & THREAD CAPACITY
-- ----------------------------------------------------------------------------
SELECT 
    VARIABLE_NAME AS `Metric`,
    VARIABLE_VALUE AS `Value`
FROM performance_schema.global_status 
WHERE VARIABLE_NAME IN (
    'Threads_connected', 
    'Threads_running', 
    'Max_used_connections', 
    'Connections', 
    'Aborted_connects', 
    'Slow_queries'
);

-- ----------------------------------------------------------------------------
-- 3. INNODB BUFFER POOL & MEMORY CACHE EFFICIENCY
-- ----------------------------------------------------------------------------
SELECT 
    req.VARIABLE_VALUE AS `Buffer_Read_Requests`,
    rds.VARIABLE_VALUE AS `Disk_Reads`,
    ROUND((1.0 - (rds.VARIABLE_VALUE / req.VARIABLE_VALUE)) * 100, 2) AS `Cache_Hit_Ratio_Pct`
FROM 
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_read_requests') req,
    (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Innodb_buffer_pool_reads') rds;

-- ----------------------------------------------------------------------------
-- 4. TABLE STORAGE FOOTPRINT (SORTED BY TOTAL DISK USAGE)
-- ----------------------------------------------------------------------------
SELECT 
    table_name AS `Table`,
    table_rows AS `Approx_Rows`,
    ROUND(((data_length + index_length) / 1024 / 1024), 3) AS `Total_MB`,
    ROUND((data_length / 1024 / 1024), 3) AS `Data_MB`,
    ROUND((index_length / 1024 / 1024), 3) AS `Index_MB`,
    ROUND((data_free / 1024 / 1024), 3) AS `Free_MB`
FROM information_schema.tables 
WHERE table_schema = 'railway' 
ORDER BY (data_length + index_length) DESC;

-- ----------------------------------------------------------------------------
-- 5. EXACT RECORD COUNTS FOR ALL CORE APPLICATION TABLES
-- ----------------------------------------------------------------------------
SELECT 'users' AS `Table`, COUNT(*) AS `Total_Rows` FROM users
UNION ALL
SELECT 'stu' AS `Table`, COUNT(*) AS `Total_Rows` FROM stu
UNION ALL
SELECT 'staff' AS `Table`, COUNT(*) AS `Total_Rows` FROM staff
UNION ALL
SELECT 'departments' AS `Table`, COUNT(*) AS `Total_Rows` FROM departments
UNION ALL
SELECT 'colleges' AS `Table`, COUNT(*) AS `Total_Rows` FROM colleges
UNION ALL
SELECT 'posts' AS `Table`, COUNT(*) AS `Total_Rows` FROM posts
UNION ALL
SELECT 'post_likes' AS `Table`, COUNT(*) AS `Total_Rows` FROM post_likes
UNION ALL
SELECT 'post_shares' AS `Table`, COUNT(*) AS `Total_Rows` FROM post_shares
UNION ALL
SELECT 'bookmarks' AS `Table`, COUNT(*) AS `Total_Rows` FROM bookmarks
UNION ALL
SELECT 'comments' AS `Table`, COUNT(*) AS `Total_Rows` FROM comments
UNION ALL
SELECT 'branch_notices' AS `Table`, COUNT(*) AS `Total_Rows` FROM branch_notices
UNION ALL
SELECT 'event_reels' AS `Table`, COUNT(*) AS `Total_Rows` FROM event_reels
UNION ALL
SELECT 'events_hub' AS `Table`, COUNT(*) AS `Total_Rows` FROM events_hub
UNION ALL
SELECT 'student_activities' AS `Table`, COUNT(*) AS `Total_Rows` FROM student_activities
UNION ALL
SELECT 'certifications' AS `Table`, COUNT(*) AS `Total_Rows` FROM certifications
UNION ALL
SELECT 'notifications' AS `Table`, COUNT(*) AS `Total_Rows` FROM notifications
UNION ALL
SELECT 'device_tokens' AS `Table`, COUNT(*) AS `Total_Rows` FROM device_tokens
UNION ALL
SELECT 'password_reset_otps' AS `Table`, COUNT(*) AS `Total_Rows` FROM password_reset_otps;

-- ----------------------------------------------------------------------------
-- 6. REFERENTIAL INTEGRITY & ORPHAN RECORDS AUDIT
-- ----------------------------------------------------------------------------
SELECT 
    'comments -> posts' AS `Relationship`,
    COUNT(*) AS `Orphan_Records`
FROM comments c
LEFT JOIN posts p ON c.post_id = p.id
WHERE c.post_id IS NOT NULL AND p.id IS NULL

UNION ALL

SELECT 
    'post_likes -> posts' AS `Relationship`,
    COUNT(*) AS `Orphan_Records`
FROM post_likes pl
LEFT JOIN posts p ON pl.post_id = p.id
WHERE pl.post_id IS NOT NULL AND p.id IS NULL

UNION ALL

SELECT 
    'post_shares -> posts' AS `Relationship`,
    COUNT(*) AS `Orphan_Records`
FROM post_shares ps
LEFT JOIN posts p ON ps.post_id = p.id
WHERE ps.post_id IS NOT NULL AND p.id IS NULL

UNION ALL

SELECT 
    'bookmarks -> posts' AS `Relationship`,
    COUNT(*) AS `Orphan_Records`
FROM bookmarks b
LEFT JOIN posts p ON b.post_id = p.id
WHERE b.post_id IS NOT NULL AND p.id IS NULL;

-- ----------------------------------------------------------------------------
-- 7. USER AUTHENTICATION & PASSWORD ENCRYPTION HEALTH
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(*) AS `Total_Accounts`,
    SUM(CASE WHEN password LIKE 'ENC:%' THEN 1 ELSE 0 END) AS `AES_Encrypted_ENC`,
    SUM(CASE WHEN password LIKE '$2a$%' OR password LIKE '$2b$%' THEN 1 ELSE 0 END) AS `BCrypt_Hashed`,
    SUM(CASE WHEN password IS NULL THEN 1 ELSE 0 END) AS `Null_Pass_Unregistered_Roster`,
    SUM(CASE WHEN is_registered = 1 THEN 1 ELSE 0 END) AS `Active_Registered`,
    SUM(CASE WHEN is_registered = 0 OR is_registered IS NULL THEN 1 ELSE 0 END) AS `Pending_In_Roster`
FROM users;

-- ----------------------------------------------------------------------------
-- 8. DUPLICATE ROLL NUMBER INTEGRITY CHECK
-- ----------------------------------------------------------------------------
SELECT 
    roll_number, 
    COUNT(*) AS `Occurrences`
FROM users 
WHERE roll_number IS NOT NULL AND roll_number != ''
GROUP BY roll_number 
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 9. ACTIVE DATABASE ENGINES & CHARSETS
-- ----------------------------------------------------------------------------
SELECT 
    table_name AS `Table`,
    engine AS `Engine`,
    table_collation AS `Collation`
FROM information_schema.tables 
WHERE table_schema = 'railway';
