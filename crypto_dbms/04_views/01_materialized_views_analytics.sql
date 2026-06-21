-- ==============================================================================
-- DELIVERABLE 5: MATERIALIZED VIEWS & ANALYTICS (FINAL FIXED VERSION)
-- Description: Materialized Views, CUBE/ROLLUP, and Set Operators
-- ==============================================================================

SET SERVEROUTPUT ON;

-- ==============================================================================
-- 1. SAFE DROP SECTION
-- ==============================================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW wallet_balance_summary';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -12003 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW monthly_txn_trends';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -12003 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW top_senders_receivers';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -12003 THEN RAISE; END IF;
END;
/

-- ==============================================================================
-- 2. MATERIALIZED VIEW: WALLET BALANCE SUMMARY
-- ==============================================================================

CREATE MATERIALIZED VIEW wallet_balance_summary
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    w.user_id,
    w.wallet_id,
    w.balance,
    c.symbol AS cryptocurrency,
    SUM(w.balance * c.current_price_usd) AS total_fiat_value
FROM wallets w
JOIN cryptocurrencies c
    ON w.coin_id = c.coin_id
GROUP BY w.user_id, w.wallet_id, w.balance, c.symbol;

-- ==============================================================================
-- 3. MATERIALIZED VIEW: MONTHLY TRANSACTION TRENDS
-- ==============================================================================

CREATE MATERIALIZED VIEW monthly_txn_trends
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    TO_CHAR(txn_timestamp, 'YYYY-MM') AS txn_month,
    coin_id,
    SUM(amount) AS total_volume,
    SUM(fee) AS total_fees,
    COUNT(*) AS txn_count
FROM transactions
WHERE txn_status = 'SUCCESS'
GROUP BY TO_CHAR(txn_timestamp, 'YYYY-MM'), coin_id;

-- ==============================================================================
-- 4. MATERIALIZED VIEW: TOP SENDERS & RECEIVERS
-- ==============================================================================

CREATE MATERIALIZED VIEW top_senders_receivers
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    wallet_id,
    SUM(sent) AS total_sent,
    SUM(received) AS total_received,
    SUM(sent + received) AS total_activity
FROM (
    SELECT 
        from_wallet_id AS wallet_id,
        COUNT(*) AS sent,
        0 AS received
    FROM transactions
    WHERE from_wallet_id IS NOT NULL
    GROUP BY from_wallet_id
    UNION ALL
    SELECT 
        to_wallet_id AS wallet_id,
        0 AS sent,
        COUNT(*) AS received
    FROM transactions
    WHERE to_wallet_id IS NOT NULL
    GROUP BY to_wallet_id
)
GROUP BY wallet_id;

-- ==============================================================================
-- 5. ANALYTICS QUERIES (SET OPERATORS)
-- ==============================================================================

-- UNION: All transaction flow for a wallet
SELECT 'OUTGOING' AS direction, txn_id, amount
FROM transactions
WHERE from_wallet_id = 1
UNION
SELECT 'INCOMING' AS direction, txn_id, amount
FROM transactions
WHERE to_wallet_id = 1;


-- INTERSECT: Users holding BTC and ETH wallets
SELECT user_id
FROM wallets
WHERE coin_id = (SELECT coin_id FROM cryptocurrencies WHERE symbol = 'BTC')
INTERSECT
SELECT user_id
FROM wallets
WHERE coin_id = (SELECT coin_id FROM cryptocurrencies WHERE symbol = 'ETH');


-- MINUS: Wallets that only send but never receive
SELECT from_wallet_id AS wallet_id
FROM transactions
MINUS
SELECT to_wallet_id AS wallet_id
FROM transactions;


-- ==============================================================================
-- 6. ROLLUP ANALYSIS (YEARLY + MONTHLY)
-- ==============================================================================

SELECT 
    EXTRACT(YEAR FROM txn_timestamp) AS txn_year,
    TO_CHAR(txn_timestamp, 'MM') AS txn_month,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY ROLLUP (
    EXTRACT(YEAR FROM txn_timestamp),
    TO_CHAR(txn_timestamp, 'MM')
);


-- ==============================================================================
-- 7. CUBE ANALYSIS (COIN + STATUS ANALYTICS)
-- ==============================================================================

SELECT 
    coin_id,
    txn_status,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY CUBE (coin_id, txn_status);

-- ==============================================================================
-- 8. FINAL SUCCESS MESSAGE
-- ==============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: MATERIALIZED VIEWS + ANALYTICS COMPLETED');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/