===============================================================================
WHY IS AN ORACLE DIRECTORY OBJECT REQUIRED FOR DATA PUMP?
===============================================================================

Unlike older client-based export tools (like the legacy 'exp' and 'imp'), Oracle Data Pump (expdp and impdp) is a highly optimized, server-side utility.

1. Architecture Difference:
When you run the `expdp` command from your command prompt, the command prompt is merely a client sending an execution job request to the Oracle Database engine. The actual reading of data and writing to the `.dmp` files is performed by background processes running internally on the database server.

2. Operating System Permission Model:
The database server processes execute under the OS account that installed the Oracle Database (e.g., the 'oracle' OS user on Linux, or the specific Windows Service account for Oracle XE). These background processes do not run as the user executing the `expdp` command, meaning they only have the OS-level file permissions granted to the Oracle service account.

3. The Purpose of the DIRECTORY Object:
Because of this separation, Oracle implements the `DIRECTORY` object as a security abstraction layer. 
- It maps an internal database alias (e.g., `dpump_dir`) to an absolute physical OS path (e.g., `E:\crypto_dbms\07_data_pump`).
- It prevents standard database users from arbitrarily reading or writing files anywhere on the OS (which would be a massive security vulnerability).
- Database Administrators strictly control which paths are accessible by creating the DIRECTORY object and explicitly issuing `GRANT READ, WRITE ON DIRECTORY dpump_dir TO schema_user;`

Without the DIRECTORY object, Data Pump would not know where to safely save the files or wouldn't have explicit permission mapped to allow the Oracle service to write to the OS path.
