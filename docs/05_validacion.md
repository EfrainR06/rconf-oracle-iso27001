# Plan de validación y registro de evidencias

## Correspondencia con la asignación

La matriz interactiva **Controles ISO** contiene los 15 controles requeridos, madurez 0–4, estado de revisión y brecha; el informe PDF resume la fundamentación. El sitio incluye 12 tareas DBA, 15 pruebas de auditoría externa y un script DBA descargable de consultas de solo lectura: `sql/08_auditor_controls.sql`. No todas las tareas están instaladas ni todas las pruebas ejecutadas. En la autoevaluación inicial no se marca ningún control como Cumple.

## Criterios de madurez usados

- **0 — Sin evidencia disponible:** no se localizó evidencia para la revisión de este laboratorio; no demuestra por sí mismo que el control falte en una organización.
- **1 — Propuesto:** existe diseño, procedimiento o recomendación, pero no se demostró implementación.
- **2 — Parcialmente implementado:** hay parte de la configuración o documentación, pero falta cobertura, revisión o resultado.
- **3 — Implementado y probado en laboratorio:** prueba favorable observada en un entorno acotado; no prueba operación sostenida ni alcance organizacional.
- **4 — Sostenido y revisado:** operación repetida con responsable, revisión independiente, métricas y evidencia vigente.

Niveles iniciales del proyecto: 5.12 (1, No cumple); 5.15 (2, Parcial); 5.16 (1, No cumple); 5.17 (1, No cumple); 5.18 (2, Parcial); 5.33 (1, No cumple); 8.2 (2, Parcial); 8.3 (3, Parcial); 8.5 (1, No cumple); 8.10 (1, No cumple); 8.11 (3, Parcial); 8.12 (1, No cumple); 8.13 (1, No cumple); 8.15 (2, Parcial); 8.20 (1, No cumple). Son valoraciones documentales preliminares basadas en evidencia compartida y diseño del proyecto; el estudiante debe confirmarlas o modificarlas, y fechar la revisión.

## Batería solicitada: 15 pruebas de auditoría externa

El objetivo es que una persona auditora pueda repetir los pasos y observar si se cumple el criterio. **Esperado** expresa el criterio; **estado** distingue salida aportada de evidencia pendiente.

