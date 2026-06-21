import oracledb

try:
    conn = oracledb.connect(user='crypto_admin', password='Crypto2026', dsn='localhost:1521/orcl')
    cursor = conn.cursor()
    
    # Check if column exists first
    cursor.execute("SELECT column_name FROM user_tab_cols WHERE table_name = 'USERS' AND column_name = 'IS_VERIFIED'")
    if not cursor.fetchone():
        print("Adding IS_VERIFIED column...")
        cursor.execute("ALTER TABLE USERS ADD is_verified VARCHAR2(10) DEFAULT 'NO'")
        cursor.execute("UPDATE USERS SET is_verified = 'YES'")
        conn.commit()
        print("Column added and existing users set to YES.")
    else:
        print("Column IS_VERIFIED already exists.")
        
except Exception as e:
    print(f"DB Error: {e}")
