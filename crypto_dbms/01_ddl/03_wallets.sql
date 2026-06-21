-- ============================================================
-- FILE: 03_wallets.sql
-- DESC: WALLETS table - references USERS and CRYPTOCURRENCIES
-- RUN : After 02_base_tables.sql
-- ============================================================

-- -------------------------------------------------------
-- TABLE: WALLETS
-- Each wallet belongs to one user and holds one coin type
-- -------------------------------------------------------
CREATE TABLE wallets (
    wallet_id       NUMBER          DEFAULT seq_wallet_id.NEXTVAL,
    user_id         NUMBER          NOT NULL,
    coin_id         NUMBER          NOT NULL,
    wallet_address  VARCHAR2(100)   NOT NULL,
    balance         NUMBER(24, 8)   DEFAULT 0 NOT NULL,
    wallet_type     VARCHAR2(20)    NOT NULL,
    created_at      DATE            DEFAULT SYSDATE NOT NULL,
    -- Constraints
    CONSTRAINT pk_wallets               PRIMARY KEY (wallet_id),
    CONSTRAINT fk_wallets_user          FOREIGN KEY (user_id)
                                            REFERENCES users(user_id)
                                            ON DELETE CASCADE,
    CONSTRAINT fk_wallets_coin          FOREIGN KEY (coin_id)
                                            REFERENCES cryptocurrencies(coin_id),
    CONSTRAINT uq_wallets_address       UNIQUE      (wallet_address),
    CONSTRAINT ck_wallets_balance       CHECK       (balance >= 0),
    CONSTRAINT ck_wallets_type          CHECK       (wallet_type IN (
                                            'PERSONAL', 'EXCHANGE', 'TRADING', 'SAVINGS'
                                        )),
    CONSTRAINT ck_wallets_address_len   CHECK       (LENGTH(wallet_address) >= 10)
);

COMMENT ON TABLE  wallets                IS 'Crypto wallets - each wallet is tied to one user and one coin';
COMMENT ON COLUMN wallets.wallet_address IS 'Blockchain wallet address - globally unique';
COMMENT ON COLUMN wallets.balance        IS 'Current balance in the coin''s native unit, 8 decimal precision';
COMMENT ON COLUMN wallets.wallet_type    IS 'PERSONAL | EXCHANGE | TRADING | SAVINGS';

-- -------------------------------------------------------
-- Indexes on foreign key columns (Oracle does NOT auto-index FKs)
-- Missing FK indexes cause full table scans on DELETE from parent
-- -------------------------------------------------------
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_coin_id ON wallets(coin_id);

-- -------------------------------------------------------
-- Seed data: 10 wallets for 5 users across different coins
-- -------------------------------------------------------

-- First create 5 sample users
INSERT INTO users (full_name, email, country) VALUES ('Ali Hassan',    'ali.hassan@email.com',    'Pakistan');
INSERT INTO users (full_name, email, country) VALUES ('Sara Ahmed',    'sara.ahmed@email.com',    'UAE');
INSERT INTO users (full_name, email, country) VALUES ('Omar Farooq',   'omar.farooq@email.com',   'Saudi Arabia');
INSERT INTO users (full_name, email, country) VALUES ('Zara Khan',     'zara.khan@email.com',     'Pakistan');
INSERT INTO users (full_name, email, country) VALUES ('David Smith',   'david.smith@email.com',   'USA');
COMMIT;

-- Now create wallets (wallet_address format simulates real crypto addresses)
INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (1, 1, 'BC1QXY1234ABCDEF567890ABCDEF1A',  0.58430000, 'PERSONAL');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (1, 2, '0xABCDEF1234567890ABCDEF12345678',  4.25000000, 'TRADING');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (2, 1, 'BC1QMN9876ZYXWVU543210ZYXWVU9B',  1.10000000, 'PERSONAL');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (2, 3, '0xUSDT9876543210FEDCBA9876543210',  5000.00000000, 'SAVINGS');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (3, 4, 'bnb1qrstuv7890123456789012345678',  12.75000000, 'EXCHANGE');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (3, 5, 'So1ana987654321ABCDEFGHIJKLMNOP',   45.50000000, 'TRADING');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (4, 2, '0xETH4567890ABCDEF1234567890ABC',    8.80000000, 'PERSONAL');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (4, 6, 'rXRP1234ABCDEFGHIJKLMNOPQRSTU',  2500.00000000, 'SAVINGS');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (5, 1, 'BC1QDV5555AAAABBBBCCCCDDDD5555D',   0.25000000, 'EXCHANGE');

INSERT INTO wallets (user_id, coin_id, wallet_address, balance, wallet_type)
VALUES (5, 3, '0xUSDT1111222233334444555566667',  10000.00000000, 'TRADING');

COMMIT;

-- Verify
SELECT w.wallet_id, u.full_name, c.symbol, w.balance, w.wallet_type
FROM   wallets w
JOIN   users u         ON u.user_id = w.user_id
JOIN   cryptocurrencies c ON c.coin_id = w.coin_id
ORDER  BY w.wallet_id;
