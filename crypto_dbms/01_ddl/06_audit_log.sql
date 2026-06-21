-- ============================================================
-- FILE: 06_audit_log.sql
-- DESC: AUDIT_LOG table - populated by triggers (Deliverable 3)
--       Also used by pkg_audit_reports package
-- RUN : After 05_price_history_partitioned.sql
-- ============================================================

-- -------------------------------------------------------
-- TABLE: AUDIT_LOG
-- Captures every INSERT / UPDATE / DELETE on WALLETS and
-- TRANSACTIONS tables via triggers defined in 03_plsql/
-- Uses CLOB for old_value / new_value to store full row data
-- -------------------------------------------------------
CREATE TABLE audit_log (
    log_id       NUMBER          DEFAULT seq_log_id.NEXTVAL,
    table_name   VARCHAR2(50)    NOT NULL,
    operation    VARCHAR2(10)    NOT NULL,
    affected_id  NUMBER,
    changed_by   VARCHAR2(50)    DEFAULT SYS_CONTEXT('USERENV','SESSION_USER'),
    change_time  TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    old_value    CLOB,
    new_value    CLOB,
    -- Constraints
    CONSTRAINT pk_audit_log         PRIMARY KEY (log_id),
    CONSTRAINT ck_audit_operation   CHECK       (operation IN ('INSERT','UPDATE','DELETE')),
    CONSTRAINT ck_audit_table       CHECK       (table_name IN (
                                        'WALLETS','TRANSACTIONS','USERS','CRYPTOCURRENCIES'
                                    ))
);

COMMENT ON TABLE  audit_log             IS 'DML audit trail populated automatically by database triggers';
COMMENT ON COLUMN audit_log.table_name  IS 'Source table that was modified';
COMMENT ON COLUMN audit_log.operation   IS 'INSERT | UPDATE | DELETE';
COMMENT ON COLUMN audit_log.affected_id IS 'PK value of the row that was changed';
COMMENT ON COLUMN audit_log.changed_by  IS 'Oracle session user at time of change';
COMMENT ON COLUMN audit_log.old_value   IS 'JSON-style string of old column values (before change)';
COMMENT ON COLUMN audit_log.new_value   IS 'JSON-style string of new column values (after change)';

-- Index for common audit queries (filter by table + time range)
CREATE INDEX idx_audit_table_time ON audit_log(table_name, change_time);
CREATE INDEX idx_audit_affected   ON audit_log(affected_id);

-- -------------------------------------------------------
-- Verify full schema is now complete
-- -------------------------------------------------------
SELECT table_name, num_rows, partitioned
FROM   user_tables
WHERE  table_name IN (
    'USERS','CRYPTOCURRENCIES','WALLETS',
    'TRANSACTIONS','PRICE_HISTORY','AUDIT_LOG'
)
ORDER  BY table_name;
