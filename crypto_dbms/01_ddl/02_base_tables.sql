-- ============================================================
-- FILE: 02_base_tables.sql
-- DESC: USERS and CRYPTOCURRENCIES tables
--       These have NO foreign key dependencies - create first
-- RUN : After 01_sequences.sql
-- ============================================================

-- -------------------------------------------------------
-- TABLE: USERS
-- Stores registered wallet owners / platform accounts
-- -------------------------------------------------------
CREATE TABLE users (
    user_id     NUMBER          DEFAULT seq_user_id.NEXTVAL,
    full_name   VARCHAR2(100)   NOT NULL,
    email       VARCHAR2(150)   NOT NULL,
    country     VARCHAR2(60),
    is_verified VARCHAR2(3)     DEFAULT 'NO',
    created_at  DATE            DEFAULT SYSDATE NOT NULL,
    -- Constraints
    CONSTRAINT pk_users         PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email   UNIQUE      (email),
    CONSTRAINT ck_users_email   CHECK       (email LIKE '%@%.%'),
    CONSTRAINT ck_users_name    CHECK       (LENGTH(TRIM(full_name)) >= 2)
);

COMMENT ON TABLE  users            IS 'Registered users and wallet owners on the platform';
COMMENT ON COLUMN users.user_id    IS 'Surrogate primary key from seq_user_id';
COMMENT ON COLUMN users.email      IS 'Unique login email - validated by check constraint';
COMMENT ON COLUMN users.country    IS 'ISO country name or code';
COMMENT ON COLUMN users.created_at IS 'Account registration timestamp, defaults to SYSDATE';

-- -------------------------------------------------------
-- TABLE: CRYPTOCURRENCIES
-- Master catalogue of supported digital coins
-- -------------------------------------------------------
CREATE TABLE cryptocurrencies (
    coin_id           NUMBER          DEFAULT seq_coin_id.NEXTVAL,
    symbol            VARCHAR2(10)    NOT NULL,
    coin_name         VARCHAR2(100)   NOT NULL,
    current_price_usd NUMBER(18, 8)   DEFAULT 0 NOT NULL,
    market_cap        NUMBER(24, 2),
    -- Constraints
    CONSTRAINT pk_cryptocurrencies        PRIMARY KEY (coin_id),
    CONSTRAINT uq_crypto_symbol           UNIQUE      (symbol),
    CONSTRAINT ck_crypto_price_positive   CHECK       (current_price_usd >= 0),
    CONSTRAINT ck_crypto_symbol_upper     CHECK       (symbol = UPPER(symbol))
);

COMMENT ON TABLE  cryptocurrencies                    IS 'Master list of supported cryptocurrencies on the platform';
COMMENT ON COLUMN cryptocurrencies.symbol             IS 'Ticker symbol e.g. BTC, ETH, USDT - must be uppercase';
COMMENT ON COLUMN cryptocurrencies.current_price_usd  IS 'Last recorded price in USD, 8 decimal precision';
COMMENT ON COLUMN cryptocurrencies.market_cap         IS 'Total market capitalisation in USD';

-- -------------------------------------------------------
-- Seed data: 6 realistic cryptocurrencies
-- -------------------------------------------------------
INSERT INTO cryptocurrencies (symbol, coin_name, current_price_usd, market_cap)
VALUES ('BTC',  'Bitcoin',       67452.50000000,  1328000000000.00);

INSERT INTO cryptocurrencies (symbol, coin_name, current_price_usd, market_cap)
VALUES ('ETH',  'Ethereum',       3521.75000000,   423000000000.00);

INSERT INTO cryptocurrencies (symbol, coin_name, current_price_usd, market_cap)
VALUES ('USDT', 'Tether',            1.00020000,   108000000000.00);

INSERT INTO cryptocurrencies (symbol, coin_name, current_price_usd, market_cap)
VALUES ('BNB',  'BNB',             589.32000000,    88000000000.00);

INSERT INTO cryptocurrencies (symbol, coin_name, current_price_usd, market_cap)
VALUES ('SOL',  'Solana',          172.48000000,    79000000000.00);

INSERT INTO cryptocurrencies (symbol, coin_name, current_price_usd, market_cap)
VALUES ('XRP',  'XRP',               0.62150000,    34000000000.00);

COMMIT;

-- Verify
SELECT coin_id, symbol, coin_name, current_price_usd FROM cryptocurrencies;
