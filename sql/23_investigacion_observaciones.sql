-- R-CONF | Investigacion de dos observaciones del diagnostico del 29/10/2026.
-- SOLO LECTURA como SYS/DBA autorizado. No modifica perfiles, RMAN ni datos.
-- Ejecutar en XEPDB1 y, para el inventario de respaldos, repetir en CDB$ROOT:
-- las vistas V$BACKUP_* y V$RMAN_* muestran informacion del contenedor actual
-- y RMAN normalmente se ejecuta desde la raiz.
-- Observaciones a investigar:
--   (1) tres piezas de respaldo visibles, ninguna marcada como cifrada (8.13 / 8.24)
--   (2) perfil DEFAULT con PASSWORD_VERIFY_FUNCTION = NULL (5.17 / 8.5)
SET LINESIZE 220
SET PAGESIZE 200
SET TRIMSPOOL ON
SET VERIFY OFF
SET FEEDBACK ON
COLUMN handle FORMAT A70
COLUMN value FORMAT A60
COLUMN name FORMAT A40
COLUMN limit FORMAT A30
COLUMN resource_name FORMAT A28
COLUMN profile FORMAT A20
COLUMN username FORMAT A26
COLUMN object_name FORMAT A32
COLUMN wrl_parameter FORMAT A50

PROMPT === Contexto ===
SELECT SYSTIMESTAMP AS fecha, USER AS cuenta,
       SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       SYS_CONTEXT('USERENV','DB_NAME') AS base_datos
FROM dual;

PROMPT
PROMPT ##### OBSERVACION 1: piezas de respaldo y cifrado (8.13 / 8.24) #####
PROMPT === Piezas visibles: estado, dispositivo, cifrado y ubicacion ===
SELECT recid, set_count, piece#, status, device_type, encrypted,
       completion_time, con_id, handle
FROM v$backup_piece
ORDER BY completion_time;

PROMPT === Conjuntos de respaldo: tipo, nivel y fecha ===
SELECT recid, set_count, backup_type, incremental_level, pieces,
       controlfile_included, completion_time
FROM v$backup_set
ORDER BY completion_time;

PROMPT === Contenido: archivos de datos por contenedor en cada conjunto ===
SELECT set_count, con_id, COUNT(*) AS archivos_datos, MIN(completion_time) AS completado
FROM v$backup_datafile
GROUP BY set_count, con_id
ORDER BY set_count, con_id;

PROMPT === Resumen por cifrado ===
SELECT status, encrypted, COUNT(*) AS piezas
FROM v$backup_piece
GROUP BY status, encrypted
ORDER BY status, encrypted;

PROMPT === Configuracion RMAN persistente (vacia = valores por omision, sin cifrado configurado) ===
SELECT conf#, name, value FROM v$rman_configuration ORDER BY conf#;

PROMPT === Algoritmo de cifrado RMAN por omision disponible ===
SELECT algorithm_name, algorithm_description, is_default
FROM v$rman_encryption_algorithms
WHERE is_default='YES';

PROMPT === Estado del keystore / wallet TDE (necesario para cifrado transparente de RMAN) ===
SELECT con_id, wrl_type, status, wallet_type, keystore_mode
FROM v$encryption_wallet
ORDER BY con_id;

PROMPT === Trabajos RMAN recientes registrados ===
SELECT session_key, input_type, status, start_time, end_time
FROM v$rman_backup_job_details
ORDER BY start_time DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT
PROMPT ##### OBSERVACION 2: verificacion de complejidad de contrasenas (5.17 / 8.5) #####
PROMPT === Limites de contrasena del perfil DEFAULT ===
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile='DEFAULT' AND resource_type='PASSWORD'
ORDER BY resource_name;

PROMPT === Perfiles usados por cuentas abiertas no mantenidas por Oracle ===
SELECT profile, account_status, COUNT(*) AS cuentas
FROM dba_users
WHERE oracle_maintained='N'
GROUP BY profile, account_status
ORDER BY profile, account_status;

PROMPT === Cuentas del laboratorio: perfil, autenticacion y versiones de hash ===
SELECT username, account_status, profile, authentication_type, password_versions,
       expiry_date
FROM dba_users
WHERE username LIKE 'RCONF%'
ORDER BY username;

PROMPT === Limite efectivo de PASSWORD_VERIFY_FUNCTION por perfil asignado a RCONF ===
SELECT u.username, u.profile, p.limit AS limite_declarado,
       CASE WHEN p.limit='DEFAULT' THEN d.limit ELSE p.limit END AS limite_efectivo
FROM dba_users u
JOIN dba_profiles p ON p.profile=u.profile AND p.resource_name='PASSWORD_VERIFY_FUNCTION'
JOIN dba_profiles d ON d.profile='DEFAULT' AND d.resource_name='PASSWORD_VERIFY_FUNCTION'
WHERE u.username LIKE 'RCONF%'
ORDER BY u.username;

PROMPT === Funciones de verificacion suministradas por Oracle disponibles en SYS ===
SELECT owner, object_name, object_type, status
FROM dba_objects
WHERE owner='SYS'
  AND object_name IN ('ORA12C_VERIFY_FUNCTION','ORA12C_STRONG_VERIFY_FUNCTION',
                      'ORA12C_STIG_VERIFY_FUNCTION','VERIFY_FUNCTION_11G','VERIFY_FUNCTION')
ORDER BY object_name;

PROMPT === Perfiles que ya declaran una funcion de verificacion ===
SELECT profile, limit
FROM dba_profiles
WHERE resource_name='PASSWORD_VERIFY_FUNCTION'
  AND limit NOT IN ('NULL','DEFAULT')
ORDER BY profile;

PROMPT
PROMPT ##### COMPLEMENTO 8.20: servicios de red negociados por las sesiones RCONF abiertas #####
PROMPT Una linea "AES... Encryption service adapter" aparece solo si se negocio cifrado nativo.
COLUMN network_service_banner FORMAT A95
SELECT s.username, s.sid, s.program, i.network_service_banner
FROM v$session s
JOIN v$session_connect_info i ON i.sid=s.sid AND i.serial#=s.serial#
WHERE s.username LIKE 'RCONF%'
ORDER BY s.sid, i.network_service_banner;

PROMPT
PROMPT Interpretacion: ENCRYPTED=NO indica piezas sin cifrado RMAN; no prueba quien accede al
PROMPT directorio. PASSWORD_VERIFY_FUNCTION=NULL solo afecta contrasenas nuevas o cambiadas.
PROMPT Este script no modifica configuraciones. Cualquier cambio requiere decision y ventana.
