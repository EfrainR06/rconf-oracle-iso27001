-- Run once as authorized DBA/AUDIT_ADMIN, after script 12.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20040,'This case requires XEPDB1');
 END IF;
END;
/
CREATE AUDIT POLICY rconf_case_read
 ACTIONS SELECT ON rconf_case_owner.case_clients,
         SELECT ON rconf_case_owner.case_masked,
         UPDATE ON rconf_case_owner.case_clients;
AUDIT POLICY rconf_case_read BY rconf_case_app;
PROMPT Case auditing enabled. Never grant AUDIT_ADMIN to the case APP.
