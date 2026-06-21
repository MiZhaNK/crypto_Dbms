-- ==============================================================================
-- DELIVERABLE 6: AUDITING & SECURITY (FINAL CORRECTED VERSION)
-- ==============================================================================

SET SERVEROUTPUT ON;
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- ==============================================================================
-- 1. DROP EXISTING OBJECTS SAFELY
-- ==============================================================================

-- Drop user
BEGIN
    EXECUTE IMMEDIATE 'DROP USER demo_analyst CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN
            RAISE;
        END IF;
END;
/

-- Drop roles
BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crypto_admin_role';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -01919 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP ROLE crypto_read_role';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -01919 THEN
            RAISE;
        END IF;
END;
/

-- Drop FGA policy safely
BEGIN
    DBMS_FGA.DROP_POLICY(
        object_schema => USER,
        object_name   => 'TRANSACTIONS',
        policy_name   => 'AUDIT_HIGH_VALUE_TXN'
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ==============================================================================
-- 2. STANDARD AUDITING
-- ==============================================================================
-- Requires DBA privileges
AUDIT INSERT, UPDATE, DELETE ON transactions BY ACCESS;
AUDIT INSERT, UPDATE, DELETE ON users BY ACCESS;

-- ==============================================================================
-- 3. FINE GRAINED AUDITING (FGA)
-- ==============================================================================
BEGIN
    DBMS_FGA.ADD_POLICY(
        object_schema   => USER,
        object_name     => 'TRANSACTIONS',
        policy_name     => 'AUDIT_HIGH_VALUE_TXN',
        audit_condition => 'AMOUNT > 10000',
        audit_column    => 'AMOUNT',
        statement_types => 'INSERT,UPDATE'
    );
END;
/

-- ==============================================================================
-- 4. ROLE CREATION
-- ==============================================================================

CREATE ROLE crypto_admin_role;
CREATE ROLE crypto_read_role;

-- ==============================================================================
-- 5. GRANT PRIVILEGES (ADMIN ROLE)
-- ==============================================================================

GRANT SELECT, INSERT, UPDATE, DELETE ON transactions TO crypto_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON users TO crypto_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON wallets TO crypto_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON cryptocurrencies TO crypto_admin_role;

-- ==============================================================================
-- 6. GRANT PRIVILEGES (READ ROLE)
-- ==============================================================================

GRANT SELECT ON transactions TO crypto_read_role;
GRANT SELECT ON users TO crypto_read_role;
GRANT SELECT ON wallets TO crypto_read_role;
GRANT SELECT ON cryptocurrencies TO crypto_read_role;

-- ==============================================================================
-- 7. CREATE DEMO USER
-- ==============================================================================

CREATE USER demo_analyst IDENTIFIED BY "StrongP@ssw0rd21";

GRANT CREATE SESSION TO demo_analyst;
GRANT crypto_read_role TO demo_analyst;

-- ==============================================================================
-- 8. SUCCESS MESSAGE
-- ==============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: AUDITING + RBAC SECURITY CONFIGURED');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/