-- Optional reversal of THIS policy only. Run as authorized AUDIT_ADMIN in same PDB.
-- Keep evidence according to retention policy. This does not delete accounts or data.
NOAUDIT POLICY rconf_access_policy BY rconf_app, rconf_review;
DROP AUDIT POLICY rconf_access_policy;
