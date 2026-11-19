-- ===== roles =====
-- ══════════════ ROLES Y USUARIOS (MySQL 8) ══════════════
CREATE ROLE IF NOT EXISTS 'rol_app', 'rol_lectura', 'rol_dba';

-- Aplicación: solo DML sobre el esquema del negocio (sin DDL ni acceso a la auditoría)
GRANT SELECT, INSERT, UPDATE, DELETE ON wawapacocha.* TO 'rol_app';
-- Lectura: reportes y analítica, incluida la consulta de la auditoría
GRANT SELECT ON wawapacocha.* TO 'rol_lectura';
GRANT SELECT ON wawapacocha_auditoria.* TO 'rol_lectura';
-- DBA: administra el esquema del negocio; la auditoría solo la puede leer
GRANT ALL PRIVILEGES ON wawapacocha.* TO 'rol_dba';
GRANT SELECT ON wawapacocha_auditoria.* TO 'rol_dba';

CREATE USER IF NOT EXISTS 'wawapacocha_app'@'localhost'      IDENTIFIED BY '<password_app>';
CREATE USER IF NOT EXISTS 'wawapacocha_readonly'@'localhost' IDENTIFIED BY '<password_lectura>';
CREATE USER IF NOT EXISTS 'wawapacocha_admin'@'localhost'    IDENTIFIED BY '<password_dba>';

GRANT 'rol_app'     TO 'wawapacocha_app'@'localhost';
GRANT 'rol_lectura' TO 'wawapacocha_readonly'@'localhost';
GRANT 'rol_dba'     TO 'wawapacocha_admin'@'localhost';
SET DEFAULT ROLE ALL TO 'wawapacocha_app'@'localhost', 'wawapacocha_readonly'@'localhost', 'wawapacocha_admin'@'localhost';
