-- FIRST INSTALL ONLY. Connect as SYS or authorized DBA directly to the LAB PDB.
-- Passwords: use independent random values, 20-64 characters, letters/digits/_ only.
-- This restriction avoids SQL*Plus substitution ambiguities. Never spool this file.
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
SET ECHO OFF VERIFY OFF
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') IN ('CDB$ROOT','PDB$SEED') THEN
   RAISE_APPLICATION_ERROR(-20010,'Connect directly to the lab PDB first.');
 END IF;
END;
/
ACCEPT owner_pwd CHAR PROMPT 'New RCONF_OWNER password (hidden): ' HIDE
ACCEPT app_pwd CHAR PROMPT 'New RCONF_APP password (hidden): ' HIDE
ACCEPT audit_pwd CHAR PROMPT 'New RCONF_REVIEW password (hidden): ' HIDE
CREATE USER rconf_owner IDENTIFIED BY "&owner_pwd" DEFAULT TABLESPACE users QUOTA 30M ON users;
CREATE USER rconf_app IDENTIFIED BY "&app_pwd";
CREATE USER rconf_review IDENTIFIED BY "&audit_pwd";
UNDEFINE owner_pwd app_pwd audit_pwd
CREATE ROLE rconf_runtime;
CREATE ROLE rconf_readonly;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO rconf_owner;
GRANT CREATE SESSION TO rconf_app, rconf_review;
GRANT rconf_runtime TO rconf_app;
GRANT rconf_readonly TO rconf_review;
PROMPT Accounts created. Connect as RCONF_OWNER to the same PDB for script 02.
