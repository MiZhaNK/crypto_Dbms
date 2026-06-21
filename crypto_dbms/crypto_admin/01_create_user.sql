-- ==============================================================================
-- PROJECT SETUP: CREATE CRYPTO_ADMIN USER
-- ==============================================================================
-- NOTE: This script should be run connected as SYSDBA (e.g., sys as sysdba)
-- ==============================================================================

-- 1. Create the project schema user
CREATE USER crypto_admin IDENTIFIED BY Crypto2026;

-- 2. Grant all necessary privileges
GRANT DBA TO crypto_admin;
GRANT CREATE SESSION TO crypto_admin;
GRANT UNLIMITED TABLESPACE TO crypto_admin;
GRANT CREATE TABLE TO crypto_admin;
GRANT CREATE VIEW TO crypto_admin;
GRANT CREATE PROCEDURE TO crypto_admin;
GRANT CREATE TRIGGER TO crypto_admin;
GRANT CREATE SEQUENCE TO crypto_admin;
GRANT CREATE TYPE TO crypto_admin;
GRANT CREATE MATERIALIZED VIEW TO crypto_admin;

-- Additional useful grants often required for advanced project features:
GRANT CREATE SYNONYM TO crypto_admin;
GRANT CREATE ANY CONTEXT TO crypto_admin;
GRANT EXECUTE ON DBMS_MVIEW TO crypto_admin;
GRANT EXECUTE ON DBMS_RLS TO crypto_admin;
GRANT EXECUTE ON DBMS_CRYPTO TO crypto_admin;
GRANT EXECUTE ON DBMS_SCHEDULER TO crypto_admin;

-- 3. Verify the user was created
SET LINESIZE 150;
COLUMN username FORMAT A20;
COLUMN account_status FORMAT A20;

SELECT username, account_status 
FROM dba_users 
WHERE username = 'CRYPTO_ADMIN';

-- ==============================================================================
-- END OF SCRIPT
-- ==============================================================================
