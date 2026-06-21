import oracledb
try:
    conn = oracledb.connect(user='crypto_admin', password='Crypto2026', dsn='localhost:1521/orcl')
    cursor = conn.cursor()
    cursor.execute("SELECT column_name, data_type, nullable FROM user_tab_cols WHERE table_name = 'USERS'")
    for row in cursor.fetchall(): print(row)
except Exception as e:
    print(e)
