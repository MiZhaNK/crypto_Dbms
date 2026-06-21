-- ==============================================================================
-- DELIVERABLE 3: ORACLE OBJECT TYPES
-- Description: Creates the OOP type hierarchy for financial entities as per PDF.
-- ==============================================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------------------------
-- 1. SAFE DROP SECTION
-- ------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE transaction_t FORCE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE exchange_wallet_t FORCE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE crypto_wallet_t FORCE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE financial_entity_t FORCE';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF;
END;
/

-- ------------------------------------------------------------------------------
-- 2. ABSTRACT BASE TYPE: FINANCIAL_ENTITY_T
-- ------------------------------------------------------------------------------
CREATE OR REPLACE TYPE financial_entity_t AS OBJECT (
    entity_id    NUMBER,
    entity_name  VARCHAR2(100),
    created_date DATE,
    is_active    VARCHAR2(1),
    
    MEMBER FUNCTION get_display_name RETURN VARCHAR2,
    MEMBER FUNCTION compute_fee RETURN NUMBER
) NOT FINAL NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE BODY financial_entity_t AS

    MEMBER FUNCTION get_display_name RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Entity ID: ' || entity_id || ' - ' || entity_name;
    END;

    MEMBER FUNCTION compute_fee RETURN NUMBER IS
    BEGIN
        RETURN 0;
    END;

END;
/

-- ------------------------------------------------------------------------------
-- 3. SUBTYPE: CRYPTO_WALLET_T
-- ------------------------------------------------------------------------------
CREATE OR REPLACE TYPE crypto_wallet_t UNDER financial_entity_t (
    wallet_address VARCHAR2(100),
    crypto_symbol  VARCHAR2(10),
    balance        NUMBER,
    
    OVERRIDING MEMBER FUNCTION get_display_name RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION compute_fee RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY crypto_wallet_t AS
    OVERRIDING MEMBER FUNCTION get_display_name RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Crypto Wallet [' || self.crypto_symbol || ']: ' || self.entity_name || ' (' || self.wallet_address || ')';
    END;

    OVERRIDING MEMBER FUNCTION compute_fee RETURN NUMBER IS
    BEGIN
        -- Example flat rate fee computation for standard crypto wallets
        RETURN 0.01; -- 1% fee logic wrapper
    END;
END;
/

-- ------------------------------------------------------------------------------
-- 4. SUBTYPE: EXCHANGE_WALLET_T
-- ------------------------------------------------------------------------------
CREATE OR REPLACE TYPE exchange_wallet_t UNDER financial_entity_t (
    exchange_name     VARCHAR2(100),
    supported_cryptos VARCHAR2(500),
    total_volume      NUMBER,
    
    OVERRIDING MEMBER FUNCTION get_display_name RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION compute_fee RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY exchange_wallet_t AS
    OVERRIDING MEMBER FUNCTION get_display_name RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Exchange Wallet: ' || self.exchange_name || ' (Supports: ' || self.supported_cryptos || ')';
    END;

    OVERRIDING MEMBER FUNCTION compute_fee RETURN NUMBER IS
    BEGIN
        -- Exchange wallets might have lower fees
        RETURN 0.005; -- 0.5% fee logic wrapper
    END;
END;
/

-- ------------------------------------------------------------------------------
-- 5. TYPE: TRANSACTION_T
-- ------------------------------------------------------------------------------
CREATE OR REPLACE TYPE transaction_t AS OBJECT (
    txn_id        NUMBER,
    from_wallet   NUMBER,
    to_wallet     NUMBER,
    amount        NUMBER,
    fee_rate      NUMBER,
    
    MEMBER FUNCTION calculate_net_amount RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY transaction_t AS
    MEMBER FUNCTION calculate_net_amount RETURN NUMBER IS
    BEGIN
        RETURN self.amount - (self.amount * self.fee_rate);
    END;
END;
/

-- ------------------------------------------------------------------------------
-- 6. VERIFICATION SCRIPT
-- ------------------------------------------------------------------------------
DECLARE
    v_crypto_wallet   crypto_wallet_t;
    v_exchange_wallet exchange_wallet_t;
    v_transaction     transaction_t;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('VERIFYING OBJECT TYPES (PDF PROPOSAL ALIGNED)');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    v_crypto_wallet := crypto_wallet_t(1, 'My Vault', SYSDATE, 'Y', '1A1zP1...', 'BTC', 2.5);
    v_exchange_wallet := exchange_wallet_t(2, 'Binance Hot', SYSDATE, 'Y', 'Binance', 'BTC,ETH', 5000000.00);
    v_transaction := transaction_t(1001, 1, 2, 50.0, 0.01);
    
    DBMS_OUTPUT.PUT_LINE(v_crypto_wallet.get_display_name() || ' | Fee: ' || v_crypto_wallet.compute_fee());
    DBMS_OUTPUT.PUT_LINE(v_exchange_wallet.get_display_name() || ' | Fee: ' || v_exchange_wallet.compute_fee());
    DBMS_OUTPUT.PUT_LINE('Transaction 1001 Net Amount: ' || v_transaction.calculate_net_amount());
END;
/
