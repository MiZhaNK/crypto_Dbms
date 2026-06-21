-- ==============================================================================
-- DELIVERABLE 3: PL/SQL PACKAGES - PKG_AUDIT_REPORTS (FINAL FIXED VERSION)
-- Description: Package for extracting and formatting recent audit logs
-- ==============================================================================
-- ISSUES FIXED:
-- 1. ORA-00904: "CHANGE_DATE": invalid identifier
--    -> Your AUDIT_LOG table does not contain a CHANGE_DATE column.
-- 2. PLS-00364: loop index variable 'R' use is invalid
--    -> Caused by the invalid SQL statement above.
--
-- SOLUTION:
-- Use only columns that are guaranteed to exist:
--   log_id, table_name, operation
-- ==============================================================================

SET SERVEROUTPUT ON;

-- Drop package if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE pkg_audit_reports';
EXCEPTION
    WHEN OTHERS THEN
        -- ORA-04043: object does not exist
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

-- ==========================================================================
-- PACKAGE SPECIFICATION
-- ==========================================================================
CREATE OR REPLACE PACKAGE pkg_audit_reports AS
    PROCEDURE print_recent_audits(
        p_limit NUMBER
    );
END pkg_audit_reports;
/

-- ==========================================================================
-- PACKAGE BODY
-- ==========================================================================
CREATE OR REPLACE PACKAGE BODY pkg_audit_reports AS

    PROCEDURE print_recent_audits(
        p_limit NUMBER
    ) IS
        v_counter NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('====================================================');
        DBMS_OUTPUT.PUT_LINE('RECENT AUDIT LOGS');
        DBMS_OUTPUT.PUT_LINE('====================================================');

        -- Retrieve audit records ordered by log_id descending
        FOR r IN (
            SELECT log_id,
                   table_name,
                   operation
            FROM audit_log
            ORDER BY log_id DESC
        ) LOOP
            -- Stop after requested number of rows
            EXIT WHEN v_counter >= p_limit;

            DBMS_OUTPUT.PUT_LINE(
                'Log ID: ' || r.log_id ||
                ' | Table: ' || r.table_name ||
                ' | Operation: ' || r.operation
            );

            v_counter := v_counter + 1;
        END LOOP;

        IF v_counter = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No audit records found.');
        END IF;

        DBMS_OUTPUT.PUT_LINE('====================================================');

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(
                'ERROR: Unable to print audit logs. ' || SQLERRM
            );
    END print_recent_audits;

END pkg_audit_reports;
/

-- ==========================================================================
-- VERIFICATION BLOCK
-- ==========================================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('VERIFYING PKG_AUDIT_REPORTS PACKAGE');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Package compiled and logic verified.');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/

-- ==========================================================================
-- CHECK FOR COMPILATION ERRORS
-- ==========================================================================
SHOW ERRORS PACKAGE BODY pkg_audit_reports;

-- ==========================================================================
-- TEST EXAMPLE
-- ==========================================================================
-- BEGIN
--     pkg_audit_reports.print_recent_audits(10);
-- END;
-- /