-- READ ONLY as authorized DBA. Restrict exported metadata and remove personal identifiers.
SET LINESIZE 220
SELECT grantee,privilege FROM dba_sys_privs
 WHERE grantee IN ('RCONF_APP','RCONF_REVIEW','RCONF_RUNTIME','RCONF_READONLY') ORDER BY 1,2;
SELECT grantee,granted_role FROM dba_role_privs
 WHERE grantee IN ('RCONF_APP','RCONF_REVIEW','RCONF_RUNTIME','RCONF_READONLY') ORDER BY 1,2;
SELECT grantee,owner,table_name,privilege FROM dba_tab_privs
 WHERE grantee IN ('RCONF_APP','RCONF_REVIEW','RCONF_RUNTIME','RCONF_READONLY') ORDER BY 1,3,4;
-- Check direct grants AND inherited roles. PUBLIC grants can widen effective access.
SELECT grantee,owner,table_name,privilege FROM dba_tab_privs
 WHERE grantee='PUBLIC' AND owner='RCONF_OWNER';
SELECT policy_name,enabled_option,entity_name,success,failure FROM audit_unified_enabled_policies
 WHERE policy_name='RCONF_ACCESS_POLICY';
SELECT event_timestamp,dbusername,action_name,object_schema,object_name,return_code
 FROM unified_audit_trail
 WHERE object_schema='RCONF_OWNER' AND dbusername IN ('RCONF_APP','RCONF_REVIEW')
 ORDER BY event_timestamp DESC FETCH FIRST 100 ROWS ONLY;
PROMPT Capture date, PDB, role, expected result and actual result in the evidence template.
