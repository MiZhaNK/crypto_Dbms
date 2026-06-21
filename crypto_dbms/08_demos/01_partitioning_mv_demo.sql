-- ==============================================================================
-- DELIVERABLE 4: PARTITIONING & MATERIALIZED VIEW DEMO
-- Description: Demonstrates partition pruning and querying MVs.
-- ==============================================================================

SET SERVEROUTPUT ON;

-- 1. Partition Pruning Demonstration
-- The TRANSACTIONS table uses RANGE partitioning on transaction_date.
-- When querying a specific month, Oracle will automatically 'prune' 
-- (ignore) all other partitions, dramatically speeding up the query.

/*
-- To view the execution plan demonstrating partition pruning in SQL Developer:
-- Highlight the query below and press F10 (Explain Plan)
-- You should see "PARTITION RANGE SINGLE" in the execution plan.

EXPLAIN PLAN FOR
SELECT * 
FROM TRANSACTIONS
WHERE transaction_date BETWEEN TO_DATE('2024-01-01', 'YYYY-MM-DD') 
                           AND TO_DATE('2024-01-31', 'YYYY-MM-DD');

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
*/

-- 2. Materialized View Query Demonstration
-- Materialized views store pre-computed results. Querying them is instantaneous.

/*
-- Fast retrieval of wallet balances without joining or grouping millions of rows:
SELECT * FROM WALLET_BALANCE_SUMMARY;

-- Fast retrieval of transaction trends:
SELECT * FROM MONTHLY_TXN_TRENDS;

-- Fast retrieval of top activity wallets:
SELECT * FROM TOP_SENDERS_RECEIVERS WHERE ROWNUM <= 5;
*/

BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('PARTITIONING & MATERIALIZED VIEW DEMO READY');
    DBMS_OUTPUT.PUT_LINE('Note: Execute the EXPLAIN PLAN queries manually in ');
    DBMS_OUTPUT.PUT_LINE('SQL Developer to visualize partition pruning behavior.');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/
