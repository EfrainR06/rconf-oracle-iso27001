# Guion de presentación y demostración de R-CONF

**Efrain Retana Segura · EIF402 Administración de Bases de Datos · II Ciclo 2026.** Duración sugerida: 8 a 10 minutos. Este guion orienta una explicación con palabras propias; cada resultado mostrado debe corresponder a una ejecución conservada por el estudiante. Faro Servicios S.A. es una empresa ficticia y el estado «antes» es una hipótesis de riesgo, no una medición histórica.

## Preparación antes de presentar

1. Para la versión actual de esta sesión, abrir `http://127.0.0.1:8001/#overview` y confirmar que el encabezado indique **Oracle**, no modo demostración. El iniciador habitual `start-local.ps1` usa el puerto 8000 cuando esté libre. Si aparece «sin sesión», usar **Conectar sesión** con el token del rol pertinente; no mostrarlo ni decirlo en voz alta. Si `/api/config` no indica `oracle`, revisar la configuración local y reiniciar el servidor sin proyectar `.env`.
2. Tener abierto el riesgo registrado y su referencia **EV-001**. Verificar antes de exponer que la referencia describe una prueba real y apunta al archivo o acta original. Si la sesión actual no muestra el riesgo, no presentar el contador vacío como si la base estuviera vacía: conectarse o explicar la limitación. Revisar en PHVA la recomendación y los controles seleccionados; son propuestas que requieren criterio del responsable.
3. Preparar por separado las salidas SQL*Plus de `05_verify_runtime.sql` y `04_verify_dba.sql`, el PDF `07_evidencia_oracle_2026-10-26.pdf` y el PDF `04_uso_ia.pdf`. Si no hay archivos guardados, repetir las consultas y usar `SPOOL` según los pasos de este guion; una nueva ejecución debe rotularse con su propia fecha, no presentarse como una salida antigua. Probar antes el botón **Ejecutar comprobación** y descargar su JSON. Ocultar contraseñas, tokens y cualquier dato personal.
4. Comprobar que los datos de ejemplo son sintéticos. No ejecutar de nuevo scripts de instalación (`01_accounts.sql` y `02_schema.sql`) para la presentación: son de primera instalación. Para repetir pruebas, usar únicamente scripts de verificación con la cuenta indicada.

## 1. Apertura y problema (45 segundos)

**Pantalla:** Vista general y Caso de estudio. **Decir:** «R-CONF es un laboratorio para evaluar riesgos de confidencialidad de bases de datos Oracle 21c XE, usando ISO/IEC 27001 y 27002 de 2022, el ciclo PHVA y mínimo privilegio. El caso Faro Servicios S.A. es ficticio; las pruebas SQL proceden de mi PDB XEPDB1». Señalar el alcance: información sintética, una cuenta de aplicación y acceso a tablas sensibles. No llamarlo auditoría certificada.

## 2. Riesgo y decisión de tratamiento (60 segundos)

**Pantalla:** Registro de riesgos y Controles ISO. Abrir el riesgo creado y mostrar activo, amenaza, probabilidad, impacto, responsable, tratamiento y selector de controles. Filtrar el catálogo por ese riesgo para enseñar medida propuesta, vínculo 2013 y evidencia esperada. **Decir:** «Si la aplicación recibe acceso directo a tablas base, una credencial comprometida expone más datos. Registré el riesgo, estimé exposición inherente y propuse limitar lectura mediante vistas y escritura mediante un paquete». Mostrar los controles 5.18, 8.2 y 8.3 si corresponden al registro real; no modificarlo solo para que coincida con el guion. Explicar que el residual es una estimación sujeta a revisión.

## 3. Ciclo PHVA y EV-001 (60 segundos)

