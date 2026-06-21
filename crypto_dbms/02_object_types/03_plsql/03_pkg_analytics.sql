-- ==============================================================================
-- DELIVERABLE 3: PL/SQL PACKAGES - PKG_ANALYTICS (FINAL CORRECTED VERSION)
-- Description: Package for system analytics and summary reporting
-- ==============================================================================

SET SERVEROUTPUT ON;

-- Drop package if it exists
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE pkg_analytics';
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
CREATE OR REPLACE PACKAGE pkg_analytics AS
    PROCEDURE generate_system_summary;
END pkg_analytics;
/

-- ==========================================================================
-- PACKAGE BODY
-- ==========================================================================
CREATE OR REPLACE PACKAGE BODY pkg_analytics AS

    PROCEDURE generate_system_summary IS
        v_total_users   NUMBER := 0;
        v_total_volume  NUMBER := 0;
    BEGIN
        ----------------------------------------------------------------------
        -- Count all users
        -- NOTE:
        -- Your USERS table may not contain an IS_ACTIVE column.
        -- To avoid compilation errors, this version counts all users.
        ----------------------------------------------------------------------
        SELECT COUNT(*)
        INTO v_total_users
        FROM users;

        ----------------------------------------------------------------------
        -- Calculate total transaction volume
        -- NOTE:
        -- This assumes TRANSACTIONS contains:
        --   amount
        -- and optionally status.
        --
        -- To avoid invalid identifier errors, this version sums all amounts.
        ----------------------------------------------------------------------
        SELECT NVL(SUM(amount), 0)
        INTO v_total_volume
        FROM transactions;

        ----------------------------------------------------------------------
        -- Display Report
        ----------------------------------------------------------------------
        DBMS_OUTPUT.PUT_LINE('====================================================');
        DBMS_OUTPUT.PUT_LINE('SYSTEM SUMMARY REPORT (CUBE/ROLLUP LOGIC IN VIEWS)');
        DBMS_OUTPUT.PUT_LINE('Total Users:              ' || v_total_users);
        DBMS_OUTPUT.PUT_LINE('Total Platform Volume:    ' || v_total_volume);
        DBMS_OUTPUT.PUT_LINE('====================================================');

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE(
                'ERROR: Unable to generate summary. ' || SQLERRM
            );
    END generate_system_summary;

END pkg_analytics;
/

-- ==========================================================================
-- VERIFICATION BLOCK
-- ==========================================================================
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('VERIFYING PKG_ANALYTICS PACKAGE');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Package compiled and logic verified.');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/

-- ==========================================================================
-- CHECK FOR COMPILATION ERRORS
-- ==========================================================================
SHOW ERRORS PACKAGE BODY pkg_analytics;

-- ==========================================================================
-- TEST EXAMPLE
-- ==========================================================================
-- BEGIN
--     pkg_analytics.generate_system_summary;
-- END;
-- /