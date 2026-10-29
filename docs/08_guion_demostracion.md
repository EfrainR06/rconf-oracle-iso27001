# Guion del video de cinco minutos

**Efrain Retana Segura · EIF402 Administración de Bases de Datos · II Ciclo 2026.** Duración objetivo: 5:00. Ensayar con cronómetro. Faro Servicios S.A. es ficticia; el caso «antes» es una hipótesis, no una medición histórica. Las salidas SQL deben ser originales y no editarse para aparentar éxito.

## Preparación antes de grabar

1. Iniciar el sitio local con `start-local.ps1`; confirmar en la franja que indique **Oracle**. Conectar un rol autorizado si el navegador perdió sesión. No proyectar ni leer tokens, contraseñas o `.env`.
2. Abrir el riesgo guardado y comprobar que EV-001 identifica un archivo real. Si no se encuentra el riesgo, no inventar una salida ni decir que está guardado.
3. Tener listos los archivos originales de `05_verify_runtime.sql` y `04_verify_dba.sql`. Confirmar usuario y PDB en cada spool. Si no se guardaron, generar una ejecución nueva y nombrarla como tal.
4. En la pantalla de inicio de PowerShell, cambiar a la carpeta del repositorio. Crear carpeta de salida si hace falta: `New-Item -ItemType Directory -Force local-evidence`. Escribir `sqlplus /nolog` en PowerShell. Los siguientes comandos van dentro de SQL*Plus, en el prompt `SQL>`.

Para guardar una prueba de aplicación, conectar como RCONF_APP, introducir la contraseña solo en el prompt privado, y confirmar `SHOW USER` / `SHOW CON_NAME`. Debe decir RCONF_APP y XEPDB1. Luego escribir `SPOOL local-evidence\05_verify_runtime_video.txt`, `@sql/05_verify_runtime.sql` y `SPOOL OFF`.

Para la salida DBA, abrir otra sesión `sqlplus /nolog`, escribir `CONNECT sys@localhost:1521/XEPDB1 AS SYSDBA`, confirmar `SHOW USER` / `SHOW CON_NAME`, y usar `SPOOL local-evidence\04_verify_dba_video.txt`, `@sql/04_verify_dba.sql`, `SPOOL OFF`. Si se ven `SP2-0640` o una sesión desconectada, invalidar ese spool y repetir conectado. Nunca ejecutar comandos SQL en el prompt de PowerShell. No vuelvas a ejecutar scripts de instalación para grabar.

## Cronograma y texto sugerido

### 0:00–0:30 — Objetivo

**Pantalla:** Vista general y Caso de estudio. **Decir:** «Este proyecto aborda riesgos de confidencialidad en Oracle 21c XE con controles de ISO/IEC 27001 y 27002 de 2022, PHVA y mínimo privilegio. Faro Servicios S.A. es un caso ficticio; uso datos sintéticos y distingo diseño de resultados SQL observados».

### 0:30–1:05 — Riesgo

**Pantalla:** Registro de riesgos; abrir R-CONF-01 si está guardado. **Decir:** «Una cuenta de aplicación con permisos amplios podría leer datos que no necesita. El riesgo inherente se estima con probabilidad por impacto. El residual es un objetivo de tratamiento, no una reducción medida». Mostrar activo, P, I, responsable y EV-001 solo si la referencia conduce al archivo fuente.

### 1:05–1:45 — Controles y trabajo DBA

**Pantalla:** Controles ISO. **Decir:** «La asignación pide estos 15 controles. El catálogo separa aplicación propuesta, evidencia esperada y correspondencia orientativa con 2013. La matriz de madurez marca No cumple o Parcial cuando faltan pruebas. Aquí se agrupan 12 tareas DBA: identidades, privilegios, autenticación, TDE, máscaras, respaldos, auditoría, parches, red, eliminación, logs y clones de prueba».

### 1:45–2:20 — PHVA y evidencia

**Pantalla:** Ciclo PHVA y Expediente de evidencias. **Decir:** «Planificar evalúa y prioriza; Hacer aplica controles; Verificar ejecuta pruebas positivas y negativas; Actuar corrige y deja al gestor documentar la decisión residual. La referencia EV-001 no prueba por sí sola el control; hay que revisar el archivo, fecha, PDB y resultado».

### 2:20–3:10 — Salida SQL original

