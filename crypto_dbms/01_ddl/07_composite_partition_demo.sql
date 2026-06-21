-- ============================================================
-- FILE: 07_composite_partition_demo.sql
-- DESC: Demonstrates LIST-RANGE composite partitioning
--       This is a SEPARATE demo table (not part of core schema)
--       Required by the proposal: "A LIST-RANGE composite
--       partition by coin_id and date is demonstrated"
-- RUN : After 06_audit_log.sql
-- ============================================================

-- -------------------------------------------------------
-- DEMO TABLE: TRANSACTIONS_COMPOSITE
--
-- Outer partition: LIST on coin_category (MAJOR / STABLE / ALT)
-- Inner sub-partition: RANGE on txn_timestamp (quarterly)
--
-- Real-world use case: partition large txn tables first by
-- coin type (for coin-specific queries), then by date
-- (for time-range archival and pruning)
-- -------------------------------------------------------
CREATE TABLE transactions_composite (
    txn_id          NUMBER,
    coin_id         NUMBER          NOT NULL,
    coin_category   VARCHAR2(10)    NOT NULL,   -- drives outer LIST partition
    amount          NUMBER(24, 8)   NOT NULL,
    txn_status      VARCHAR2(20)    DEFAULT 'COMPLETED',
    txn_timestamp   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_txn_comp  PRIMARY KEY (txn_id, coin_category, txn_timestamp),
    CONSTRAINT ck_tc_category CHECK (coin_category IN ('MAJOR','STABLE','ALT')),
    CONSTRAINT ck_tc_amount   CHECK (amount > 0)
)
-- -------------------------------------------------------
-- COMPOSITE PARTITIONING: LIST (outer) + RANGE (inner)
-- -------------------------------------------------------
PARTITION BY LIST (coin_category)
SUBPARTITION BY RANGE (txn_timestamp)
SUBPARTITION TEMPLATE (
    SUBPARTITION sub_q1 VALUES LESS THAN (TIMESTAMP '2024-04-01 00:00:00'),
    SUBPARTITION sub_q2 VALUES LESS THAN (TIMESTAMP '2024-07-01 00:00:00'),
    SUBPARTITION sub_q3 VALUES LESS THAN (TIMESTAMP '2024-10-01 00:00:00'),
    SUBPARTITION sub_q4 VALUES LESS THAN (TIMESTAMP '2025-01-01 00:00:00'),
    SUBPARTITION sub_future VALUES LESS THAN (MAXVALUE)
)
(
    PARTITION p_major   VALUES ('MAJOR'),   -- BTC, ETH (high value)
    PARTITION p_stable  VALUES ('STABLE'),  -- USDT, USDC (stable coins)
    PARTITION p_alt     VALUES ('ALT')      -- BNB, SOL, XRP (altcoins)
);

COMMENT ON TABLE transactions_composite IS
    'Demo table for LIST-RANGE composite partitioning - outer LIST on coin_category, inner RANGE on txn_timestamp';

-- -------------------------------------------------------
-- Insert test data across all partition combinations
-- -------------------------------------------------------
INSERT INTO transactions_composite VALUES (1,1,'MAJOR',0.5 ,'COMPLETED', TIMESTAMP '2024-02-10 09:00:00');
INSERT INTO transactions_composite VALUES (2,1,'MAJOR',1.2 ,'COMPLETED', TIMESTAMP '2024-05-20 14:00:00');
INSERT INTO transactions_composite VALUES (3,1,'MAJOR',0.8 ,'COMPLETED', TIMESTAMP '2024-08-15 11:00:00');
INSERT INTO transactions_composite VALUES (4,2,'MAJOR',5.0 ,'COMPLETED', TIMESTAMP '2024-11-05 16:00:00');
INSERT INTO transactions_composite VALUES (5,3,'STABLE',1000,'COMPLETED',TIMESTAMP '2024-01-22 10:00:00');
INSERT INTO transactions_composite VALUES (6,3,'STABLE',500 ,'COMPLETED', TIMESTAMP '2024-06-30 13:00:00');
INSERT INTO transactions_composite VALUES (7,4,'ALT',  12.5 ,'COMPLETED', TIMESTAMP '2024-03-18 08:00:00');
INSERT INTO transactions_composite VALUES (8,5,'ALT',  30.0 ,'COMPLETED', TIMESTAMP '2024-09-09 15:00:00');
INSERT INTO transactions_composite VALUES (9,6,'ALT',  800  ,'COMPLETED', TIMESTAMP '2024-12-01 12:00:00');
COMMIT;

-- -------------------------------------------------------
-- Demo queries: show composite partition pruning
-- -------------------------------------------------------

-- Query 1: Hits only p_major partition, sub_q1 subpartition
SELECT txn_id, coin_id, amount, txn_timestamp
FROM   transactions_composite
WHERE  coin_category = 'MAJOR'
AND    txn_timestamp < TIMESTAMP '2024-04-01 00:00:00';

-- Query 2: Hits only p_stable partition, all subpartitions
SELECT txn_id, coin_id, amount, txn_timestamp
FROM   transactions_composite
WHERE  coin_category = 'STABLE';

-- Verify partition + subpartition metadata
SELECT partition_name, subpartition_name, num_rows
FROM   user_tab_subpartitions
WHERE  table_name = 'TRANSACTIONS_COMPOSITE'
ORDER  BY partition_name, subpartition_name;
