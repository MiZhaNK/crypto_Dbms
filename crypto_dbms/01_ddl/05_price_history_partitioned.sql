-- ============================================================
-- FILE: 05_price_history_partitioned.sql
-- DESC: PRICE_HISTORY table with INTERVAL (auto) partitioning
--       Difference from TRANSACTIONS: Oracle auto-creates new
--       partitions as data arrives - no manual partition list needed
-- RUN : After 04_transactions_partitioned.sql
-- ============================================================

-- -------------------------------------------------------
-- TABLE: PRICE_HISTORY (INTERVAL partitioned by recorded_at)
--
-- Partitioning strategy:
--   INTERVAL(NUMTOYMINTERVAL(1,'MONTH')) means Oracle
--   automatically creates a new partition for each new month
--   when data is inserted. You only define the first seed partition.
--
-- This is DIFFERENT from TRANSACTIONS which uses manual RANGE.
-- Demo point: show both approaches side by side in presentation.
-- -------------------------------------------------------
CREATE TABLE price_history (
    price_id     NUMBER          DEFAULT seq_price_id.NEXTVAL,
    coin_id      NUMBER          NOT NULL,
    recorded_at  TIMESTAMP       NOT NULL,
    price_usd    NUMBER(18, 8)   NOT NULL,
    volume_24h   NUMBER(24, 2),
    -- Constraints
    CONSTRAINT pk_price_history         PRIMARY KEY (price_id, recorded_at),
    CONSTRAINT fk_ph_coin               FOREIGN KEY (coin_id)
                                            REFERENCES cryptocurrencies(coin_id),
    CONSTRAINT ck_ph_price_positive     CHECK       (price_usd > 0),
    CONSTRAINT ck_ph_volume_positive    CHECK       (volume_24h IS NULL OR volume_24h >= 0)
)
-- -------------------------------------------------------
-- INTERVAL PARTITIONING: auto-creates monthly partitions
-- Only the seed partition (before Jan 2024) is defined manually
-- All subsequent months are created by Oracle automatically
-- -------------------------------------------------------
PARTITION BY RANGE (recorded_at)
INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION ph_seed VALUES LESS THAN (TIMESTAMP '2024-01-01 00:00:00')
);

COMMENT ON TABLE  price_history             IS 'Time-series price snapshots per coin - uses INTERVAL auto-partitioning';
COMMENT ON COLUMN price_history.recorded_at IS 'Partition key - Oracle auto-creates monthly partitions on insert';
COMMENT ON COLUMN price_history.volume_24h  IS '24-hour trading volume in USD at the time of recording';

-- -------------------------------------------------------
-- Indexes (LOCAL = partition-aligned, essential here)
-- -------------------------------------------------------
CREATE INDEX idx_ph_coin_id     ON price_history(coin_id)     LOCAL;
CREATE INDEX idx_ph_recorded_at ON price_history(recorded_at) LOCAL;

-- -------------------------------------------------------
-- Seed price history: insert data spanning multiple months
-- Oracle will auto-create partitions for each new month
-- -------------------------------------------------------
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (1, TIMESTAMP '2024-01-15 10:00:00', 42800.50000000, 28500000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (1, TIMESTAMP '2024-02-15 10:00:00', 51200.00000000, 32100000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (1, TIMESTAMP '2024-03-15 10:00:00', 68500.75000000, 45600000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (1, TIMESTAMP '2024-04-15 10:00:00', 63200.00000000, 39800000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (1, TIMESTAMP '2024-06-15 10:00:00', 65400.25000000, 41200000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (2, TIMESTAMP '2024-01-15 10:00:00',  2250.00000000,  9800000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (2, TIMESTAMP '2024-03-15 10:00:00',  3800.50000000, 14500000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (2, TIMESTAMP '2024-06-15 10:00:00',  3521.75000000, 12300000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (5, TIMESTAMP '2024-01-15 10:00:00',    98.50000000,  1800000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (5, TIMESTAMP '2024-03-15 10:00:00',   185.25000000,  4200000000.00);
INSERT INTO price_history (coin_id, recorded_at, price_usd, volume_24h)
VALUES (5, TIMESTAMP '2024-06-15 10:00:00',   172.48000000,  3500000000.00);
COMMIT;

-- -------------------------------------------------------
-- Verify: Oracle auto-created partitions for each month
-- -------------------------------------------------------
SELECT partition_name, high_value, num_rows
FROM   user_tab_partitions
WHERE  table_name = 'PRICE_HISTORY'
ORDER  BY partition_position;
-- Expected: ph_seed + auto-named partitions for Jan, Feb, Mar, Apr, Jun 2024
