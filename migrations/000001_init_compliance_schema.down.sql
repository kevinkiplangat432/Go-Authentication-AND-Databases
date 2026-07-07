DROP INDEX IF EXISTS idx_role_permissions_role;
DROP INDEX IF EXISTS idx_audit_log_hash;

DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS user;

DROP TYPE IF EXISTS user_role