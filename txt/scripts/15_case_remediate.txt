-- Run as RCONF_CASE_OWNER AFTER capturing BEFORE.
-- Changes only the isolated synthetic case, not RCONF_OWNER or RCONF_APP.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20040,'This case requires XEPDB1');
 END IF;
END;
/
BEGIN
 IF USER <> 'RCONF_CASE_OWNER' THEN RAISE_APPLICATION_ERROR(-20041,'Connect as RCONF_CASE_OWNER'); END IF;
END;
/
REVOKE SELECT ON case_clients FROM rconf_case_app;
GRANT SELECT ON case_masked TO rconf_case_app;
PROMPT Treatment applied: raw access revoked, masked view allowed. Repeat probes as case APP.
