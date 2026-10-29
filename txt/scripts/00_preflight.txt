-- Read-only. SQL*Plus / SQLcl / SQL Developer (Run Script, F5).
SET LINESIZE 180
SET PAGESIZE 100
SELECT banner_full FROM v$version;
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS container,
       SYS_CONTEXT('USERENV','SESSION_USER') AS connected_user FROM dual;
SELECT name, open_mode FROM v$pdbs;
SELECT name, network_name FROM v$services;
SELECT value AS unified_auditing FROM v$option WHERE parameter = 'Unified Auditing';
PROMPT Confirm Oracle 21c, a READ WRITE lab PDB, USERS tablespace and target service.
PROMPT Do not execute the following scripts in CDB$ROOT or in a production database.
