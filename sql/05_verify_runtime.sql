-- Run as RCONF_APP. Expected denials are intentional; do not stop on those errors.
WHENEVER SQLERROR CONTINUE
SET ECHO ON
SET LINESIZE 180
SET PAGESIZE 100
SELECT SYSTIMESTAMP AS capture_time FROM dual;
SELECT SYS_CONTEXT('USERENV','SESSION_USER') AS account,
 SYS_CONTEXT('USERENV','CON_NAME') AS pdb FROM dual;
PROMPT POSITIVE: limited view must return synthetic masked data.
SELECT * FROM rconf_owner.masked_personal;
PROMPT POSITIVE: risk view must be readable.
SELECT id,version FROM rconf_owner.risk_view;
PROMPT NEGATIVE: raw table must be denied (typically ORA-00942 or ORA-01031).
SELECT * FROM rconf_owner.demo_personal;
PROMPT NEGATIVE: base risk table must be denied.
SELECT * FROM rconf_owner.risks;
PROMPT NEGATIVE: direct update must be denied even with no rows matching.
UPDATE rconf_owner.risks SET version=99 WHERE 1=0;
PROMPT Any unexpected success is a failed control. Investigate before accepting the residual.
ROLLBACK;
