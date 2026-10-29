-- R-CONF: diagnóstico de solo lectura del estado actual, no un «antes» histórico.
-- Conectar como SYS/DBA en XEPDB1 y conservar el SPOOL para revisión.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET ECHO OFF FEEDBACK ON LINESIZE 200 PAGESIZE 100 TRIMSPOOL ON
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20040,'Se requiere XEPDB1');
 END IF;
END;
/
SELECT SYSTIMESTAMP AS fecha, SYS_CONTEXT('USERENV','SESSION_USER') AS cuenta,
       SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
PROMPT === 5.12 Clasificacion: comentarios de las columnas del laboratorio ===
SELECT table_name, column_name, comments FROM dba_col_comments
 WHERE owner='RCONF_OWNER' AND table_name IN ('DEMO_PERSONAL','RISKS')
 ORDER BY table_name,column_name;
PROMPT === 5.15 5.18 8.2 8.3: privilegios del usuario y roles ===
SELECT grantee, owner, table_name, privilege, grantable FROM dba_tab_privs
 WHERE grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY')
 ORDER BY grantee,owner,table_name,privilege;
SELECT grantee, privilege, admin_option FROM dba_sys_privs
 WHERE grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY') ORDER BY grantee,privilege;
SELECT grantee, granted_role, admin_option FROM dba_role_privs
 WHERE grantee IN ('RCONF_APP','RCONF_RUNTIME','RCONF_READONLY') ORDER BY grantee,granted_role;
PROMPT === 5.16 8.5 Cuentas del laboratorio y perfiles ===
SELECT username,account_status,profile FROM dba_users WHERE username LIKE 'RCONF_%' ORDER BY username;
SELECT profile,resource_name,limit FROM dba_profiles WHERE resource_type='PASSWORD'
 AND profile IN (SELECT profile FROM dba_users WHERE username LIKE 'RCONF_%')
 ORDER BY profile,resource_name;
PROMPT === 5.33 8.15 Politicas de auditoria ===
SELECT policy_name,entity_name,success,failure FROM audit_unified_enabled_policies
 WHERE policy_name LIKE 'RCONF%' ORDER BY policy_name,entity_name;
PROMPT === 8.3 8.11 Objetos de la cuenta de aplicacion ===
SELECT owner,object_name,object_type,status FROM dba_objects WHERE owner='RCONF_OWNER'
 AND object_name IN ('MASKED_PERSONAL','RISK_VIEW','DEMO_PERSONAL','RISKS','RISK_API')
 ORDER BY object_type,object_name;
PROMPT === 8.10 Objetos del esquema en papelera ===
SELECT COUNT(*) AS objetos_en_papelera FROM dba_recyclebin WHERE owner='RCONF_OWNER';
PROMPT === 8.12 Enlaces de base de datos del laboratorio ===
SELECT owner,COUNT(*) AS cantidad FROM dba_db_links WHERE owner LIKE 'RCONF_%' GROUP BY owner;
PROMPT === 8.13 Resumen de piezas de respaldo visibles ===
SELECT COUNT(*) AS piezas, NVL(SUM(CASE WHEN encrypted='YES' THEN 1 ELSE 0 END),0) AS cifradas FROM v$backup_piece;
PROMPT === 8.15 Auditoria del caso: conteos sin SQL ni valores ===
SELECT client_identifier,action_name,object_name,return_code,COUNT(*) AS eventos
 FROM unified_audit_trail WHERE object_schema='RCONF_CASE_OWNER' AND dbusername='RCONF_CASE_APP'
 GROUP BY client_identifier,action_name,object_name,return_code
 ORDER BY client_identifier,action_name,object_name,return_code;
PROMPT === 8.20 Cifrado: informacion de la sesion actual, no de toda la red ===
SELECT i.network_service_banner FROM v$session s JOIN v$session_connect_info i
 ON i.sid=s.sid AND i.serial#=s.serial# WHERE s.audsid=SYS_CONTEXT('USERENV','SESSIONID');
PROMPT === 8.9 Parches SQL registrados ===
SELECT patch_id,action,status,action_time FROM dba_registry_sqlpatch ORDER BY action_time DESC;
PROMPT === Controles sin prueba completa ===
PROMPT Los resultados requieren revisar procedimientos, alcance, configuracion y evidencia externa.
PROMPT Una consulta aislada no demuestra cumplimiento ISO, borrado seguro, DLP, cifrado o recuperacion.
