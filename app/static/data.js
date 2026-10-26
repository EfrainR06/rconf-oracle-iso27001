'use strict';
const PHASES=['Planificar','Hacer','Verificar','Actuar'];
const STATUSES=['Abierto','En tratamiento','Mitigado','Aceptado'];
const CONTROLS=[
 {id:'5.15',title:'Control de acceso',old:'A.9.1.1 / A.9.1.2',kind:'Organizacional',implementation:'Definir acceso por función, activo y necesidad de conocer.',evidence:'Política de acceso aprobada; matriz de autorizaciones.',risk:'R-CONF-001, 002'},
 {id:'5.16',title:'Gestión de identidades',old:'A.9.2.1',kind:'Organizacional',implementation:'Identidades individuales; altas, cambios y bajas trazables.',evidence:'Inventario de cuentas y actas de baja.',risk:'R-CONF-002'},
 {id:'5.17',title:'Información de autenticación',old:'A.9.2.4 / A.9.3.1 / A.9.4.3',kind:'Organizacional',implementation:'Secretos fuera del código; rotación y distribución restringida.',evidence:'Configuración de Key Vault y registro de rotación.',risk:'R-CONF-003'},
 {id:'5.18',title:'Derechos de acceso',old:'A.9.2.2 / A.9.2.5 / A.9.2.6',kind:'Organizacional',implementation:'Aprobar y revisar permisos; revocar al cambiar de función.',evidence:'Comparación de concesiones antes y después.',risk:'R-CONF-001, 002'},
 {id:'5.23',title:'Seguridad en servicios de nube',old:'Nuevo en 2022',kind:'Organizacional',implementation:'Acordar responsabilidades en Azure y proteger la conexión local.',evidence:'Diagrama, configuración TLS y control de acceso a Azure.',risk:'R-CONF-004'},
 {id:'8.2',title:'Derechos de acceso privilegiado',old:'A.9.2.3',kind:'Tecnológico',implementation:'Separar propietario, aplicación y auditor; evitar DBA y privilegios ANY.',evidence:'DBA_SYS_PRIVS y DBA_ROLE_PRIVS revisados.',risk:'R-CONF-001'},
 {id:'8.3',title:'Restricción de acceso a la información',old:'A.9.4.1',kind:'Tecnológico',implementation:'Vistas limitadas y paquete de operaciones; denegar tablas base.',evidence:'Prueba positiva y prueba negativa de SELECT.',risk:'R-CONF-005'},
 {id:'8.9',title:'Gestión de la configuración',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Mantener una línea base revisada de cuentas y listener.',evidence:'Inventario versionado sin secretos.',risk:'R-CONF-002, 004'},
 {id:'8.11',title:'Enmascaramiento de datos',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Vista con datos sustituidos para la demostración. No equivale a Oracle Data Redaction.',evidence:'Resultado de vista enmascarada y denegación de tabla.',risk:'R-CONF-005'},
 {id:'8.12',title:'Prevención de fuga de datos',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Restringir exportaciones y ubicaciones de evidencias. DLP empresarial queda como medida adicional.',evidence:'Política de exportación y revisión de accesos al almacenamiento.',risk:'R-CONF-006'},
 {id:'8.15',title:'Registro de eventos',old:'A.12.4.1 / A.12.4.2 / A.12.4.3',kind:'Tecnológico',implementation:'Auditoría unificada y bitácora transaccional de la aplicación.',evidence:'Eventos de acceso y cambios con fecha y rol.',risk:'R-CONF-007'},
 {id:'8.16',title:'Actividades de monitoreo',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Revisar eventos y atender lecturas anómalas. El sitio no es un SIEM.',evidence:'Revisión periódica y caso de investigación.',risk:'R-CONF-007'},
 {id:'8.24',title:'Uso de criptografía',old:'A.10.1.1 / A.10.1.2',kind:'Tecnológico',implementation:'Cifrar respaldos y proteger conexiones con TLS o canal privado; separar claves y verificar licencias antes de TDE.',evidence:'Prueba de cifrado y gestión de claves.',risk:'R-CONF-004, 008'},
 {id:'8.28',title:'Codificación segura',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Consultas parametrizadas, validación, control de roles y pruebas.',evidence:'Pruebas de autorización e inyección.',risk:'R-CONF-003, 006'}
];
const CONTROL_VERIFICATION={
 '5.15':'Revisar la matriz RCONF_RUNTIME y RCONF_READONLY y los permisos de objeto con una cuenta DBA.',
 '5.16':'Contrastar el inventario de cuentas con DBA_USERS y las actas de alta o baja; requiere cuenta administrativa.',
 '5.17':'Revisar .env y el proceso de rotación en una ubicación restringida; nunca mostrar secretos en la web.',
 '5.18':'Comparar concesiones de RCONF_APP antes y después; completar con 04_verify_dba.sql.',
 '5.23':'Revisar responsabilidades y conectividad del plan Azure; el despliegue todavía no se ha probado.',
 '8.2':'Comprobar DBA_SYS_PRIVS y DBA_ROLE_PRIVS desde una sesión DBA; RCONF_APP no debe tener DBA ni privilegios ANY.',
 '8.3':'Ejecutar la comprobación local de SELECT y el script 05_verify_runtime.sql para lecturas permitidas y denegadas.',
 '8.9':'Conservar salida de 00_preflight.sql, configuración del listener y versión de scripts sin contraseñas.',
 '8.11':'Comparar MASKED_PERSONAL con la denegación de DEMO_PERSONAL en T07; la vista no es Oracle Data Redaction.',
 '8.12':'Revisar permisos y retención del almacén de evidencias y exportaciones; queda fuera de la prueba SELECT.',
 '8.15':'Correlacionar 03_audit.sql con la política activa y el rastro consultado por 04_verify_dba.sql.',
 '8.16':'Investigar T11 en UNIFIED_AUDIT_TRAIL por hora, sesión y sentencia antes de cerrar el hallazgo.',
 '8.24':'Documentar configuración y prueba de TLS o TCPS y custodia de claves; aún no existe prueba de Azure.',
 '8.28':'Revisar las pruebas de autorización de la API y la parametrización; no ejecutar código desde el navegador.'
};
const SEED=[
 [1,'Permisos excesivos en cuentas de aplicación','Esquema de clientes','DBA',4,5,2,5,'Hacer','En tratamiento','2026-11-06','5.18, 8.2','Sustituir DBA por CREATE SESSION y permisos específicos sobre vistas y paquetes.','DEM-001: diseño del rol mínimo; ejecución local pendiente.'],
 [2,'Cuentas de excolaboradores activas','Identidades Oracle','Responsable de accesos',3,4,1,4,'Planificar','Abierto','2026-11-09','5.16, 5.18, 8.9','Revisar cuentas con el dueño del activo y bloquear las que no tengan justificación.',''],
 [3,'Credenciales presentes en código fuente','Secretos de conexión','Desarrollador',4,5,1,5,'Planificar','Abierto','2026-11-03','5.17, 8.28','Extraer secretos a configuración restringida; rotar cualquier credencial expuesta.',''],
 [4,'Tráfico de base de datos sin protección','Canal Azure a Oracle','Administrador de red',3,5,1,5,'Planificar','Abierto','2026-11-10','5.23, 8.24','Configurar canal privado y TCPS; verificar el certificado del servidor.',''],
 [5,'Lectura de datos personales sin necesidad','Datos personales de prueba','Dueño del dato',4,4,1,4,'Verificar','En tratamiento','2026-11-12','8.3, 8.11','Publicar una vista de columnas reducidas y enmascaradas, con tabla base inaccesible.','DEM-005: caso de prueba diseñado; resultado ilustrativo, no ejecutado en Oracle.'],
 [6,'Exportaciones con información sensible','Archivos y evidencias','Responsable de seguridad',3,5,2,5,'Hacer','En tratamiento','2026-11-13','8.12, 8.28','Usar solo datos sintéticos; restringir el almacén de evidencias y revisar exportaciones.','DEM-006: política propuesta, validación pendiente.'],
 [7,'Lecturas indebidas sin trazabilidad','Auditoría de accesos','Auditor',3,4,2,4,'Planificar','Abierto','2026-11-16','8.15, 8.16','Habilitar política de auditoría y definir responsable y frecuencia de revisión.',''],
 [8,'Copias de respaldo accesibles a terceros','Respaldos Oracle','DBA',3,5,1,5,'Planificar','Abierto','2026-11-18','8.24, 5.15','Cifrar copias con herramientas disponibles, restringir lectura y separar claves.','']
].map(r=>({id:r[0],title:r[1],asset:r[2],owner:r[3],probability:r[4],impact:r[5],residual_probability:r[6],residual_impact:r[7],phase:r[8],status:r[9],due:r[10],controls:r[11],treatment:r[12],evidence:r[13],decision:'',version:1}));
const SOURCES=[
 ['ISO/IEC 27001:2022','Requisitos del sistema de gestión','https://www.iso.org/standard/27001'],
 ['ISO/IEC 27002:2022','Guía de controles de seguridad','https://www.iso.org/standard/75652.html'],
 ['ISO/IEC 27001:2013','Ficha histórica de la edición anterior','https://www.iso.org/standard/54534.html'],
 ['ISO/IEC 27002:2013','Ficha histórica de la edición anterior','https://www.iso.org/standard/54533.html'],
 ['ANAB · comparación 2013 y 2022','Cambios en requisitos y controles','https://blog.ansi.org/anab/iso-iec-27001-2013-2022-comparison/'],
 ['ISO/IEC JTC 1/SC 27 · actualización 27002','Explicación de estructura, atributos y correspondencia por los editores de la norma','https://committee.iso.org/files/live/sites/jtc1sc27/files/resources/ISO-IEC%20JTC%201-SC%2027_N22755_SC27%20Journal%20Vol%202%20Issue%202%20(update%20Dec%202022).pdf'],
 ['Oracle · autorización','Privilegios, roles y permisos de objetos','https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-privilege-and-role-authorization.html'],
 ['Oracle · auditoría unificada','Sintaxis de políticas de auditoría','https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-AUDIT-POLICY-Unified-Auditing.html'],
 ['Azure · App Service con Python','Alojamiento de la aplicación','https://learn.microsoft.com/en-us/azure/app-service/quickstart-python'],
 ['Azure · Hybrid Connections','Conexión de App Service a Oracle local','https://learn.microsoft.com/en-us/azure/app-service/app-service-hybrid-connections'],
 ['GlobalSuite · ISO 27002','Lectura complementaria aportada por el estudiante','https://www.globalsuitesolutions.com/es/que-es-la-norma-iso-27002-y-para-que-sirve/']
];

// Resultados transcritos de salidas SQL compartidas por el estudiante el 26-10-2026.
// No equivalen a una revisión independiente ni a una certificación.
const CASE_TESTS=[
 {id:'T07',title:'Vista limitada frente a tabla sensible',controls:'8.3 · 8.11',expected:'MASKED_PERSONAL legible; DEMO_PERSONAL inaccesible.',observed:'RCONF_APP obtuvo Persona 1 con correo [oculto]; SELECT sobre DEMO_PERSONAL devolvió ORA-00942.',status:'Conforme según salida aportada',tone:'pass',proof:'05_verify_runtime.sql · 26 oct 2026',phase:'Verificar'},
 {id:'T08',title:'Acceso mínimo al registro de riesgos',controls:'5.18 · 8.2 · 8.3',expected:'RISK_VIEW legible; RISKS y UPDATE directo denegados.',observed:'RISK_VIEW respondió sin filas en la primera prueba; SELECT y UPDATE sobre RISKS devolvieron ORA-00942.',status:'Conforme según salida aportada',tone:'pass',proof:'05_verify_runtime.sql · 26 oct 2026',phase:'Verificar'},
 {id:'T11',title:'Política y rastro de auditoría',controls:'8.15 · 8.16',expected:'Política habilitada y eventos de acciones permitidas y denegadas.',observed:'RCONF_ACCESS_POLICY figuró activa para RCONF_APP y RCONF_REVIEW. El rastro incluyó códigos 0 y 2004 para DEMO_PERSONAL; falta correlacionar el evento con código 0.',status:'Revisión pendiente',tone:'review',proof:'04_verify_dba.sql · 26 oct 2026',phase:'Verificar'}
];

const AUDIT_NEXT=[
 {priority:'Alta',title:'Correlacionar auditoría',detail:'Relacionar cada evento de UNIFIED_AUDIT_TRAIL con hora, sesión, sentencia y código de retorno; aclarar la fila de DEMO_PERSONAL con código 0.'},
 {priority:'Alta',title:'Cerrar cuenta instaladora',detail:'Ejecutar 06_lock_owner.sql después de terminar las pruebas y comprobar que la aplicación conserva sus funciones.'},
 {priority:'Media',title:'Completar evidencia PHVA',detail:'Conservar salida original, fecha, ejecutor, PDB, resultado esperado y observado para cada EV; revisar la referencia antes de aprobar el residual.'},
 {priority:'Futura',title:'Identidad y canal de Azure',detail:'Planificar identidad individual, MFA, secretos gestionados y conectividad cifrada antes de usar datos reales o publicar el modo Oracle.'}
];
