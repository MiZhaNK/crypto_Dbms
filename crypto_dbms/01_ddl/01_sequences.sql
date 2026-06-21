-- ============================================================
-- FILE: 01_sequences.sql
-- DESC: All sequences for Cryptocurrency Transaction DBMS
-- RUN : Connect as CRYPTO_ADMIN and execute this file first
-- ============================================================

-- Drop existing sequences if re-running (safe re-run)
BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- Users sequence
CREATE SEQUENCE seq_user_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Cryptocurrencies sequence
CREATE SEQUENCE seq_coin_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Wallets sequence
CREATE SEQUENCE seq_wallet_id
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Transactions sequence
CREATE SEQUENCE seq_txn_id
    START WITH 1000
    INCREMENT BY 1
    CACHE 20
    NOCYCLE;

-- Price history sequence
CREATE SEQUENCE seq_price_id
    START WITH 1
    INCREMENT BY 1
    CACHE 50
    NOCYCLE;

-- Audit log sequence
CREATE SEQUENCE seq_log_id
    START WITH 1
    INCREMENT BY 1
    CACHE 20
    NOCYCLE;

-- Verify all sequences created
SELECT sequence_name, min_value, increment_by, cache_size
FROM   user_sequences
ORDER  BY sequence_name;
