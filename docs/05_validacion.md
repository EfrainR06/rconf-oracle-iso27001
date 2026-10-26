# Plan de validación y registro de evidencias

## Resultados disponibles

Se ejecutaron 12 pruebas automatizadas de API y dominio con pytest. Resultado inicial: 12 aprobadas. El almacén de datos se simuló; estas pruebas no conectaron a Oracle. También se comprobaron sintaxis JavaScript y respuesta de /health en demostración. La revisión funcional de interfaz se registra en `VERIFICACION.md` al finalizar.

El estudiante compartió salidas de `05_verify_runtime.sql` y `04_verify_dba.sql` ejecutadas en XEPDB1 el 26 de octubre de 2026. T07 y T08 muestran resultados esperados; T11 requiere correlación adicional de una fila de auditoría. Su transcripción y límites figuran en `07_evidencia_oracle_2026-10-26.md`. TCPS, conectividad desde Azure, recuperación y respaldo siguen sin evidencias de ejecución. Para cada ensayo se necesita fecha real, cuenta usada, contenedor, pasos, esperado, observado, conclusión y referencia del archivo original.

El 26 de octubre de 2026 Codex ejecutó en el Oracle local cuatro consultas SELECT predefinidas desde RCONF_APP: vista enmascarada permitida, tabla personal denegada, vista de riesgos permitida y tabla RISKS denegada. Las cuatro devolvieron el resultado esperado; la salida estructurada y su procedencia están en `09_comprobacion_local_2026-10-26.json`. Esta comprobación no ejecutó UPDATE ni consultó el rastro DBA. El estudiante debe revisar y repetir la prueba ante cámara si desea presentarla como trabajo propio observado.

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
