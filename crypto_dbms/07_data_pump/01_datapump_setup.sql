-- ==============================================================================
-- DELIVERABLE 8: DATA PUMP (DIRECTORY OBJECT SETUP)
-- ==============================================================================

-- Create directory object
CREATE OR REPLACE DIRECTORY dpump_dir AS 'E:\crypto_dbms\07_data_pump';

-- Grant access ONLY to schema owner (SECURE APPROACH)
GRANT READ, WRITE ON DIRECTORY dpump_dir TO crypto_admin;

-- Success message
BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('SUCCESS: DIRECTORY dpump_dir created successfully.');
    DBMS_OUTPUT.PUT_LINE('ACCESS GRANTED TO SCHEMA OWNER ONLY.');
    DBMS_OUTPUT.PUT_LINE('====================================================');
END;
/