**Pantalla:** Ciclo PHVA y Expediente de evidencias. **Decir:** «Planificar identifica y prioriza; Hacer aplica las restricciones; Verificar contrasta lo esperado con Oracle; Actuar corrige y documenta la decisión residual». Mostrar la recomendación del riesgo, el tratamiento registrado, los controles y la referencia EV-001; explicar exactamente a qué archivo, prueba, fecha y ejecutor remite. Una referencia escrita por sí sola no prueba que el control funcionó. La aplicación exige referencia al avanzar fuera de Planificar y decisión del gestor para cerrar el residual; describir lo que efectivamente se observe en pantalla.

## 4. Controles visibles y prueba positiva/negativa (90 segundos)

**Pantalla:** Caso de estudio y luego Ciclo PHVA → **Ejecutar comprobación**. Explicar el modelo de amenaza y la ruta de control. Mostrar cuenta RCONF_APP, PDB XEPDB1 y cuatro resultados de SELECT: vista enmascarada permitida, tabla personal denegada, vista de riesgos permitida y tabla RISKS denegada. Descargar el JSON. Después mostrar la salida original de `05_verify_runtime.sql`, que incluye la prueba negativa de UPDATE no ejecutada por el botón web. **Decir:** «Una prueba positiva demuestra la función permitida; una negativa comprueba la restricción». La comprobación web conserva solo un resultado técnico; necesita revisión y archivo original para ser evidencia final.

## 5. Auditoría y hallazgo abierto (75 segundos)

**Qué significa T11:** es la verificación de auditoría. Comprueba que `RCONF_ACCESS_POLICY` aparece habilitada y revisa en `UNIFIED_AUDIT_TRAIL` los accesos de `RCONF_APP` y `RCONF_REVIEW`. En la salida compartida aparecieron dos filas para `DEMO_PERSONAL`, una con código 0 y otra con 2004; el ensayo de SQL*Plus para leer la tabla fue denegado con `ORA-00942`. Esas observaciones deben correlacionarse por hora, usuario, acción y objeto. No se debe afirmar que 2004 equivale a `ORA-00942` ni que la fila con código 0 sea necesariamente la lectura directa: podría pertenecer a otra sentencia o sesión.

**Pantalla:** Expediente de evidencias, T11; después, el archivo de salida generado por SQL*Plus. Mostrar la política habilitada, las dos filas de `DEMO_PERSONAL` y la denegación `ORA-00942` en la prueba de runtime. **Decir:** «La política está activa, pero la correspondencia entre el evento y el ensayo aún no está probada. T11 sigue abierto hasta relacionar sentencia, hora y sesión». Dejar visibles ambas filas y la consulta que las produjo.

## 6. Comparación ISO 2013 y 2022 (90 segundos)

**Pantalla:** 2013 vs. 2022. **Decir:** «ISO/IEC 27001 fija requisitos del sistema de gestión; ISO/IEC 27002 orienta la selección e implementación de controles. La edición 2022 reorganizó el catálogo de 27002: de 114 controles en 14 dominios a 93 en cuatro grupos, con once controles nuevos y atributos para clasificarlos. No implica que se hayan eliminado sin más 21 salvaguardas: hubo fusiones y correspondencias». Mostrar al menos dos mapeos pertinentes al caso y explicar por qué la tabla del sitio es una selección académica, no la norma completa. Mencionar en 27001:2022 la planificación de cambios y la mayor claridad sobre procesos e interacciones. Las fuentes oficiales figuran enlazadas en el sitio.

## 7. Uso de IA, límites y cierre (60 segundos)

**Pantalla:** Documentación y PDF `04_uso_ia.pdf`. **Decir:** «La herramienta asistió en borradores de interfaz, código y documentación; el estudiante aportó el alcance, instaló Oracle, ejecutó scripts y compartió las salidas. La declaración separa lo observado de lo pendiente y debe completarse con evidencias verificables de autoría». Mostrar luego la lista de cierre: correlacionar T11, revisar EV-001, ejecutar la comprobación final del propietario instalador y validar identidad, secretos y conexión cifrada antes de Azure con datos reales. Azure está preparado como plan, sin publicación realizada.

## Si el docente pide una prueba en vivo

