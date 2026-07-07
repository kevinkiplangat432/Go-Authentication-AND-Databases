-- Seed Initial Granular Permissions
INSERT INTO permissions (name, description) VALUES 
('compliance:read', 'View AI models and logs'),
('compliance:write', 'Submit AI models for audit'),
('compliance:override', 'Bypass or force override safety policies');

-- Assign Permissions to Roles
-- Employee can only read/submit
INSERT INTO role_permissions (role, permission_id) VALUES 
('employee', (SELECT id FROM permissions WHERE name='compliance:read')),
('employee', (SELECT id FROM permissions WHERE name='compliance:write'));

-- Manager can do everything an employee can
INSERT INTO role_permissions (role, permission_id) VALUES 
('Manager', (SELECT id FROM permissions WHERE name='compliance:read')),
('Manager', (SELECT id FROM permissions WHERE name='compliance:write'));

-- Admin gets the nuclear option: overrides
INSERT INTO role_permissions (role, permission_id) VALUES 
('admin', (SELECT id FROM permissions WHERE name='compliance:read')),
('admin', (SELECT id FROM permissions WHERE name='compliance:write')),
('admin', (SELECT id FROM permissions WHERE name='compliance:override'));
