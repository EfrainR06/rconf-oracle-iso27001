# Alojamiento del laboratorio en Azure

Efrain Retana Segura. EIF402 Administración de Bases de Datos. Universidad Nacional. II Ciclo 2026. Guía del 25 de octubre de 2026.

## Estado y estrategia de despliegue

La aplicación está preparada para Azure App Service Linux con Python 3.12 y Gunicorn. La publicación se dejó para una siguiente etapa por indicación del usuario. Esta guía no afirma que exista un recurso desplegado ni una URL operativa en Azure. No se utiliza Cloudflare.

Se recomienda publicar primero la demostración sin secretos Oracle. Luego configurar conectividad privada e identidad antes de habilitar el modo real. El frontend y la API pertenecen a la misma aplicación y origen; no se envían contraseñas Oracle al navegador. La base Oracle 21c XE permanece en la computadora local, que deberá estar encendida para atender conexiones.

## Datos que se necesitan

Identificador de suscripción, grupo de recursos existente, región, nombre globalmente único para la web y nombre de un App Service Plan Linux. Confirmar permisos sobre ese grupo y revisar el costo del plan y de Azure Relay antes de crear recursos. No se publican claves ni identificadores sensibles en el repositorio. La suscripción fue confirmada por el usuario, pero no se proporcionaron grupo ni región.

## Publicar la demostración

Instalar Azure CLI desde Microsoft e iniciar sesión con `az login`. Seleccionar la suscripción con `az account set --subscription ID`. Revisar `az account show` para evitar usar una suscripción equivocada. El script requiere un grupo ya existente y un nombre nuevo para plan y web; evita sobrescribir recursos con esos nombres.

Desde la carpeta del proyecto:

```powershell
.\azure\deploy-demo.ps1 -SubscriptionId 'ID' -ResourceGroup 'GRUPO' -Location 'REGION' -AppName 'NOMBRE-UNICO' -PlanName 'PLAN-NUEVO'
```

El script crea un plan Linux B1 y una web Python 3.12 en el grupo indicado, activa HTTPS y TLS mínimo 1.2, deshabilita FTP y establece APP_MODE=demo. Empaqueta solo app y requirements.txt; no incluye `.env`, documentos de trabajo, pruebas ni credenciales. Configura la compilación remota y Gunicorn con dos workers y cuatro threads por worker.

El plan B1 es un valor explícito del laboratorio, no una garantía de precio ni de disponibilidad en toda región. Revisar cotización y límites de la suscripción. La creación debe realizarse cuando el usuario retome la publicación; el archivo no se ejecutó durante la preparación.

## Comprobar el primer despliegue

Abrir `https://NOMBRE.azurewebsites.net/health`: debe responder status ok y mode demo. Abrir la raíz y comprobar la etiqueta Modo demostración. Registrar y editar un riesgo sintético, probar filtros y exportación. Las modificaciones de demo permanecen en cada navegador y no son una base de datos compartida.

Si no inicia, revisar los logs desde Azure Portal o `az webapp log tail --resource-group GRUPO --name NOMBRE`. No registrar tokens, cabeceras Authorization ni contenido confidencial. Verificar runtime Python 3.12, requirements.txt en la raíz del ZIP, compilación remota y comando de arranque. Consultar el despliegue y su resultado antes de reenviar paquetes.

## Conectar Oracle local

`localhost` dentro de App Service identifica el servidor de Azure, no la computadora del estudiante. La dirección ORACLE_DSN del despliegue debe usar el nombre DNS del endpoint configurado en la conexión híbrida o una dirección alcanzable por una red privada.

Opción de laboratorio: Azure App Service Hybrid Connections con Azure Relay y Hybrid Connection Manager en Windows. Esta función vincula un nombre de host y puerto TCP con el recurso local. El agente local establece conexión saliente por 443; no exige publicar el listener Oracle como un endpoint de Internet. Se requiere un plan compatible y validar disponibilidad en la suscripción [S12].

