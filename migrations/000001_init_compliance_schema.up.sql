-- generate enums 
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'employee');
-- BASE users Table (independent) 
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role NOT NULL DEFAULT 'employee',
    created_aT TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- FINE GRAINED PERMISSION TABLE (INDEPENDENT)
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
);

-- Role-based Join table (dependent on permissions)
-- since we are using an enum for roles we map the text value of the emnum directly to granular permission
CREATE TABLE role_permissions (
    role user_role NOT NULL,
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role, permission_id)
);

-- cryptographically linked tamper-evident AUDIT LOG (Dependent on Users)
--The hash and prev_hash make this a blockchain-style append-only ledger for AI changes
CREATE TABLE audit_log(
    id BIGSERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- cryptographic chaincolumns
    hash VARCHAR(64) NOT NULL
    prev_hash VARCHAR(64) NOT NULL
);

-- INDEXES for stark level speeds
--compliance systems query logs and check permissions constantly. 
CREATE INDEX idx_audit_log_hash ON audit_log(hash);
CREATE INDEX idx_role_permission_role ON role_permission(role);