1. **PT-01 — Privilegios (DBA; positiva de revisión):** consultar DBA_SYS_PRIVS, DBA_ROLE_PRIVS y DBA_TAB_PRIVS para RCONF_APP y sus roles. Esperado: sin DBA, ANY ni grant directo innecesario. Herramienta: SQL*Plus y `04_verify_dba.sql`. Estado: consulta de privilegios compartida; conservar spool original y revisar grants heredados.
2. **PT-02 — Vista enmascarada (positiva):** como RCONF_APP consultar MASKED_PERSONAL. Esperado: solo datos sintéticos/campos aprobados. Herramienta: `05_verify_runtime.sql`. Estado: salida aportada T07; Persona 1 y `[oculto]`.
3. **PT-03 — Tabla sensible (negativa):** como RCONF_APP consultar RCONF_OWNER.DEMO_PERSONAL. Esperado: ORA-00942 u ORA-01031. Herramienta: SQL*Plus. Estado: salida aportada T07, ORA-00942.
4. **PT-04 — Vista y tabla de riesgos (positiva/negativa):** leer RISK_VIEW y tratar de leer RISKS. Esperado: vista permitida, base denegada. Herramienta: `05_verify_runtime.sql`. Estado: T08 aportada; la vista estaba vacía.
5. **PT-05 — DML directo (negativa):** UPDATE directo a RISKS, incluso con condición sin coincidencias. Esperado: denegación. Herramienta: `05_verify_runtime.sql`. Estado: T08 aportada; UPDATE denegado.
6. **PT-06 — Identidades:** comparar DBA_USERS, estados y dueño de cuentas. Esperado: justificación vigente y bloqueo de cuenta sobrante. Herramienta: DBA/SQL*Plus y acta. Estado: pendiente de acta completa.
7. **PT-07 — Perfil/autenticación:** cruzar DBA_USERS.PROFILE con DBA_PROFILES y el procedimiento de custodia/rotación. Esperado: política aprobada y aplicada, sin secretos en repositorio. Estado: pendiente.
8. **PT-08 — Clasificación y máscara:** revisar inventario/clasificación y contrastar columnas de vista con tabla base. Esperado: tratamiento acorde a sensibilidad. Herramienta: `05_verify_runtime.sql` e inventario. Estado: ejemplo de datos sintéticos T07; inventario pendiente.
9. **PT-09 — Auditoría:** comprobar política y correlacionar UNIFIED_AUDIT_TRAIL por hora, sesión, usuario y SQL. Esperado: eventos atribuibles y denegaciones investigadas. Herramienta: `03_audit.sql` y `04_verify_dba.sql`. Estado: T11 abierto; código 0 para DEMO_PERSONAL requiere correlación.
10. **PT-10 — Eliminación:** comparar política de retención, DBA_RECYCLEBIN y acta de borrado. Esperado: evidencia de disposición conforme al ciclo de vida; papelera sola no basta. Estado: pendiente.
11. **PT-11 — Respaldo cifrado:** revisar RMAN/V$BACKUP_PIECE, permisos del repositorio, claves y restauración. Esperado: cifrado/acceso acorde a política y restauración comprobada. Estado: pendiente; no se afirma TDE ni respaldo cifrado en XE.
12. **PT-12 — Red:** revisar listener, firewall y V$SESSION_CONNECT_INFO. Esperado: orígenes autorizados y cifrado/integridad apropiados. Estado: pendiente; conexión local no evidencia Azure.
13. **PT-13 — Logs/evidencias:** revisar accesos, retención, escritura/borrado y revisión del almacén. Esperado: custodia restringida e integridad protegida. Estado: pendiente.
14. **PT-14 — Parches/configuración:** revisar DBA_REGISTRY_SQLPATCH contra una línea base y registros de cambio. Esperado: evaluación y despliegue trazables. Estado: pendiente.
15. **PT-15 — Clones DEV/TEST/exportación:** comprobar aprobación y sanitización de clones, datos exportados y destinos. Esperado: sin datos productivos en claro y acceso aprobado. Estado: pendiente.

Las consultas DBA agrupadas para varias de estas comprobaciones están en `sql/08_auditor_controls.sql`. No modifican objetos ni permisos; deben ejecutarse con una cuenta DBA en la PDB XEPDB1. No todas las fuentes son consultables por RCONF_APP. La prueba T07/T08 debe ejecutarse por separado usando la cuenta de aplicación.

## Resultados disponibles

Se ejecutaron 12 pruebas automatizadas de API y dominio con pytest. Resultado inicial: 12 aprobadas. El almacén de datos se simuló; estas pruebas no conectaron a Oracle. También se comprobaron sintaxis JavaScript y respuesta de /health en demostración. La revisión funcional de interfaz se registra en `VERIFICACION.md` al finalizar.

El estudiante compartió salidas de `05_verify_runtime.sql` y `04_verify_dba.sql` ejecutadas en XEPDB1 el 26 de octubre de 2026. T07 y T08 muestran resultados esperados; T11 requiere correlación adicional de una fila de auditoría. Su transcripción y límites figuran en `07_evidencia_oracle_2026-10-26.md`. TCPS, conectividad desde Azure, recuperación y respaldo siguen sin evidencias de ejecución. Para cada ensayo se necesita fecha real, cuenta usada, contenedor, pasos, esperado, observado, conclusión y referencia del archivo original.

El 26 de octubre de 2026 Codex ejecutó en el Oracle local cuatro consultas SELECT predefinidas desde RCONF_APP: vista enmascarada permitida, tabla personal denegada, vista de riesgos permitida y tabla RISKS denegada. Las cuatro devolvieron el resultado esperado; la salida estructurada y su procedencia están en `09_comprobacion_local_2026-10-26.json`. Esta comprobación no ejecutó UPDATE ni consultó el rastro DBA. Si el estudiante presenta la ejecución en video, debe identificarla como comprobación asistida y distinguirla de su propia repetición.

## Casos de aceptación

