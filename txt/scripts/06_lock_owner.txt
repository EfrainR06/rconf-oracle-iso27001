-- As authorized DBA, only AFTER schema setup and optional demo seed have succeeded.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
REVOKE CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE FROM rconf_owner;
ALTER USER rconf_owner ACCOUNT LOCK;
PROMPT Owner locked. For maintenance the DBA must explicitly unlock and temporarily authorize DDL.
PROMPT Definer-rights package remains callable by the limited runtime role.
