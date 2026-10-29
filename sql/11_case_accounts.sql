-- ISOLATED CASE: run once as authorized DBA in XEPDB1.
-- Use two independent passwords: 20-24 letters/digits/underscore only.
-- Synthetic case only. Do not SPOOL passwords. Do not recreate existing accounts.
SET ECHO OFF
SET VERIFY OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN
  RAISE_APPLICATION_ERROR(-20040,'This case requires XEPDB1');
 END IF;
END;
/
ACCEPT case_owner_pwd CHAR PROMPT 'New case OWNER password (hidden): ' HIDE
ACCEPT case_app_pwd CHAR PROMPT 'New case APP password (hidden): ' HIDE
CREATE USER rconf_case_owner IDENTIFIED BY "&case_owner_pwd" DEFAULT TABLESPACE users QUOTA 5M ON users;
CREATE USER rconf_case_app IDENTIFIED BY "&case_app_pwd";
UNDEFINE case_owner_pwd case_app_pwd
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW TO rconf_case_owner;
GRANT CREATE SESSION TO rconf_case_app;
PROMPT Case accounts created. No DBA, ANY or PUBLIC grants.
