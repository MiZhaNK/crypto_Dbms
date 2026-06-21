@echo off
echo ==============================================================================
echo Running SQL*Loader for Crypto Transactions
echo ==============================================================================

sqlldr userid=crypto_admin/Crypto2026@orcl control=transactions_load.ctl log=load.log bad=load.bad

echo.
echo Check load.log for execution details and load.bad for rejected records.
pause