**Pantalla:** Oracle y scripts: seleccionar 05_verify_runtime.sql para mostrar cuenta y código; abrir su archivo .txt original en el visor Después. Si no hay medición inicial guardada, dejar Antes vacío. **Decir:** «Esta es la salida de SQL*Plus, ejecutada en XEPDB1 como RCONF_APP. Primero se permitió la vista MASKED_PERSONAL con datos sintéticos y correo oculto. Después se denegó la lectura de DEMO_PERSONAL, se permitió RISK_VIEW y se denegaron RISKS y el UPDATE directo. La transcripción compartida documenta T07/T08; aquí muestro el archivo local guardado». Señalar el resultado completo, sin ocultar errores ni completar una salida a mano.

### 3:10–3:50 — Auditoría T11

**Pantalla:** Abrir la salida DBA o la vista de evidencias. **Decir:** «La política de auditoría se informó activa. T11 mostró para DEMO_PERSONAL códigos 2004 y 0. Todavía falta asociar el evento con la hora, sesión y sentencia. Por eso T11 sigue abierto y no concluyo que el código 0 sea una lectura indebida confirmada». Mostrar ambas filas y la consulta original, si el spool está disponible.

### 3:50–4:25 — 2013 frente a 2022

**Pantalla:** Comparativa. **Decir:** «En ISO/IEC 27002, 2013 tenía 114 controles en 14 dominios; en 2022 hay 93 controles en cuatro grupos, con fusiones, actualizaciones, once nuevos controles y cinco atributos. Menos controles numerados no equivale a menor protección. Mínimo privilegio ya se abordaba antes; en 2022 se relaciona con 5.15–5.18, 8.2 y 8.3». Mostrar un mapeo antiguo y uno nuevo. No proyectar el texto completo de la norma.

### 4:25–5:00 — IA, limitaciones y cierre

**Pantalla:** Documentación, informe PDF e IA. **Decir:** «Codex contribuyó de forma sustancial al sitio, scripts y documentos; declaro prompts reales y distingo sus aportes de mis validaciones. Las pruebas de vistas son preliminares; T11, controles de respaldo y red quedan pendientes. Azure no se ha publicado. El resultado es un laboratorio académico, no una certificación». Cerrar con la lista de pendientes visible y terminar antes de 5:00.

## Cómo presentar los spools SQL

Abra el archivo local desde `local-evidence`; compruebe nombre y fecha. El spool de runtime debe mostrar `ACCOUNT` y `PDB`, consultas positivas y los errores de denegación. El spool DBA debe mostrar la política activa y la consulta a `UNIFIED_AUDIT_TRAIL`. Los errores de conexión `ORA-01017` y `SP2-0640` significan que no se completó esa prueba: no deben presentarse como evidencia favorable. Las contraseñas se escriben solo cuando SQL*Plus las solicita y nunca aparecen en el video.

Si RCONF_APP rechaza la conexión, desde una sesión DBA en XEPDB1 se puede restablecer interactivamente con `PASSWORD RCONF_APP`; no pegar ni registrar la clave en el video. Reconectar y comprobar usuario/PDB antes de iniciar SPOOL. Si la contraseña cambia, la aplicación local también requiere actualizar su configuración privada y reiniciarse.

## Lista final para tener el video listo

- Arrancar la versión local actual y confirmar que muestra Oracle, no modo demostración.
- Confirmar que EV-001 remite a la evidencia real y que el riesgo R-CONF-01 está guardado.
- Tener un spool válido de runtime y otro DBA; explicar qué es T11 y por qué está pendiente.
- Revisar los 15 controles requeridos y los niveles de madurez; no afirmar como propio lo que generó la IA.
- Confirmar que no aparecen secretos, tokens ni datos personales reales.
- Ensayar una vez con cronómetro, comprobar que voz y texto se entiendan, y mantener la grabación en 5:00.
- Firmar personalmente la declaración de IA solo luego de revisar su exactitud. Añadir el video al medio de entrega solicitado por el docente.

## Pendientes que deben quedar claros

Correlacionar T11; revisar EV-001 contra su archivo original; confirmar niveles de madurez; ejecutar o declarar pendientes PT-06 a PT-15; comprobar bloqueo del owner instalador; completar firma y video. Azure está pospuesto y no se presenta como desplegado.


## Apoyo de la nueva vista Oracle y scripts

Antes de grabar, conectar una sesión web, pulsar Consultar estado actual y revisar RCONF_APP/XEPDB1, objetos visibles y conteos. Descargar JSON de esa observación. Para el caso, los botones Ver script abren el SQL real de la biblioteca. Los .txt se muestran localmente y no se suben al servidor. No cargar como evidencia una prueba ficticia o un archivo con sesión desconectada. La guía de pruebas ampliada está disponible en Documentación.
