-- R-CONF | consultas de verificación de solo lectura para Oracle 21c XE
-- Ejecutar conectado como SYS en la PDB XEPDB1, o como DBA con privilegios
-- equivalentes de lectura de catálogo. No otorga privilegios ni modifica objetos.
-- No compartir spool sin revisar si contiene nombres de cuentas o sentencias.

SET PAGESIZE 100
SET LINESIZE 220
SET LONG 2000
SET TRIMSPOOL ON
SET VERIFY OFF

PROMPT === Contexto de sesión ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS pdb,
       SYS_CONTEXT('USERENV','SESSION_USER') AS usuario,
       SYS_CONTEXT('USERENV','DB_NAME') AS base_datos
FROM dual;

PROMPT === 5.12 Clasificación: comentarios/documentación de columnas ===
SELECT owner, table_name, column_name, comments
FROM dba_col_comments
WHERE owner = 'RCONF_OWNER'
  AND table_name IN ('DEMO_PERSONAL','RISKS')
ORDER BY table_name, column_name;

PROMPT === 5.15 / 5.18 / 8.2 / 8.3 Derechos directos de RCONF_APP ===
SELECT grantee, owner, table_name, privilege, grantable
FROM dba_tab_privs
WHERE grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY')
   OR (owner='RCONF_OWNER' AND grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY'))
ORDER BY grantee, owner, table_name, privilege;

PROMPT === 8.2 Privilegios de sistema del usuario y sus roles asignados ===
SELECT grantee, privilege, admin_option
FROM dba_sys_privs
WHERE grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY')
ORDER BY grantee, privilege;
SELECT grantee, granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY')
ORDER BY grantee, granted_role;

PROMPT === 5.16 / 8.5 Estado de cuentas y perfiles ===
SELECT username, account_status, profile, expiry_date, lock_date
FROM dba_users
WHERE username LIKE 'RCONF_%'
ORDER BY username;

PROMPT === 5.17 / 8.5 Parámetros de perfiles relacionados con contraseña ===
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE resource_type='PASSWORD'
  AND profile IN (SELECT profile FROM dba_users WHERE username LIKE 'RCONF_%')
ORDER BY profile, resource_name;

PROMPT === 5.33 / 8.15 Políticas de auditoría del laboratorio ===
SELECT policy_name, enabled_option, entity_name, entity_type, success, failure
FROM audit_unified_enabled_policies
WHERE policy_name LIKE 'RCONF%'
ORDER BY policy_name, entity_name;

PROMPT === 8.3 / 8.11 Vistas y tablas del alcance ===
SELECT owner, object_name, object_type, status
FROM dba_objects
WHERE owner='RCONF_OWNER'
  AND object_name IN ('MASKED_PERSONAL','RISK_VIEW','DEMO_PERSONAL','RISKS','RISK_API')
ORDER BY object_type, object_name;

PROMPT === 8.10 Objetos RCONF presentes en la papelera de reciclaje ===
SELECT owner, original_name, type, droptime
FROM dba_recyclebin
WHERE owner='RCONF_OWNER'
ORDER BY droptime DESC;

PROMPT === 8.12 Conteo de enlaces de base de datos por propietario ===
SELECT owner, COUNT(*) AS cantidad_db_links
FROM dba_db_links
GROUP BY owner
ORDER BY owner;

PROMPT === 8.13 Estado de piezas de respaldo visibles ===
SELECT recid, stamp, piece#, status, encrypted, completion_time
FROM v$backup_piece
ORDER BY completion_time DESC;

PROMPT === 8.15 / 8.16 Eventos Unified Audit recientes para el laboratorio ===
SELECT event_timestamp, dbusername, action_name, object_schema,
       object_name, return_code, sessionid, sql_text
FROM unified_audit_trail
WHERE (object_schema='RCONF_OWNER'
       AND object_name IN ('DEMO_PERSONAL','MASKED_PERSONAL','RISKS','RISK_VIEW'))
   OR dbusername IN ('RCONF_APP','RCONF_OWNER')
ORDER BY event_timestamp DESC
FETCH FIRST 100 ROWS ONLY;

PROMPT === 8.20 Sesión actual: información de servicio de red negociado ===
SELECT s.username, s.sid, s.serial#, i.network_service_banner
FROM v$session s
JOIN v$session_connect_info i ON i.sid=s.sid AND i.serial#=s.serial#
WHERE s.audsid=SYS_CONTEXT('USERENV','SESSIONID');

PROMPT === 8.9 Parches SQL registrados ===
SELECT patch_id, patch_type, action, status, action_time, description
FROM dba_registry_sqlpatch
ORDER BY action_time DESC;

PROMPT === 8.11 Prueba positiva/negativa de acceso ===
PROMPT Ejecutar sql/05_verify_runtime.sql conectado como RCONF_APP.
PROMPT La consulta de catálogo no sustituye la prueba de autorización con esa cuenta.
PROMPT Solo SELECT: este archivo no cambia datos, privilegios, usuarios ni políticas.
