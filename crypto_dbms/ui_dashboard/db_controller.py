import oracledb

class DBController:
    def __init__(self):
        self.user = 'crypto_admin'
        self.password = 'Crypto2026'
        self.dsn = 'localhost:1521/orcl'  # Standard Oracle XE DSN, can be updated as needed
        self.connection = None

    def connect(self):
        try:
            # Thin mode does not require Oracle Client libraries
            self.connection = oracledb.connect(user=self.user, password=self.password, dsn=self.dsn)
            return True, "Connected successfully"
        except Exception as e:
            return False, str(e)

    def close(self):
        if self.connection:
            self.connection.close()

    def execute_query(self, query):
        if not self.connection:
            return False, "Not connected"
        try:
            cursor = self.connection.cursor()
            cursor.execute(query)
            
            if query.strip().upper().startswith("SELECT"):
                columns = [col[0] for col in cursor.description]
                rows = cursor.fetchall()
                cursor.close()
                return True, (columns, rows)
            else:
                self.connection.commit()
                cursor.close()
                return True, "Execution successful"
        except Exception as e:
            return False, str(e)

    def call_procedure(self, proc_name, params):
        if not self.connection:
            return False, "Not connected"
        try:
            cursor = self.connection.cursor()
            cursor.callproc(proc_name, params)
            self.connection.commit()
            cursor.close()
            return True, "Procedure executed successfully"
        except Exception as e:
            return False, str(e)
