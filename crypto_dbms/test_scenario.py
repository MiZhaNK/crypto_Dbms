import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), 'ui_dashboard'))
from db_controller import DBController

db = DBController()
db.connect()

# 1. Check if user was created
succ, res = db.execute_query("SELECT user_id, full_name, is_verified FROM users ORDER BY user_id DESC FETCH FIRST 1 ROWS ONLY")
print("Latest user:", res[1] if succ and res[1] else "None")
user_id = res[1][0][0] if succ and res[1] else None

# 2. Try creating a wallet for this user
succ, msg = db.call_procedure("pkg_wallet_ops.create_wallet", [user_id, 1])
print(f"Create wallet: {succ}, {msg}")

succ, res = db.execute_query(f"SELECT wallet_id, user_id, coin_id, balance FROM wallets WHERE user_id = {user_id}")
print(f"Wallets for user {user_id}:", res[1] if succ and res[1] else "None")

# 3. Check materialized view
db.call_procedure("DBMS_MVIEW.REFRESH", ["WALLET_BALANCE_SUMMARY"])
succ, res = db.execute_query(f"SELECT * FROM WALLET_BALANCE_SUMMARY WHERE user_id = {user_id}")
print(f"MV data for user {user_id}:", res[1] if succ and res[1] else "None")

# 4. Check why transaction tab wouldn't update
# Wait, check_live_transfer_status executes: SELECT wallet_id, balance FROM wallets WHERE user_id = {sender} AND coin_id = {crypto_id}
succ, res = db.execute_query(f"SELECT wallet_id, balance FROM wallets WHERE user_id = {user_id} AND coin_id = 1")
print(f"Transaction tab check for user {user_id} BTC:", res[1] if succ and res[1] else "None")
