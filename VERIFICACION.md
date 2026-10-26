# Verificación de la entrega

Fecha local: 25 de octubre de 2026, America/Costa_Rica.

## Comprobaciones ejecutadas

- pytest: 12 pruebas aprobadas de API y dominio usando un almacén simulado.
- `node --check` sobre app.js y data.js: sin errores de sintaxis.
- Análisis sintáctico de PowerShell sobre deploy-demo.ps1: sin errores.
- HTTP local: raíz y /health responden correctamente; modo demo explícito.
- Interfaz: panel visible con ocho escenarios sintéticos y referencias DEM; navegación al registro, documentación y bitácora comprobada.
- Formulario: intento de avanzar Planificar a Hacer sin evidencia rechazado con mensaje visible.
- Guardado: registro sintético R-CONF-002 guardado sin alterar su evaluación ni fase; actualización visible en la bitácora del navegador.
- Búsqueda: filtro por credenciales devuelve el escenario R-CONF-003.
- PDF: cuatro documentos, 14 páginas en total (5 + 4 + 3 + 2), renderizados y revisados visualmente; límites de texto comprobados sin recortes.
- Listener Oracle local: versión 21, servicio xepdb1 anunciado en TCP 1521.

## Pendiente de ejecución

- Instalación de cuentas, objetos y política de auditoría en Oracle. No se ejecutaron scripts de escritura sobre la base local.
- Pruebas de integración con las cuentas reales, denegación de tabla y DML, auditoría unificada, rollback y concurrencia en Oracle.
- TCPS SQL, gestión de certificados y wallet.
- Despliegue y conectividad híbrida en Azure, pospuestos por el usuario.
- Autenticación individual Entra ID, MFA y autorización por activo para uso con información real.
- Verificación funcional en dispositivos móviles reales.

La evidencia visual `vista-previa.png` muestra la demostración local. Ningún resultado simulado se presenta como control Oracle verificado. La guía 05_validacion.md permite registrar las comprobaciones pendientes.