- **Ver el riesgo guardado:** conectarse en la web con un rol autorizado, abrir Registro de riesgos y buscar el identificador. Mostrar EV-001 y su archivo fuente. No crear datos ficticios como evidencia de producción.
- **Guardar la salida original de runtime:** en PowerShell, ir a la carpeta del proyecto, ejecutar `New-Item -ItemType Directory -Force local-evidence` y abrir `sqlplus /nolog`. En SQL*Plus escribir `CONNECT RCONF_APP@localhost:1521/XEPDB1`; al pedirla, introducir la contraseña. Después ejecutar `SPOOL local-evidence\05_verify_runtime_2026-10-26.txt`, `@sql/05_verify_runtime.sql` y `SPOOL OFF`.
- **Guardar la salida original DBA:** abrir otra sesión `sqlplus /nolog` y escribir `CONNECT sys@localhost:1521/XEPDB1 AS SYSDBA`; introducir la contraseña solo cuando SQL*Plus la solicite. Ejecutar `SPOOL local-evidence\04_verify_dba_2026-10-26.txt`, `@sql/04_verify_dba.sql` y `SPOOL OFF`. La sesión DBA verifica política, privilegios y rastro.
- **Enseñarlas en el video:** abrir los dos `.txt` desde `local-evidence` con Bloc de notas o VS Code. En runtime señalar primero `ACCOUNT` y `PDB`, luego la vista enmascarada permitida y las denegaciones `ORA-00942`; la salida incluye también el intento de UPDATE seguido por rollback. En DBA señalar `RCONF_ACCESS_POLICY`, la consulta a `UNIFIED_AUDIT_TRAIL` y las filas de `DEMO_PERSONAL` con códigos 0 y 2004. Mostrar fecha y nombre del archivo, no contraseñas. La salida anterior compartida en el chat no se convierte retroactivamente en un archivo original: si no la guardaste, la nueva captura `SPOOL` es una ejecución nueva.

## Lista para tener el video listo

1. Reiniciar el servidor local tras actualizar el proyecto; comprobar que `/api/config` indica `oracle` y que la página reconoce la sesión. Un navegador recién abierto necesita reconectar el token.
2. Verificar que el riesgo real aparece en el registro y en PHVA. Filtrar los controles por ese riesgo; preparar una explicación propia del tratamiento y del residual.
3. Ejecutar ante cámara la comprobación local de cuatro SELECT. Mostrar el resultado completo y descargar el JSON sin exponer el token. Si aparece fallo o revisar, investigar y explicarlo; no editar la salida para que parezca conforme.
4. Tener a mano los dos archivos `.txt` creados con `SPOOL`. Confirmar fecha, cuenta, PDB, ejecutor y revisor. T11 sigue abierto hasta correlacionar sentencia, sesión, hora y código de retorno.
5. Abrir la declaración de IA y el informe académico en PDF. Confirmar con el docente la condición de uso evaluativo de IA indicada en el programa antes de entregar. El estudiante debe revisar y poder explicar el código, la configuración y cada resultado mostrado.
6. Hacer una grabación de prueba de 8 a 10 minutos. Revisar que se lean la PDB, el riesgo, los cuatro estados y las fuentes ISO, que el audio sea inteligible y que no aparezcan contraseñas, tokens ni el contenido de `.env`. Conservar el video y las salidas originales en una ubicación restringida.

Para el relato final aún quedan tareas técnicas por cerrar: revisar EV-001 contra el archivo original, correlacionar T11, probar el bloqueo de RCONF_OWNER y repetir las verificaciones tras cambios. Azure sigue planificado y no debe mostrarse como publicado.

## Mensaje final sugerido

«Puedo demostrar lecturas permitidas por vistas y denegaciones de tablas base en Oracle. El registro PHVA organiza tratamiento y evidencia. El hallazgo de auditoría T11 queda abierto y documentado; el proyecto no reclama certificación ni un despliegue Azure ya realizado». Ensayar con las salidas propias, controlar el tiempo y dejar uno o dos minutos para preguntas.
