import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'ui_dashboard'))
from db_controller import DBController

db = DBController()
success, msg = db.connect()
print(f"Connect: {success}, {msg}")

succ, msg = db.call_procedure("DBMS_MVIEW.REFRESH", ["WALLET_BALANCE_SUMMARY"])
print(f"Refresh WALLET_BALANCE_SUMMARY: {succ}, {msg}")

succ, msg = db.call_procedure("DBMS_MVIEW.REFRESH", ["MONTHLY_TXN_TRENDS"])
print(f"Refresh MONTHLY_TXN_TRENDS: {succ}, {msg}")
