-- ============================================================
-- FILE: 00_RUN_ALL_DDL.sql
-- DESC: Master script - runs all DDL files in correct order
--       Run THIS file instead of running files individually
-- CONN: Connect as CRYPTO_ADMIN before running
-- HOW : In VS Code, open this file, make sure CRYPTO_PROJECT
--       connection is active, press F5 or right-click → Run
-- ============================================================

-- Safety check: confirm you are connected as crypto_admin
SELECT SYS_CONTEXT('USERENV','SESSION_USER') AS current_user FROM DUAL;
-- Must show: CRYPTO_ADMIN

PROMPT ====================================================
PROMPT  Step 1: Creating all sequences
PROMPT ====================================================
@01_sequences.sql

PROMPT ====================================================
PROMPT  Step 2: Creating USERS and CRYPTOCURRENCIES tables
PROMPT ====================================================
@02_base_tables.sql

PROMPT ====================================================
PROMPT  Step 3: Creating WALLETS table
PROMPT ====================================================
@03_wallets.sql

PROMPT ====================================================
PROMPT  Step 4: Creating TRANSACTIONS (RANGE partitioned)
PROMPT ====================================================
@04_transactions_partitioned.sql

PROMPT ====================================================
PROMPT  Step 5: Creating PRICE_HISTORY (INTERVAL partitioned)
PROMPT ====================================================
@05_price_history_partitioned.sql

PROMPT ====================================================
PROMPT  Step 6: Creating AUDIT_LOG table
PROMPT ====================================================
@06_audit_log.sql

PROMPT ====================================================
PROMPT  Step 7: Composite partition demo table
PROMPT ====================================================
@07_composite_partition_demo.sql

PROMPT ====================================================
PROMPT  COMPLETE - Final verification
PROMPT ====================================================

-- Show all tables with partition status
SELECT
    t.table_name,
    t.partitioned,
    t.num_rows,
    COUNT(p.partition_name) AS partition_count
FROM user_tables t
LEFT JOIN user_tab_partitions p ON p.table_name = t.table_name
WHERE t.table_name IN (
    'USERS','CRYPTOCURRENCIES','WALLETS',
    'TRANSACTIONS','PRICE_HISTORY','AUDIT_LOG',
    'TRANSACTIONS_COMPOSITE'
)
GROUP BY t.table_name, t.partitioned, t.num_rows
ORDER BY t.table_name;

-- Show all sequences
SELECT sequence_name FROM user_sequences ORDER BY sequence_name;

-- Show all indexes
SELECT index_name, table_name, partitioned, status
FROM   user_indexes
WHERE  table_name IN ('WALLETS','TRANSACTIONS','PRICE_HISTORY','AUDIT_LOG')
ORDER  BY table_name, index_name;
