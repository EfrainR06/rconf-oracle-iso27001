# Expediente preliminar de pruebas Oracle

Efrain Retana Segura · EIF402 Administración de Bases de Datos · II Ciclo 2026. Fecha de las salidas compartidas: 26 de octubre de 2026. Entorno declarado: Oracle Database 21c XE 21.3, PDB XEPDB1. Alcance: controles de confidencialidad R-CONF.

## Procedencia y límite

Este expediente transcribe las salidas de SQL*Plus que el estudiante compartió durante la instalación y las pruebas. No es una revisión independiente de la PDB ni reemplaza los archivos originales de salida. El estudiante debe conservarlos en una ubicación restringida y completar hora, ejecutor, revisor, versión del código y firma de revisión antes de presentar el acta como evidencia final.

El caso narrativo de Faro Servicios S.A. en el sitio es ficticio. El estado “antes” representa una hipótesis de permisos excesivos; no se midió una configuración histórica de esa empresa ni de la PDB.

## Instalación reportada

Se confirmó XEPDB1 en modo READ WRITE. El propietario RCONF_OWNER ejecutó `02_schema.sql` tras concederse CREATE SEQUENCE, necesario para las columnas identity de este laboratorio. La salida reportó tablas, vistas, paquete y concesiones creados sin errores de compilación. Como SYS en XEPDB1 se ejecutó `03_audit.sql` y la salida indicó que la política se creó y habilitó. Estas operaciones deben asociarse a sus registros de consola originales.

## T07 · Vista limitada y tabla sensible

Cuenta: RCONF_APP. Resultado esperado: SELECT en RCONF_OWNER.MASKED_PERSONAL permitido y SELECT en RCONF_OWNER.DEMO_PERSONAL denegado. Resultado observado en `05_verify_runtime.sql`: la vista devolvió `Persona 1` y correo `[oculto]`; la tabla base devolvió ORA-00942. Evaluación preliminar: conforme según la salida aportada. Controles relacionados: 8.3 y 8.11. La vista de este proyecto no equivale a Oracle Data Redaction ni a anonimización de datos reales.

## T08 · Registro de riesgos y DML directo

Cuenta: RCONF_APP. Resultado esperado: SELECT en RCONF_OWNER.RISK_VIEW permitido; SELECT y UPDATE directos sobre RCONF_OWNER.RISKS denegados. Resultado observado en `05_verify_runtime.sql`: RISK_VIEW respondió `no rows selected` en esa primera prueba; SELECT y UPDATE sobre RISKS devolvieron ORA-00942. Posteriormente el estudiante reportó haber creado un riesgo en la web, pero esa operación debe documentarse con su propia captura o acta. Evaluación preliminar de la restricción SQL: conforme según la salida aportada. Controles relacionados: 5.18, 8.2 y 8.3.

## T11 · Política y rastro de auditoría

Cuenta de consulta: SYS en XEPDB1. `04_verify_dba.sql` mostró `RCONF_ACCESS_POLICY` habilitada para RCONF_APP y RCONF_REVIEW, con auditoría de éxitos y fallos. El rastro mostró código 0 para lecturas de MASKED_PERSONAL y RISK_VIEW. También aparecieron dos registros de DEMO_PERSONAL para RCONF_APP, uno con código 2004 y otro con código 0. SQL*Plus sí mostró ORA-00942 en la prueba negativa.

Evaluación: revisión pendiente. Se debe correlacionar cada fila de `UNIFIED_AUDIT_TRAIL` con hora, sesión, sentencia, objeto y contexto antes de concluir que todos los eventos representan exactamente las pruebas previstas. No se interpreta el código 2004 como equivalente automático de ORA-00942 ni se oculta la fila de código 0. Controles relacionados: 8.15 y 8.16.

## Trabajo pendiente para el cierre

- Registrar T09: creación y actualización mediante RISK_API con evento correspondiente y prueba de rollback controlado.
- Probar T02 y T03: auditor web de solo lectura y aprobación residual exclusiva del gestor.
- Correlacionar T11 y adjuntar salida SQL original con fecha, sesión y consulta utilizada.
- Ejecutar T15 solo al terminar la instalación: bloquear RCONF_OWNER y revocar privilegios DDL temporales con `06_lock_owner.sql`; luego repetir operaciones permitidas.
- Documentar EV-001 del riesgo registrado en la web con resultado esperado y observado, archivo original, ubicación restringida y revisor. Una referencia escrita en el formulario no acredita por sí sola la ejecución.

## Plantilla de cierre por prueba

ID de prueba: ____ · Riesgo: ____ · Controles: ____ · Fecha y hora: ____ · Ejecutor: ____ · Revisor: ____ · PDB: ____ · Cuenta: ____ · Comando: ____ · Esperado: ____ · Observado: ____ · Archivo original: ____ · Ubicación restringida: ____ · Conclusión: ____ · Acción correctiva: ____.
