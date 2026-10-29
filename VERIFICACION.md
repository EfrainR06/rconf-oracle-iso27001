# Verificación de la entrega

Fecha local de revisión: 28 de octubre de 2026, America/Costa_Rica.

## Comprobaciones de esta revisión

- 15 pruebas pytest aprobadas de API/dominio con almacén simulado; incluyen catálogo SQL limitado y metadatos autenticados.
- Sintaxis JavaScript y Python correcta en los archivos modificados.
- Oracle real, cuenta RCONF_APP, PDB XEPDB1: RISK_API, EVENT_VIEW, MASKED_PERSONAL y RISK_VIEW visibles y VALID; un riesgo y dos eventos al consultar.
- Cuatro SELECT reales por el driver: vistas accesibles y tablas base denegadas (ORA-00942). Sin UPDATE ni DDL en esta revisión.
- API de metadatos con rol auditor: HTTP 200, cuatro objetos. Sin imprimir secretos.
- Navegador: biblioteca de diez SQL, cambio de script y botones desde Caso de estudio comprobados; código real visible. Vista revisada en el panel estrecho del navegador integrado.
- Visor de evidencia: archivo QA rotulado como ficticio, con SP2-0640 y texto HTML, mostrado como texto y con advertencia de conexión. Archivo de prueba retirado del visor al recargar.
- PDFs de manual técnico, guion y guía de pruebas regenerados.

## Evidencia y alcance

local-evidence/revision_driver_2026-10-28.json contiene la ejecución asistida por Codex; no es un spool de SQLPlus ni trabajo ejecutado personalmente por el estudiante. Las pruebas de rol y PHVA automatizadas usan FakeStore. No hay una nueva ejecución DBA ni resolución de T11.

## Pendiente

- Correlación de T11 y conservación/revisión de spools SQLPlus originales.
- Pruebas completas de escritura, concurrencia y rollback con Oracle en un registro de laboratorio.
- Evidencias de respaldo/cifrado/restauración, red, eliminación y clones DEV/TEST.
- Revisión de madurez, firma y video del estudiante. Azure sigue pospuesto.

Ver docs/10_pruebas_y_video.md para el recorrido reproducible y las diferencias observadas frente al video de referencia.


## Ampliación: comparación y TXT

16 pruebas pytest y 7 pruebas Node del lector de capturas aprobadas. Exportación de los 17 scripts TXT y ZIP revisada. Las fichas antes/después se rotulan PENDIENTE. Scripts 11–17 preparados, sin ejecución DBA ni creación de nuevas cuentas en esta revisión. La gráfica requiere dos capturas válidas del caso; no contiene mediciones inventadas. La comprobación visual de esta ampliación quedó bloqueada por el acceso al navegador integrado; la anterior biblioteca sí había sido revisada en navegador.


Grafica de madurez: 11 pruebas Node aprobadas en total (lector de capturas y calculo por bloques). Se validaron controles faltantes, evidencia/revision incompleta, reducciones de nivel y rechazo de importaciones invalidas. La tabla de uso de IA esta visible en Documentacion; ejemplos ficticios separados y declaracion sin firma. El nuevo ensayo Oracle sigue pendiente de ejecucion DBA.

Revision visual completada tras recuperar el navegador: grafica de lineas, leyenda conmutada, ejemplo rotulado y tabla de IA/declaracion visibles. La vista ilustrativa se retiro al finalizar; los registros reales permanecen pendientes.
