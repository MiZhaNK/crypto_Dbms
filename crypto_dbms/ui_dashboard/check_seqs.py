import oracledb
try:
    conn = oracledb.connect(user='crypto_admin', password='Crypto2026', dsn='localhost:1521/orcl')
    cursor = conn.cursor()
    cursor.execute("SELECT sequence_name FROM user_sequences WHERE sequence_name LIKE '%USER%'")
    for row in cursor.fetchall(): print(row)
except Exception as e:
    print(e)
