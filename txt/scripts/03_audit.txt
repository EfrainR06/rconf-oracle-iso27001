-- Run as authorized DBA / AUDIT_ADMIN in the SAME PDB, after script 02.
-- Review the policy with the DBA; never change global auditing mode automatically.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
CREATE AUDIT POLICY rconf_access_policy
 ACTIONS SELECT ON rconf_owner.risk_view,
         SELECT ON rconf_owner.masked_personal,
         SELECT ON rconf_owner.demo_personal,
         EXECUTE ON rconf_owner.risk_api;
AUDIT POLICY rconf_access_policy BY rconf_app, rconf_review;
PROMPT Generate allowed and denied actions, then query UNIFIED_AUDIT_TRAIL as DBA.
PROMPT The application account is NOT granted AUDIT_ADMIN or AUDIT_VIEWER.
