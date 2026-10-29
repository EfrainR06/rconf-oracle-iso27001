-- Run once as RCONF_CASE_OWNER. All values are synthetic.
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
CREATE TABLE case_clients (id NUMBER PRIMARY KEY, display_name VARCHAR2(60), email VARCHAR2(120));
COMMENT ON TABLE case_clients IS 'SYNTHETIC DATA ONLY - controlled confidentiality case';
COMMENT ON COLUMN case_clients.email IS 'CLASSIF: Restricted (synthetic demonstration)';
INSERT INTO case_clients VALUES (1,'Cliente sintetico 01','cliente01@example.invalid');
CREATE VIEW case_masked AS SELECT id, display_name, CAST('[oculto]' AS VARCHAR2(120)) AS email FROM case_clients;
-- Controlled initial weakness ONLY on this synthetic case table.
GRANT SELECT ON case_clients TO rconf_case_app;
COMMIT;
PROMPT Initial state: case APP can read synthetic raw email, but has no view grant.
