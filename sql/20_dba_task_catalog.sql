-- Instalacion unica en XEPDB1 por DBA. Catalogo de planificacion, no prueba de ejecucion.
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
SET ECHO ON
BEGIN
 IF SYS_CONTEXT('USERENV','CON_NAME') <> 'XEPDB1' THEN RAISE_APPLICATION_ERROR(-20050,'Se requiere XEPDB1'); END IF;
END;
/
DECLARE n NUMBER; BEGIN
 SELECT COUNT(*) INTO n FROM dba_objects WHERE owner='RCONF_OWNER' AND object_name IN ('RCONF_DBA_TASKS','V_DBA_TASKS');
 IF n<>0 THEN RAISE_APPLICATION_ERROR(-20051,'Catalogo existente; no repetir instalacion'); END IF;
END;
/
CREATE TABLE rconf_owner.rconf_dba_tasks (
 task_id VARCHAR2(5 CHAR) PRIMARY KEY, title VARCHAR2(120 CHAR) NOT NULL,
 action_description VARCHAR2(1000 CHAR) NOT NULL, frequency_proposed VARCHAR2(300 CHAR) NOT NULL,
 controls VARCHAR2(240 CHAR) NOT NULL, evidence_expected VARCHAR2(1000 CHAR) NOT NULL,
 reference_script VARCHAR2(100 CHAR) NOT NULL, status VARCHAR2(25 CHAR) DEFAULT 'PENDIENTE' NOT NULL,
 CONSTRAINT rconf_dba_tasks_status CHECK (status IN ('PENDIENTE','EN REVISION','EVIDENCIADO'))
);
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T01','Tarea 01 · usuarios','Altas, bajas, bloqueo y revisión periódica de cuentas.','En cada alta o baja; revision mensual','5.16 · 5.18 · 8.5','DBA_USERS; acta del dueño de cuenta.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T02','Tarea 02 · privilegios','Separar dueño, aplicación y auditor; revisar privilegios directos, roles y ANY.','Por solicitud; revision trimestral','5.15 · 5.18 · 8.2 · 8.3','DBA_SYS_PRIVS, DBA_ROLE_PRIVS, DBA_TAB_PRIVS.','04_verify_dba.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T03','Tarea 03 · autenticación','Aplicar perfiles, expiración/bloqueo proporcionados al entorno y custodia de credenciales.','Configuracion inicial; revision semestral','5.17 · 8.5','DBA_PROFILES y procedimiento de rotación; no revelar secretos.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T04','Tarea 04 · TDE','Determinar necesidad, disponibilidad/licencia y configuración de TDE antes de activarlo.','Al disenar y revisar claves o cambios','8.24','Estado de wallet/cifrado y gestión de claves. No afirmado como habilitado en XE.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T05','Tarea 05 · enmascaramiento','Usar vistas reducidas con datos sintéticos; evaluar Data Redaction/VPD según licencia y arquitectura.','Al cambiar datos o vistas; revision periodica','8.3 · 8.11','Consulta permitida a vista y denegada a tabla base.','05_verify_runtime.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T06','Tarea 06 · respaldo','Restringir archivos, cifrar cuando corresponda, separar claves y validar restauración.','Segun politica; restauracion de prueba','8.13 · 8.24','RMAN, V$BACKUP_PIECE y acta de restauración.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T07','Tarea 07 · auditoría','Configurar eventos relevantes, revisar Unified Audit Trail y escalar anomalías.','Configuracion inicial; revision periodica','5.33 · 8.15 · 8.16','03_audit.sql / 04_verify_dba.sql; correlación pendiente T11.','19_audit_correlation.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T08','Tarea 08 · parches','Mantener versión soportada y planificar parches, pruebas y reversión.','Segun avisos y ventana aprobada','8.9','DBA_REGISTRY_SQLPATCH y registro de cambio.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T09','Tarea 09 · listener/red','Restringir listener y orígenes de conexión; evaluar TLS/TCPS.','Ante cambios de red; revision periodica','8.20 · 8.24','listener.ora, reglas de red, V$SESSION_CONNECT_INFO.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T10','Tarea 10 · eliminación','Aplicar retención y borrado seguro a producción, exportaciones y respaldos según ciclo de vida.','Segun plazos de retencion aprobados','5.12 · 8.10','Política y acta; DBA_RECYCLEBIN es evidencia parcial.','08_auditor_controls.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T11','Tarea 11 · logs','Limitar quién puede consultar y borrar logs; retenerlos y revisarlos.','Revision periodica y ante alertas','5.33 · 8.15 · 8.16','Permisos, retención e investigación documentada.','19_audit_correlation.sql','PENDIENTE');
INSERT INTO rconf_owner.rconf_dba_tasks (task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status) VALUES ('T12','Tarea 12 · clones DEV/TEST','No copiar datos productivos directamente; enmascarar/sintetizar y controlar acceso al clon.','Antes de cada clon o exportacion','5.12 · 8.11 · 8.12','Aprobación, procedimiento de sanitización y evidencia del clon.','08_auditor_controls.sql','PENDIENTE');
CREATE VIEW rconf_owner.v_dba_tasks AS SELECT task_id,title,action_description,frequency_proposed,controls,evidence_expected,reference_script,status FROM rconf_owner.rconf_dba_tasks;
GRANT SELECT ON rconf_owner.v_dba_tasks TO rconf_runtime, rconf_readonly;
COMMIT;
PROMPT Catalogo listo: 12 tareas propuestas; cada ejecucion necesita evidencia real.
