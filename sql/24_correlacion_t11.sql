-- R-CONF | T11 (logs) / 8.15: correlacion de la prueba runtime con Unified Audit.
-- SOLO LECTURA como DBA autorizado en XEPDB1. SQL_TEXT puede ser sensible: revisar antes de compartir.
-- Referencia: local-evidence/05_verify_runtime_2026-10-29_valido.txt
--   CAPTURE_TIME 29-OCT-26 12.22.58.552 AM -06:00 | ACCOUNT RCONF_APP | PDB XEPDB1
-- Para otra ejecucion, cambiar la ventana (hora local de la base) en las dos lineas DEFINE.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET LINESIZE 230
SET PAGESIZE 200
SET TRIMSPOOL ON
SET VERIFY OFF
DEFINE desde = '2026-10-29 00:22:00'
DEFINE hasta = '2026-10-29 00:24:00'
COLUMN ts FORMAT A23
COLUMN action_name FORMAT A10
COLUMN object_name FORMAT A16
COLUMN sql_text FORMAT A62
COLUMN policy_name FORMAT A21
COLUMN audit_option FORMAT A10
COLUMN object_schema FORMAT A12
COLUMN unified_audit_policies FORMAT A22
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20044,'Se requiere la PDB XEPDB1');
 END IF;
END;
/
PROMPT === Contexto ===
SELECT SYSTIMESTAMP AS fecha, USER AS cuenta, SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;

PROMPT === Alcance de la politica: que acciones y objetos genera evidencia ===
SELECT policy_name, audit_option, object_schema, object_name
FROM audit_unified_policies
WHERE policy_name='RCONF_ACCESS_POLICY'
ORDER BY object_name, audit_option;

PROMPT === Eventos de RCONF_APP en la ventana &desde -> &hasta ===
SELECT TO_CHAR(event_timestamp,'YYYY-MM-DD HH24:MI:SS.FF3') AS ts,
       sessionid, action_name, object_name, return_code,
       unified_audit_policies, SUBSTR(sql_text,1,62) AS sql_text
FROM unified_audit_trail
WHERE dbusername='RCONF_APP'
  AND event_timestamp BETWEEN TIMESTAMP '&desde' AND TIMESTAMP '&hasta'
ORDER BY event_timestamp, object_name;

PROMPT === Resumen de la ventana por sesion y codigo ===
SELECT sessionid, return_code, COUNT(*) AS eventos
FROM unified_audit_trail
WHERE dbusername='RCONF_APP'
  AND event_timestamp BETWEEN TIMESTAMP '&desde' AND TIMESTAMP '&hasta'
GROUP BY sessionid, return_code
ORDER BY sessionid, return_code;

PROMPT === Historico total de RCONF_APP por accion y codigo ===
SELECT action_name, return_code, COUNT(*) AS eventos,
       TO_CHAR(MIN(event_timestamp),'YYYY-MM-DD HH24:MI') AS primero,
       TO_CHAR(MAX(event_timestamp),'YYYY-MM-DD HH24:MI') AS ultimo
FROM unified_audit_trail
WHERE dbusername='RCONF_APP'
GROUP BY action_name, return_code
ORDER BY action_name, return_code;

PROMPT
PROMPT Guia de lectura (no es una conclusion automatica):
PROMPT - Comparar cada sentencia del spool runtime con un evento de la misma hora y sesion.
PROMPT - RETURN_CODE 0 sobre DEMO_PERSONAL con SQL_TEXT de MASKED_PERSONAL es el acceso
PROMPT   interno de la vista (derechos del propietario), no una lectura directa de la tabla.
PROMPT - RETURN_CODE 2004 registra un acceso a objeto denegado; el cliente recibio ORA-00942.
PROMPT - Sentencias del spool sin evento (p. ej. RISKS) indican objetos fuera de la politica.

