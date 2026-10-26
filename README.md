# R-CONF Oracle Security Lab

Laboratorio académico para gestionar riesgos de **confidencialidad** en Oracle Database 21c XE con ISO/IEC 27001:2022, ISO/IEC 27002:2022, PHVA y mínimo privilegio.

**Estudiante responsable:** Efrain Retana Segura. Universidad Nacional, Escuela de Informática. **EIF402 Administración de Bases de Datos, II Ciclo 2026.** Docente: Johnny Villalobos Murillo.

## Inicio en Windows

Requisitos: Python 3.12 y acceso a PyPI. En PowerShell, dentro de esta carpeta:

```powershell
.\start-local.ps1
```

Abrir http://127.0.0.1:8000. Inicialmente funciona como demostración: datos sintéticos, cambios en el navegador y exportación JSON. No necesita Oracle para explorar el sitio. El modo demo no usa SQLite ni otro sustituto de Oracle.

## Conectar Oracle

1. Leer [el manual técnico](docs/02_manual_tecnico.md).
2. Ejecutar `sql/00_preflight.sql` como DBA y confirmar la PDB. El listener local anuncia `xepdb1`.
3. Como DBA conectado a la PDB: `sql/01_accounts.sql`.
4. Como RCONF_OWNER: `sql/02_schema.sql`; opcionalmente `sql/02b_seed_demo.sql` para cargar ejemplos sintéticos claramente identificados.
5. Como DBA/AUDIT_ADMIN: `sql/03_audit.sql`.
6. Como RCONF_APP: `sql/05_verify_runtime.sql`. Como DBA: `sql/04_verify_dba.sql`.
7. Como DBA: `sql/06_lock_owner.sql` cuando termine la instalación.
8. Copiar `.env.example` a `.env`, establecer `APP_MODE=oracle`, cuenta RCONF_APP, contraseña y tres tokens distintos de al menos 32 caracteres. Reiniciar el servidor y conectar una sesión en el sitio.

Los scripts son de primera instalación. No son idempotentes ni eliminan objetos anteriores. Ante un error, detenerse y revisar; no repetir la secuencia a ciegas. No se ejecutaron automáticamente cambios en la base de datos del usuario.

## Funciones

- Registro y edición de riesgos, responsable, fecha, controles y tratamiento.
- Matriz de exposición inherente; residual estimado separado.
- PHVA con avance gradual y referencia de evidencia.
- Aprobación residual por gestor; auditor de solo lectura.
- 14 controles seleccionados y correspondencia parcial con 2013.
- Bitácora transaccional Oracle, exportación JSON y fuentes enlazadas.
- Consultas parametrizadas y cuenta sin DBA ni privilegios ANY.

## Documentos

- [Informe académico y comparación normativa](docs/01_informe_academico.md).
- [Manual técnico y Oracle](docs/02_manual_tecnico.md).
- [Despliegue en Azure](docs/03_azure.md).
- [Declaración de IA y registro de contribuciones](docs/04_uso_ia.md).
- [Plan de validación y plantilla de evidencia](docs/05_validacion.md).
- [Fuentes y trazabilidad](docs/06_fuentes.md).

Los cuatro documentos principales se incluyen también como PDF. Los Markdown son editables y versionables. La norma completa no está incluida por estar sujeta a licencia. La matriz de aplicabilidad es parcial y el prototipo no acredita certificación ISO.

## Pruebas

```powershell
.venv\Scripts\python.exe -m pip install -r requirements-dev.txt
.venv\Scripts\python.exe -m pytest -q
```

Las pruebas usan un almacén simulado para verificar las reglas de la API; no sustituyen las pruebas de integración con Oracle. Ver `docs/05_validacion.md` para alcance y evidencia.

## Azure

Se prepara Azure App Service Linux con Gunicorn. No hay dependencia de Cloudflare. El despliegue queda pospuesto por decisión del usuario. El script `azure/deploy-demo.ps1` publica solo la demostración; la conexión real requiere Oracle, secretos y conectividad híbrida configurados según el manual. Los planes de Azure y Relay pueden generar cargos.

## Límites de seguridad

Esta versión es un laboratorio. Los tokens compartidos representan roles, no identifican personas. Para información real se requiere identidad individual y MFA, autorización por activo o tenant, controles de exportación, TLS de extremo a extremo, almacenamiento de evidencias restringido, gestión de incidentes y retención. La bitácora del proyecto no es inmutable frente al DBA. No hay ejecución de SQL arbitrario desde el navegador.

## Integridad académica

El código y los documentos fueron elaborados con asistencia de Codex. No se inventa un historial de prompts ni un porcentaje de autoría del estudiante. Las contribuciones realizadas por el estudiante deben incorporarse con evidencias al registro de IA. El programa del curso requiere autorización docente para uso evaluativo de IA.
