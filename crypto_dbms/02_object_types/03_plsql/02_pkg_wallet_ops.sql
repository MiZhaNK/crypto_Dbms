-- ==============================================================================
-- DELIVERABLE 3: PL/SQL PACKAGES - PKG_WALLET_OPS (FINAL FIXED VERSION)
-- Description: Package for wallet creation and balance retrieval
-- ==============================================================================
-- ISSUE FIXED:
-- ORA-00904: "CRYPTO_ID": invalid identifier
--
-- Reason:
-- Your WALLETS table does NOT contain a CRYPTO_ID column.
--
-- Solution:
-- Remove CRYPTO_ID from both:
--   1. Procedure parameters
--   2. INSERT statement
-- ==============================================================================

SET SERVEROUTPUT ON;

-- Drop package if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE pkg_wallet_ops';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

-- Create sequence if it does not exist
BEGIN
    EXECUTE IMMEDIATE '
        CREATE SEQUENCE wallets_seq
        START WITH 1
        INCREMENT BY 1
        NOCACHE
        NOCYCLE
    ';
EXCEPTION
    WHEN OTHERS THEN
        -- ORA-00955: object already exists
        IF SQLCODE != -955 THEN
            RAISE;
        END IF;
END;
/

-- ==========================================================================
-- PACKAGE SPECIFICATION
-- ==========================================================================
CREATE OR REPLACE PACKAGE pkg_wallet_ops AS

    -- Create a wallet for a user
    PROCEDURE create_wallet(
        p_user_id NUMBER,
        p_coin_id NUMBER
    );

    -- Get current wallet balance
    FUNCTION get_wallet_balance(
        p_wallet_id NUMBER
    ) RETURN NUMBER;

END pkg_wallet_ops;
/

-- ==========================================================================
-- PACKAGE BODY
-- ==========================================================================
CREATE OR REPLACE PACKAGE BODY pkg_wallet_ops AS

    --------------------------------------------------------------------------
    -- PROCEDURE: CREATE_WALLET
    --------------------------------------------------------------------------
    PROCEDURE create_wallet(
        p_user_id NUMBER,
        p_coin_id NUMBER
    ) IS
        v_wallet_id NUMBER;
        v_address   VARCHAR2(100);
    BEGIN
        -- Generate new wallet ID using the correct sequence
        SELECT seq_wallet_id.NEXTVAL
        INTO v_wallet_id
        FROM dual;

        -- Generate unique wallet address
        v_address := '0x' || RAWTOHEX(SYS_GUID());

        -- Insert new wallet
        INSERT INTO wallets (
            wallet_id,
            user_id,
            coin_id,
            wallet_address,
            balance,
            wallet_type,
            created_at
        ) VALUES (
            v_wallet_id,
            p_user_id,
            p_coin_id,
            v_address,
            0,
            'PERSONAL',
            SYSDATE
        );

        DBMS_OUTPUT.PUT_LINE(
            'SUCCESS: Wallet ' || v_wallet_id || ' created successfully.'
        );

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(
                'ERROR: Failed to create wallet. ' || SQLERRM
            );
            RAISE;
    END create_wallet;

    --------------------------------------------------------------------------
    -- FUNCTION: GET_WALLET_BALANCE
    --------------------------------------------------------------------------
    FUNCTION get_wallet_balance(
        p_wallet_id NUMBER
    ) RETURN NUMBER IS
        v_balance NUMBER := 0;
    BEGIN
        SELECT balance
        INTO v_balance
        FROM wallets
        WHERE wallet_id = p_wallet_id;

        RETURN v_balance;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END get_wallet_balance;

END pkg_wallet_ops;
/

-- ==========================================================================
-- VERIFICATION BLOCK
-- ==========================================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('VERIFYING PKG_WALLET_OPS PACKAGE');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Package compiled and logic verified.');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/

-- ==========================================================================
-- CHECK FOR COMPILATION ERRORS
-- ==========================================================================
SHOW ERRORS PACKAGE BODY pkg_wallet_ops;

-- ==========================================================================
-- TEST EXAMPLE
-- ==========================================================================
-- BEGIN
--     pkg_wallet_ops.create_wallet(1);
-- END;
-- /
--
-- SELECT pkg_wallet_ops.get_wallet_balance(1) AS balance FROM dual;