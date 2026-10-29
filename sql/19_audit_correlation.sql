-- Objetivo 5. Solo lectura como DBA autorizado en XEPDB1.
-- SQL_TEXT puede contener datos sensibles: revisar antes de compartir el spool.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET ECHO ON
SET LINESIZE 220
SET PAGESIZE 100
SET LONG 2000
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20044,'Se requiere la PDB XEPDB1');
 END IF;
END;
/
SELECT SYSTIMESTAMP AS fecha, USER AS cuenta,
       SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
PROMPT === Politica de auditoria configurada ===
SELECT policy_name, enabled_option, entity_name, success, failure
FROM audit_unified_enabled_policies WHERE policy_name='RCONF_ACCESS_POLICY';
PROMPT === Eventos recientes para RCONF_APP y objetos de RCONF_OWNER ===
SELECT event_timestamp, dbusername, action_name, object_name, return_code,
       sessionid, client_identifier, sql_text
FROM unified_audit_trail
WHERE dbusername='RCONF_APP' AND object_schema='RCONF_OWNER'
ORDER BY event_timestamp DESC FETCH FIRST 100 ROWS ONLY;
PROMPT Correlacionar fecha, sesion, objeto, sentencia y codigo con el spool runtime.
PROMPT Un codigo 0 indica exito de ese evento; investigar su sentencia y sesion.
PROMPT No obtener filas no demuestra que la auditoria funciona.
