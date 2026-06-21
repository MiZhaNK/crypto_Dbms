-- ==============================================================================
-- DELIVERABLE 4: TRIGGERS
-- ==============================================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------------------------
-- SAFE DROP SECTION
-- ------------------------------------------------------------------------------

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_users';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_transactions';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_update_balance';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_price_alert';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN RAISE; END IF;
END;
/

-- ------------------------------------------------------------------------------
-- TRG_AUDIT_USERS
-- ------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW
DECLARE
    v_op VARCHAR2(10);
    v_old_val CLOB;
    v_new_val CLOB;
BEGIN

    IF INSERTING THEN
        v_op := 'INSERT';

        v_new_val :=
            'Name: ' || :NEW.full_name;

    ELSIF UPDATING THEN
        v_op := 'UPDATE';

        v_old_val :=
            'Name: ' || :OLD.full_name;

        v_new_val :=
            'Name: ' || :NEW.full_name;

    ELSIF DELETING THEN
        v_op := 'DELETE';

        v_old_val :=
            'Name: ' || :OLD.full_name;
    END IF;

    INSERT INTO audit_log (
        log_id,
        table_name,
        operation,
        old_value,
        new_value,
        changed_by,
        change_time
    )
    VALUES (
        seq_log_id.NEXTVAL,
        'USERS',
        v_op,
        v_old_val,
        v_new_val,
        USER,
        SYSDATE
    );

END;
/

-- ------------------------------------------------------------------------------
-- TRG_AUDIT_TRANSACTIONS
-- ------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_audit_transactions
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW
DECLARE
    v_op VARCHAR2(10);
    v_old_val CLOB;
    v_new_val CLOB;
BEGIN

    IF INSERTING THEN
        v_op := 'INSERT';

        v_new_val :=
            'TXN_ID: ' || :NEW.txn_id ||
            ', Amount: ' || :NEW.amount;

    ELSIF UPDATING THEN
        v_op := 'UPDATE';

        v_old_val :=
            'TXN_ID: ' || :OLD.txn_id ||
            ', Amount: ' || :OLD.amount;

        v_new_val :=
            'TXN_ID: ' || :NEW.txn_id ||
            ', Amount: ' || :NEW.amount;

    ELSIF DELETING THEN
        v_op := 'DELETE';

        v_old_val :=
            'TXN_ID: ' || :OLD.txn_id ||
            ', Amount: ' || :OLD.amount;
    END IF;

    INSERT INTO audit_log (
        log_id,
        table_name,
        operation,
        old_value,
        new_value,
        changed_by,
        change_time
    )
    VALUES (
        seq_log_id.NEXTVAL,
        'TRANSACTIONS',
        v_op,
        v_old_val,
        v_new_val,
        USER,
        SYSDATE
    );

END;
/

-- ------------------------------------------------------------------------------
-- TRG_UPDATE_BALANCE
-- ------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_update_balance
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN

    -- deduct from sender wallet
    UPDATE wallets
    SET balance = balance - :NEW.amount
    WHERE wallet_id = :NEW.from_wallet_id;

    -- add to receiver wallet
    UPDATE wallets
    SET balance = balance + :NEW.amount
    WHERE wallet_id = :NEW.to_wallet_id;

END;
/

-- ------------------------------------------------------------------------------
-- TRG_PRICE_ALERT
-- ------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_price_alert
AFTER INSERT ON price_history
FOR EACH ROW
DECLARE
    v_prev_price NUMBER;
    v_change_pct NUMBER;
BEGIN

    SELECT current_price_usd
    INTO v_prev_price
    FROM cryptocurrencies
    WHERE coin_id = :NEW.coin_id;

    IF v_prev_price > 0 THEN

        v_change_pct :=
            ABS((:NEW.price_usd - v_prev_price) / v_prev_price) * 100;

        IF v_change_pct > 10 THEN

            INSERT INTO audit_log (
                log_id,
                table_name,
                operation,
                new_value,
                changed_by,
                change_time
            )
            VALUES (
                seq_log_id.NEXTVAL,
                'PRICE_HISTORY',
                'PRICE_ALERT',
                'Coin ID ' || :NEW.coin_id ||
                ' changed by ' || ROUND(v_change_pct,2) || '%',
                USER,
                SYSDATE
            );

        END IF;

    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
END;
/

-- ------------------------------------------------------------------------------
-- VERIFICATION
-- ------------------------------------------------------------------------------

BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('TRIGGERS CREATED SUCCESSFULLY');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/