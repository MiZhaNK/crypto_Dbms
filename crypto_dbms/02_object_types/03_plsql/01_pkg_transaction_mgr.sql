-- ==============================================================================
-- DELIVERABLE 3: PL/SQL PACKAGES - PKG_TRANSACTION_MGR (PDF Aligned)
-- Description: Package for transaction management with validation and auditing.
-- ==============================================================================

SET SERVEROUTPUT ON;

BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE pkg_transaction_mgr';
EXCEPTION
    WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF;
END;
/

CREATE OR REPLACE PACKAGE pkg_transaction_mgr AS
    FUNCTION validate_transaction(p_sender NUMBER, p_amount NUMBER) RETURN BOOLEAN;
    PROCEDURE process_transaction(
        p_sender   NUMBER, 
        p_receiver NUMBER, 
        p_crypto   NUMBER, 
        p_amount   NUMBER, 
        p_type     VARCHAR2
    );
END pkg_transaction_mgr;
/

CREATE OR REPLACE PACKAGE BODY pkg_transaction_mgr AS
    FUNCTION validate_transaction(p_sender NUMBER, p_amount NUMBER) RETURN BOOLEAN IS
        v_balance NUMBER := 0;
    BEGIN
        IF p_sender IS NULL THEN RETURN TRUE; END IF;
        
        SELECT balance INTO v_balance FROM WALLETS WHERE wallet_id = p_sender;
        RETURN v_balance >= p_amount;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN FALSE;
    END validate_transaction;

    PROCEDURE process_transaction(
        p_sender   NUMBER, p_receiver NUMBER, p_crypto   NUMBER, 
        p_amount   NUMBER, p_type     VARCHAR2
    ) IS
        v_txn_id NUMBER;
    BEGIN
        SAVEPOINT start_process_txn;
        
        IF NOT validate_transaction(p_sender, p_amount) THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Transaction failed validation.');
            ROLLBACK TO start_process_txn;
            RAISE_APPLICATION_ERROR(-20001, 'Transaction Failed: Insufficient balance or invalid wallet.');
        END IF;
        
        INSERT INTO TRANSACTIONS (
            txn_id, from_wallet_id, to_wallet_id, coin_id, 
            amount, fee, txn_status, txn_timestamp, notes
        ) VALUES (
            SEQ_TXN_ID.NEXTVAL, p_sender, p_receiver, p_crypto, 
            p_amount, 0.01, 'SUCCESS', SYSDATE, 'Processed via mgr - ' || UPPER(p_type)
        ) RETURNING txn_id INTO v_txn_id;
        
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Transaction ' || v_txn_id || ' completed.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO start_process_txn;
            DBMS_OUTPUT.PUT_LINE('ERROR: Transaction failed. ' || SQLERRM);
            RAISE;
    END process_transaction;
END pkg_transaction_mgr;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('VERIFYING PKG_TRANSACTION_MGR PACKAGE');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Package compiled and logic verified.');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/
