-- ============================================================
-- FILE: 04_transactions_partitioned.sql
-- DESC: TRANSACTIONS table with RANGE partitioning by month
--       Core fact table - most important for the DBA demo
-- RUN : After 03_wallets.sql
-- ============================================================

-- -------------------------------------------------------
-- TABLE: TRANSACTIONS (RANGE partitioned by txn_timestamp)
--
-- Partitioning strategy:
--   - Monthly RANGE partitions from Jan 2024 to Dec 2025
--   - MAXVALUE catch-all partition for future records
--   - Partition pruning demo: query WHERE txn_timestamp
--     between two dates hits ONLY relevant partitions
-- -------------------------------------------------------
CREATE TABLE transactions (
    txn_id          NUMBER          DEFAULT seq_txn_id.NEXTVAL,
    from_wallet_id  NUMBER,                          -- NULL = external deposit
    to_wallet_id    NUMBER          NOT NULL,
    coin_id         NUMBER          NOT NULL,
    amount          NUMBER(24, 8)   NOT NULL,
    fee             NUMBER(24, 8)   DEFAULT 0 NOT NULL,
    txn_status      VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL,
    txn_timestamp   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    notes           VARCHAR2(500),
    -- Constraints
    CONSTRAINT pk_transactions          PRIMARY KEY (txn_id, txn_timestamp),
    CONSTRAINT fk_txn_from_wallet       FOREIGN KEY (from_wallet_id)
                                            REFERENCES wallets(wallet_id),
    CONSTRAINT fk_txn_to_wallet         FOREIGN KEY (to_wallet_id)
                                            REFERENCES wallets(wallet_id),
    CONSTRAINT fk_txn_coin              FOREIGN KEY (coin_id)
                                            REFERENCES cryptocurrencies(coin_id),
    CONSTRAINT ck_txn_amount_positive   CHECK       (amount > 0),
    CONSTRAINT ck_txn_fee_positive      CHECK       (fee >= 0),
    CONSTRAINT ck_txn_status            CHECK       (txn_status IN (
                                            'PENDING','COMPLETED','FAILED','CANCELLED'
                                        )),
    CONSTRAINT ck_txn_wallets_diff      CHECK       (from_wallet_id != to_wallet_id)
)
-- -------------------------------------------------------
-- RANGE PARTITIONING on txn_timestamp (monthly intervals)
-- Each partition holds exactly one month of transactions
-- Enables partition pruning on date-range queries
-- -------------------------------------------------------
PARTITION BY RANGE (txn_timestamp) (
    PARTITION txn_2024_01 VALUES LESS THAN (TIMESTAMP '2024-02-01 00:00:00'),
    PARTITION txn_2024_02 VALUES LESS THAN (TIMESTAMP '2024-03-01 00:00:00'),
    PARTITION txn_2024_03 VALUES LESS THAN (TIMESTAMP '2024-04-01 00:00:00'),
    PARTITION txn_2024_04 VALUES LESS THAN (TIMESTAMP '2024-05-01 00:00:00'),
    PARTITION txn_2024_05 VALUES LESS THAN (TIMESTAMP '2024-06-01 00:00:00'),
    PARTITION txn_2024_06 VALUES LESS THAN (TIMESTAMP '2024-07-01 00:00:00'),
    PARTITION txn_2024_07 VALUES LESS THAN (TIMESTAMP '2024-08-01 00:00:00'),
    PARTITION txn_2024_08 VALUES LESS THAN (TIMESTAMP '2024-09-01 00:00:00'),
    PARTITION txn_2024_09 VALUES LESS THAN (TIMESTAMP '2024-10-01 00:00:00'),
    PARTITION txn_2024_10 VALUES LESS THAN (TIMESTAMP '2024-11-01 00:00:00'),
    PARTITION txn_2024_11 VALUES LESS THAN (TIMESTAMP '2024-12-01 00:00:00'),
    PARTITION txn_2024_12 VALUES LESS THAN (TIMESTAMP '2025-01-01 00:00:00'),
    PARTITION txn_2025_01 VALUES LESS THAN (TIMESTAMP '2025-02-01 00:00:00'),
    PARTITION txn_2025_02 VALUES LESS THAN (TIMESTAMP '2025-03-01 00:00:00'),
    PARTITION txn_2025_03 VALUES LESS THAN (TIMESTAMP '2025-04-01 00:00:00'),
    PARTITION txn_2025_04 VALUES LESS THAN (TIMESTAMP '2025-05-01 00:00:00'),
    PARTITION txn_2025_05 VALUES LESS THAN (TIMESTAMP '2025-06-01 00:00:00'),
    PARTITION txn_2025_06 VALUES LESS THAN (TIMESTAMP '2025-07-01 00:00:00'),
    PARTITION txn_2025_07 VALUES LESS THAN (TIMESTAMP '2025-08-01 00:00:00'),
    PARTITION txn_2025_08 VALUES LESS THAN (TIMESTAMP '2025-09-01 00:00:00'),
    PARTITION txn_2025_09 VALUES LESS THAN (TIMESTAMP '2025-10-01 00:00:00'),
    PARTITION txn_2025_10 VALUES LESS THAN (TIMESTAMP '2025-11-01 00:00:00'),
    PARTITION txn_2025_11 VALUES LESS THAN (TIMESTAMP '2025-12-01 00:00:00'),
    PARTITION txn_2025_12 VALUES LESS THAN (TIMESTAMP '2026-01-01 00:00:00'),
    PARTITION txn_future   VALUES LESS THAN (MAXVALUE)
);

COMMENT ON TABLE  transactions               IS 'Core fact table: all cryptocurrency fund movements';
COMMENT ON COLUMN transactions.from_wallet_id IS 'NULL indicates an external deposit (no source wallet)';
COMMENT ON COLUMN transactions.fee           IS 'Network/platform fee deducted from sender';
COMMENT ON COLUMN transactions.txn_timestamp IS 'Partition key - do NOT omit in WHERE clauses';

-- -------------------------------------------------------
-- Indexes: critical for query performance
-- Always index FK columns in partitioned tables
-- -------------------------------------------------------
CREATE INDEX idx_txn_from_wallet  ON transactions(from_wallet_id)  LOCAL;
CREATE INDEX idx_txn_to_wallet    ON transactions(to_wallet_id)    LOCAL;
CREATE INDEX idx_txn_coin_id      ON transactions(coin_id)         LOCAL;
CREATE INDEX idx_txn_status       ON transactions(txn_status)      LOCAL;
CREATE INDEX idx_txn_timestamp    ON transactions(txn_timestamp)   LOCAL;

-- LOCAL = partition-aligned indexes (required for partition pruning to work)

-- -------------------------------------------------------
-- Verify: check partition metadata
-- -------------------------------------------------------
SELECT partition_name, high_value, num_rows
FROM   user_tab_partitions
WHERE  table_name = 'TRANSACTIONS'
ORDER  BY partition_position;