1. Confirmar que el listener escucha para el nombre de host elegido y que el servicio xepdb1 está disponible. Preferir un nombre DNS estable del equipo o de la red que alcance el agente.
2. En Azure Portal, abrir la web, Networking, Hybrid connections y crear o agregar la conexión para el host y puerto Oracle. Crear el namespace Relay y la conexión según los permisos disponibles.
3. Instalar Hybrid Connection Manager de Microsoft en un Windows con acceso al listener. Autorizar solo la conexión prevista y comprobar el estado Connected. Proteger el equipo y las credenciales SAS de Relay.
4. Usar exactamente el host configurado en el endpoint al establecer ORACLE_DSN. Por ejemplo, `equipo-oracle:1521/XEPDB1` para un listener TCP de laboratorio; para datos reales configurar TCPS y el puerto SQL correspondiente.
5. Probar desde App Service que se puede consultar RISK_VIEW con la cuenta limitada. Si el agente local se detiene, la base no estará disponible para la web; la API debe devolver un error controlado.

La conexión híbrida protege el transporte por Relay, pero no convierte por sí sola toda conexión Oracle en TCPS. Para confidencialidad de extremo a extremo, configurar certificados y listener SQL TCPS, validar identidad del servidor y probar el wallet. Otra alternativa es integración VNet con VPN hacia la red local; requiere diseño de subredes, DNS, rutas y firewall por separado.

## Secretos e identidad

Configurar ORACLE_USER=RCONF_APP, ORACLE_PASSWORD, ORACLE_DSN y los tres tokens de roles como ajustes del lado servidor. Para una instalación que maneje información real, almacenar secretos en Azure Key Vault y usar referencias desde App Service con identidad administrada. Conceder lectura únicamente de los secretos necesarios, según el modelo RBAC del almacén.

No pegar contraseñas en comandos de ejemplo, workflow YAML, issues, frontend ni archivos `.env` del repositorio. Los ajustes se crean por un canal administrativo restringido. Rotar los valores si se expusieron. El wallet también es un material protegido; no se incorpora al ZIP ni a Git y debe montarse o aprovisionarse por un proceso restringido.

El prototipo usa tokens compartidos por rol para una prueba académica. Antes de manejar información real, integrar Microsoft Entra ID con usuarios individuales y MFA, mapear roles en la API y verificar la autenticación de App Service. No basta con mostrar una pantalla de inicio de sesión: el servidor debe validar emisor, audiencia y autorización de cada operación. Esta integración no está implementada en el paquete actual.

## Habilitar el modo real

Completar primero instalación y pruebas Oracle, conectividad híbrida, secretos y política de acceso. Cambiar APP_MODE a oracle y reiniciar la web. La configuración exige tres tokens distintos de al menos 32 caracteres y credenciales Oracle completas; una configuración incompleta impide iniciar el modo real.

Abrir el sitio y conectar una sesión de auditor: debe consultar sin escribir. Probar analista y gestor por separado. Confirmar que no se puede aprobar residual con analista, leer datos sin token ni escribir directamente en tablas con RCONF_APP. Verificar eventos tanto en la bitácora transaccional como en la auditoría unificada correspondiente.

El endpoint /health solo verifica el proceso. La disponibilidad de Oracle se comprueba con una lectura autorizada de /api/risks. Registrar ambas comprobaciones para no interpretar un proceso sano como una base de datos disponible.

## Responsabilidades y operación

Microsoft administra la infraestructura del servicio; el proyecto administra identidad, secretos, permisos Oracle, clasificación, código, configuración, revisión de eventos y la computadora que aloja Oracle. Esta distribución debe explicarse al revisar 5.23. La política de exportación y el acceso a evidencias requieren decisiones del dueño del dato.

Definir retención de logs y presupuesto, revisar facturación, controlar quién puede cambiar ajustes, y probar restauración de los registros del laboratorio. App Service no respalda automáticamente la base Oracle local. En el proyecto se identificó el riesgo de respaldos expuestos, pero no se automatizaron operaciones RMAN ni cifrado de copias.

## Detención y continuidad

Detener una web no elimina necesariamente el costo del plan. Revisar facturación y recursos compartidos antes de desasignar o eliminar. No borrar un grupo de recursos que contenga otros proyectos. La guía no incluye borrado automático. Guardar la evidencia y configuración necesaria para reconstruir el entorno.

El repositorio privado facilita continuidad. Se puede configurar posteriormente un workflow de despliegue con federación OIDC y permisos limitados para Azure. No se añadió un secreto de publicación ni un workflow que despliegue automáticamente cada push. Esa configuración debe realizarse contra la suscripción y aplicación elegidas.

Referencias: documentación oficial Microsoft Learn de App Service y Hybrid Connections, S11 y S12; documentación del controlador Oracle, S10. Los valores de recursos se eligen al retomar el despliegue.