- T01: sin token, GET /api/risks debe devolver 401 en modo Oracle. Ningún dato debe aparecer.
- T02: token auditor permite lectura y deniega POST/PUT con 403. Debe conservarse el registro sin cambio.
- T03: analista no puede aprobar residual como Mitigado o Aceptado. El gestor solo puede hacerlo en Actuar con evidencia y decisión.
- T04: pasar Planificar a Verificar se rechaza. Pasar Planificar a Hacer sin referencia se rechaza.
- T05: dos sesiones leen la misma versión; guarda la primera y la segunda recibe rechazo por conflicto. No deben perderse cambios.
- T06: texto con caracteres SQL permanece como dato. Revisar que la llamada use parámetros y que la tabla se conserve. La prueba simulada comprueba el flujo; el ensayo real confirma el driver y paquete.
- T07: RCONF_APP consulta MASKED_PERSONAL y obtiene etiqueta genérica y correo oculto; la lectura de DEMO_PERSONAL se deniega con ORA-00942 u ORA-01031. **Observado según salida aportada:** Persona 1, `[oculto]` y ORA-00942.
- T08: RCONF_APP consulta RISK_VIEW; lectura de RISKS y UPDATE directo se deniegan. No debe tener DBA ni privilegios ANY directos o heredados. **Observado según salida aportada:** vista legible sin filas iniciales y ambas operaciones directas con ORA-00942.
- T09: crear y actualizar riesgo mediante el paquete genera RISK_EVENTS. Error antes de commit no debe dejar riesgo actualizado sin evento; comprobar rollback en una transacción de prueba.
- T10: RCONF_REVIEW consulta vistas y no ejecuta RISK_API. Revisar privilegios de rol y concesiones a PUBLIC.
- T11: generar lecturas permitidas y denegadas; consultar UNIFIED_AUDIT_TRAIL como auditor autorizado. Validar política, objeto, cuenta y retorno. **Observado parcialmente:** política habilitada y eventos visibles. DEMO_PERSONAL aparece con códigos 2004 y 0; correlacionar las filas antes de cerrar el caso.
- T12: confirmar HTTPS en Azure y canal híbrido. Detener el agente en un ensayo controlado y verificar error manejado; restaurar y comprobar recuperación.
- T13: verificar TCPS SQL y validación del certificado sin deshabilitar ssl_server_dn_match. No confundir puerto HTTP 5500 con SQL TCPS.
- T14: revisar exportaciones y ubicación de evidencias. Un enlace de evidencia debe apuntar a un recurso restringido, sin contenido sensible en el registro público.
- T15: confirmar que el dueño quedó bloqueado y sin DDL de instalación. Las operaciones autorizadas del paquete deben seguir funcionando.
- T16: edición en demostración persiste al recargar el mismo navegador y no aparece como dato Oracle. La exportación debe incluir mode y advertencia de datos sintéticos.

## Plantilla de evidencia

Identificador EV-____. Riesgo R-CONF-____. Control(es) ____. Fase PHVA ____. Fecha y hora reales ____. Responsable ejecutor ____. Revisor ____. Entorno y PDB ____. Versión/commit ____. Cuenta/rol probado ____. Pasos ejecutados ____. Resultado esperado ____. Resultado observado ____. Conclusión satisfactoria/no satisfactoria ____. Referencia restringida ____. Acción correctiva ____. Próxima revisión ____.

Puede incorporarse una huella SHA-256 del archivo de evidencia para detectar cambios respecto a la versión revisada. La huella no prueba quién creó el archivo ni lo vuelve inmutable. Conservar el archivo original y los permisos del almacenamiento.

## Criterios de revisión

Una prueba negativa es satisfactoria cuando la operación indebida se deniega, y una positiva cuando la operación necesaria funciona con los permisos mínimos. Si la cuenta puede leer la tabla sensible base, el control falla aunque la vista también funcione. Si hay privilegios indirectos amplios, revisar la jerarquía de roles antes de concluir que la cuenta es mínima.

El auditor revisa las referencias y resultados; el gestor decide el residual. El sitio registra roles compartidos de laboratorio, por lo que nombres de ejecutor y revisor deben constar en el acta real. La eficacia se determina con evidencia y contexto; el cálculo de la matriz no la demuestra por sí solo.
