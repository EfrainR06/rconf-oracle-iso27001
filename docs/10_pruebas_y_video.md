# Recorrido final de pruebas y comparación con el video

Revisión: 28 de octubre de 2026. Referencia visual: video explicativo de Josué Sánchez Salazar, entregado por el estudiante. Las capturas revisadas muestran matriz antes/después, listado de evidencias, SQL y salidas originales. Esta comparación evalúa la presentación visible; no certifica la base del compañero ni reproduce su código o resultados.

## Qué se incorporó a partir de la comparación

- Una biblioteca con los diez archivos SQL reales, visibles y descargables desde **Oracle y scripts**. Cada uno explica cuenta, PDB, efecto, fase PHVA, control y resultado esperado.
- Un recorrido SQL en **Caso de estudio**: contexto (00), diseño de permisos (02), prueba con aplicación (05), revisión DBA (04). Los botones abren el archivo correspondiente.
- Un panel de metadatos actuales: cuenta Oracle, PDB, servicio, objetos visibles, roles, privilegios de sistema y conteos de riesgos/eventos. Solo usa permisos de la cuenta técnica.
- Un visor local de archivos .txt para comparar diagnóstico y repetición. Los archivos no se envían al servidor y desaparecen al recargar. No se generan resultados “antes” ficticios.
- La consulta DBA incluye hora, sesión, identificador de cliente y SQL_TEXT para investigar T11. Esto ayuda a correlacionar; no resuelve automáticamente el hallazgo.

## Lo que aún falta demostrar

El video muestra una medición inicial y otra posterior. En este proyecto hay un escenario inicial hipotético y verificaciones del estado actual; no existe una medición propia previa guardada. No conviene degradar los permisos de la instalación actual para fabricar ese “antes”. Si se necesita un ensayo completo, debe prepararse otra PDB o entorno aislado autorizado y medir ambas etapas con los mismos criterios.

También faltan salidas DBA revisadas para T11, evidencia suficiente de los controles de red, respaldo, eliminación y clones, revisión de la matriz, firma del estudiante y video final. Una gráfica ascendente sin mediciones repetidas no demostraría madurez, por lo que no se añadió una evolución inventada.

## Prueba 1: biblioteca SQL (sin ejecutar instalación)

1. Abrir `http://127.0.0.1:8000/#database`. Deben aparecer diez archivos en la biblioteca aunque aún no haya sesión web.
2. Seleccionar `05_verify_runtime.sql`: debe indicar RCONF_APP y mostrar lecturas permitidas, denegaciones esperadas y ROLLBACK.
3. Cambiar a `04_verify_dba.sql`: debe indicar DBA y mostrar consultas de grants y auditoría con sesión y SQL_TEXT.
4. Descargar y comparar con el archivo de `sql/` en el repositorio. El visor siempre lee el archivo real; no contiene una copia ilustrativa del código.
5. Volver a Caso de estudio y pulsar “Ver 05_verify_runtime.sql”. Debe abrir la biblioteca con ese archivo seleccionado.

## Prueba 2: conexión y persistencia real

1. Conectar una sesión web autorizada desde el encabezado. No mostrar el token durante el video.
2. En Oracle y scripts, pulsar **Consultar estado actual**. Debe devolver RCONF_APP y XEPDB1 si está configurado ese entorno.
3. Revisar objetos visibles: RISK_API, EVENT_VIEW, MASKED_PERSONAL y RISK_VIEW. La lista no es el inventario DBA de todas las tablas.
4. Revisar los conteos de riesgos y eventos. Volver al registro y contrastar que el riesgo guardado aparece. Los conteos de eventos no representan accesos de Unified Audit Trail.
5. Descargar observación JSON, conservar fecha y responsable. Cerrar sesión: los metadatos deben retirarse de la vista y el botón quedar deshabilitado.

## Prueba 3: acceso mínimo con la aplicación

En **Ciclo PHVA**, ejecutar las cuatro comprobaciones locales y descargar JSON. La vista enmascarada y RISK_VIEW deben ser accesibles; DEMO_PERSONAL y RISKS deben ser denegadas. Si una tabla base resulta accesible, el control falla y requiere investigación. La comprobación web usa SELECT fijos y no ejecuta UPDATE ni consultas DBA.

## Prueba 4: SQL original y T11

Desde PowerShell, en la carpeta del proyecto, crear `local-evidence` si no existe y abrir `sqlplus /nolog`. Luego, dentro de SQL*Plus:

1. Conectar como RCONF_APP; introducir contraseña solo en el prompt privado. Confirmar SHOW USER y SHOW CON_NAME.
2. Iniciar `SPOOL local-evidence\runtime_repeticion.txt`, ejecutar `@sql/05_verify_runtime.sql` y finalizar con `SPOOL OFF`.
3. En otra sesión DBA conectada a XEPDB1, iniciar `SPOOL local-evidence\dba_repeticion.txt`, ejecutar `@sql/04_verify_dba.sql` y finalizar SPOOL.
4. Mostrar los .txt en el visor “Después”. Si no hay diagnóstico previo, dejar “Antes” vacío. El visor detecta algunos errores de conexión y alerta, pero la revisión del resultado corresponde a la persona auditora.
5. Correlacionar los eventos de DEMO_PERSONAL usando fecha/hora, cuenta, SESSIONID, CLIENT_IDENTIFIER, sentencia y retorno. Mantener T11 abierto si no se puede explicar el evento con retorno 0.

## Prueba 5: roles y PHVA

Probar con un registro de laboratorio identificado como prueba: analista puede crear en Planificar, pero no cerrar el residual; auditor puede consultar y no escribir; gestor decide en Actuar con evidencia y justificación. Un avance sin evidencia y un salto de fase deben rechazarse. Reabrir la página y comprobar persistencia en Oracle. Registrar los cambios como prueba; no borrar evidencia para ocultar errores.

## Comprobaciones realizadas por la asistencia

- Suite de API/dominio: 15 pruebas aprobadas, con almacén simulado. Incluye autorización, evidencia PHVA, restricción local de comprobaciones, catálogo SQL limitado y rechazo de rutas a archivos privados.
- Oracle real, vía driver y cuenta configurada: snapshot correcto RCONF_APP/XEPDB1; cuatro objetos visibles VALID; un riesgo y dos eventos al consultar. Son valores observados ese día, no contadores fijos del sitio.
- Cuatro SELECT reales: dos vistas permitidas y dos tablas denegadas con ORA-00942. No se ejecutó UPDATE ni se accedió con SYS en esta revisión.
- API de metadatos con rol auditor: HTTP 200 y cuatro objetos visibles. Los secretos se cargaron de la configuración privada y no se imprimieron.
- Archivo local de la ejecución asistida: `local-evidence/revision_driver_2026-10-28.json`. Es resultado del driver; no es un spool de SQL*Plus.

Registrar en cada ensayo propio fecha, cuenta, PDB, responsable, esperado, observado, archivo y conclusión. El guion de cinco minutos debe mostrar un resultado propio que pueda explicarse, incluida cualquier limitación pendiente.
