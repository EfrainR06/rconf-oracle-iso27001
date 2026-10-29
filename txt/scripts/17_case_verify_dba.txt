-- READ ONLY: authorized DBA in XEPDB1. Can run before and after remediation.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20040,'This case requires XEPDB1');
 END IF;
END;
/
SET ECHO ON
SET LINESIZE 220
SET PAGESIZE 100
SET LONG 4000
SELECT SYSTIMESTAMP AS capture_time, SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
SELECT username,account_status FROM dba_users WHERE username IN ('RCONF_CASE_OWNER','RCONF_CASE_APP');
SELECT grantee,owner,table_name,privilege FROM dba_tab_privs WHERE grantee='RCONF_CASE_APP' ORDER BY table_name;
SELECT grantee,privilege FROM dba_sys_privs WHERE grantee='RCONF_CASE_APP';
SELECT grantee,granted_role FROM dba_role_privs WHERE grantee='RCONF_CASE_APP';
SELECT policy_name,entity_name,success,failure FROM audit_unified_enabled_policies WHERE policy_name='RCONF_CASE_READ';
SELECT event_timestamp,dbusername,action_name,object_name,return_code,sessionid,client_identifier,sql_text
 FROM unified_audit_trail WHERE object_schema='RCONF_CASE_OWNER'
 AND dbusername='RCONF_CASE_APP' ORDER BY event_timestamp DESC FETCH FIRST 100 ROWS ONLY;
PROMPT Correlate event time, SQL, session and return code. Empty results are not proof of compliance.
