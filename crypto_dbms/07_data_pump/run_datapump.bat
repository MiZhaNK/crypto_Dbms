@echo off
echo ==============================================================================
echo DATA PUMP EXPORT/IMPORT COMMANDS
echo ==============================================================================

echo 1. FULL SCHEMA EXPORT
echo expdp username/password@XE schemas=username directory=dpump_dir dumpfile=schema_full.dmp logfile=expdp_full.log
echo.

echo 2. TABLE-ONLY EXPORT (TRANSACTIONS and USERS)
echo expdp username/password@XE tables=TRANSACTIONS,USERS directory=dpump_dir dumpfile=tables_only.dmp logfile=expdp_tables.log
echo.

echo 3. RESTORE (IMPORT) WITH REMAP_SCHEMA
echo impdp system/syspassword@XE remap_schema=username:new_username directory=dpump_dir dumpfile=schema_full.dmp logfile=impdp_remap.log
echo.

pause
