# Pruebas por objetivo: Oracle 21c XE y la aplicación R-CONF

Alcance: laboratorio XEPDB1 con datos sintéticos. La evidencia debe incluir fecha, cuenta, PDB, resultado y revisión. No incluir contraseñas en SPOOL. Las pruebas administrativas requieren una sesión DBA autorizada; la consola `abrir-oracle-app.cmd` utiliza únicamente RCONF_APP y no admite cambiar de usuario.

## 1. Identificar y clasificar cinco riesgos

Abrir Registro de riesgos en modo Oracle y registrar o revisar como mínimo cinco riesgos de confidencialidad distintos, con activo, probabilidad e impacto 1–5, tratamiento y controles. No contar los ejemplos de demostración como registros de Oracle. Con RCONF_APP, capturar:

```sql
SPOOL local-evidence/18_riesgos.txt
@sql/18_risk_inventory.sql
SPOOL OFF
```

La salida muestra conteo y nivel inherente; comprobar individualmente en la página que sean riesgos pertinentes. Cinco filas no acreditan por sí solas la calidad del análisis.

## 2. Mapear doce tareas críticas

Abrir Caso de estudio, conectar sesion Oracle y revisar la tabla cargada desde RCONF_OWNER.V_DBA_TASKS: tareas, riesgo, control y evidencia esperada. El catalogo fue instalado una vez con sql/20_dba_task_catalog.sql; no repetir el instalador en XEPDB1. Los estados PENDIENTE son planes, no resultados de ejecucion. Deben figurar usuarios, privilegios, autenticación, TDE, enmascaramiento, respaldo, auditoría, parcheo, listener, eliminación, logs y clones. El mapeo documentado no demuestra que las doce tareas estén ejecutadas.

## 3. Seleccionar y justificar controles

Abrir Controles ISO y verificar los 15 identificadores pedidos y sus justificaciones, relación con riesgos y evidencias. Completar con las observaciones de `08_auditor_controls.sql` en una sesión DBA y con la prueba runtime del paso 5. La consulta de catálogo no prueba políticas, autorizaciones o procesos empresariales.

## 4. Evaluar madurez, evidencia y estado

En Controles ISO revisar la matriz y sus estados iniciales. En Auditoría antes/después registrar los niveles 0–4, referencias y revisión humana para cada control. Guardar la matriz en Oracle; opcionalmente exportar el expediente JSON. Las curvas intermedias son calculadas; no introducir los datos de ejemplo como mediciones. El estado Cumple/No cumple/Parcial requiere revisión de la evidencia.

## 5. Ejecutar pruebas técnicas

Con RCONF_APP en XEPDB1 ejecutar `05_verify_runtime.sql` y conservar SPOOL: vistas permitidas, tablas base y UPDATE denegados. La captura existente `local-evidence/05_verify_runtime_2026-10-29_valido.txt` fue revisada; registrar la referencia.

En una sesión DBA separada y confirmada en XEPDB1 ejecutar con SPOOL `04_verify_dba.sql`, `08_auditor_controls.sql` y `19_audit_correlation.sql`. El script 19 correlaciona hora, cuenta, sesión, objeto, sentencia y código. Revisar contenido antes de compartir. La ausencia de eventos no prueba auditoría; T11 sigue pendiente hasta explicar sus eventos. Consultas de parches, red, backup y papelera no sustituyen evidencia de parcheo, canal, restauración, borrado ni clon.

Para una medición reproducible antes/después del mismo control, seguir `docs/11_caso_antes_despues.md` y los scripts 11–17. Es un escenario aislado con una concesión deliberada en una tabla sintética; solo ejecutarlo en el laboratorio y seguir el orden. En el laboratorio local hay capturas del 29 de octubre de 2026; revisar su procedencia, los eventos de auditoria y la decision antes de concluir.

## Pendientes manuales

La disponibilidad/licencia TDE, restauración de backup, protección del listener/canal, borrado seguro, custodia de logs y sanitización de clones necesitan comprobaciones o actas adicionales. Una vista sintética no demuestra Oracle Data Redaction. Sin evidencia, mantener el control pendiente o parcial. Guardar el expediente, revisar la declaración de IA y preparar la presentación.

La asignación de gestión de respaldos RMAN aportada por el estudiante es otro proyecto enfocado en disponibilidad e integridad. Como referencia para 8.13, documentar qué, cómo y cuándo se respalda, resultado, ubicación, responsable y prueba de recuperación; añadir cifrado, acceso a las piezas y custodia de claves para el riesgo de confidencialidad. Consultar `V$BACKUP_PIECE` por sí solo no valida restauración ni seguridad. R-CONF no constituye la herramienta de programación y ejecución de RMAN descrita en esa asignación.

## Guardar evaluaciones y mostrar la grafica con evidencia real

1. Conectar la aplicacion en modo Oracle con un rol analista o gestor.
2. Abrir Caso de estudio > Recorrido paso a paso > Matriz de evaluacion. Registrar en Antes y Despues el nivel 0-4, la referencia de archivo, fecha y revisor, el estado y la revision de cada control. Los estados son decisiones del revisor, no se deducen automaticamente.
3. Pulsar Guardar matriz en Oracle. La vista V_PROJECT_DATA y el paquete PROJECT_API limitan el acceso; la tabla base no se concede a la cuenta de aplicacion.
4. En Auditoria antes/despues, asignar el bloque a cada control y guardar de nuevo. Una linea por riesgo se dibuja cuando todos sus controles tienen niveles de ambas etapas, referencias, bloque y revision. La media requiere los 20 controles. Las posiciones intermedias son calculadas.
5. Las tres pruebas del caso aislado ya tienen salidas copiadas en Oracle y originales en local-evidence/antes y local-evidence/despues. Son evidencia para revisar 8.3 y 8.11, pero por si solas no prueban la madurez de todos los controles. La revisión independiente de la correlación DBA y las valoraciones sigue pendiente.

El 29 de octubre se ejecutó `22_diagnostico_actual.sql` como SYS en XEPDB1, sin modificar configuraciones. La salida original `local-evidence/diagnostico_actual_2026-10-29.txt` se guardó también en Oracle. Se añadieron valoraciones preliminares del estado actual y referencias a la matriz. Las filas sin prueba anterior o revisión completa siguen pendientes; los valores deben ser revisados por el estudiante. La consulta observó tres piezas de respaldo y ninguna marcada como cifrada, además de un perfil DEFAULT con función de verificación de contraseña NULL; investigar su alcance antes de concluir o cambiar la configuración.
