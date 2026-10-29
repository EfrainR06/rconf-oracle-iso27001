'use strict';
const PHASES=['Planificar','Hacer','Verificar','Actuar'];
const STATUSES=['Abierto','En tratamiento','Mitigado','Aceptado'];
let CONTROLS=[
 {id:'5.12',title:'Clasificación de la información',old:'A.8.2.1 / A.8.2.2',kind:'Organizacional',implementation:'Clasificar activos y columnas por sensibilidad; definir quién puede consultar, exportar y conservar cada conjunto.',evidence:'Inventario de datos aprobado, etiquetas y reglas de manejo.',risk:'R-CONF-05, 006',required:true},
 {id:'5.15',title:'Control de acceso',old:'A.9.1.1 / A.9.1.2',kind:'Organizacional',implementation:'Definir acceso por función, activo y necesidad de conocer.',evidence:'Política de acceso aprobada; matriz de autorizaciones.',risk:'R-CONF-01, 002'},
 {id:'5.16',title:'Gestión de identidades',old:'A.9.2.1',kind:'Organizacional',implementation:'Identidades individuales; altas, cambios y bajas trazables.',evidence:'Inventario de cuentas y actas de baja.',risk:'R-CONF-02'},
 {id:'5.17',title:'Información de autenticación',old:'A.9.2.4 / A.9.3.1 / A.9.4.3',kind:'Organizacional',implementation:'Secretos fuera del código; rotación y distribución restringida.',evidence:'Configuración de Key Vault y registro de rotación.',risk:'R-CONF-03'},
 {id:'5.18',title:'Derechos de acceso',old:'A.9.2.2 / A.9.2.5 / A.9.2.6',kind:'Organizacional',implementation:'Aprobar y revisar permisos; revocar al cambiar de función.',evidence:'Comparación de concesiones antes y después.',risk:'R-CONF-01, 002'},
 {id:'5.33',title:'Protección de registros',old:'A.18.1.3',kind:'Organizacional',implementation:'Proteger registros de auditoría y evidencia frente a lectura, alteración y borrado no autorizado; definir retención y custodia.',evidence:'Política de retención, responsables, permisos y revisión de integridad.',risk:'R-CONF-06, 007',required:true},
 {id:'5.23',title:'Seguridad en servicios de nube',old:'Nuevo en 2022',kind:'Organizacional',implementation:'Acordar responsabilidades en Azure y proteger la conexión local.',evidence:'Diagrama, configuración TLS y control de acceso a Azure.',risk:'R-CONF-04'},
 {id:'8.2',title:'Derechos de acceso privilegiado',old:'A.9.2.3',kind:'Tecnológico',implementation:'Separar propietario, aplicación y auditor; evitar DBA y privilegios ANY.',evidence:'DBA_SYS_PRIVS y DBA_ROLE_PRIVS revisados.',risk:'R-CONF-01'},
 {id:'8.3',title:'Restricción de acceso a la información',old:'A.9.4.1',kind:'Tecnológico',implementation:'Vistas limitadas y paquete de operaciones; denegar tablas base.',evidence:'Prueba positiva y prueba negativa de SELECT.',risk:'R-CONF-05'},
 {id:'8.5',title:'Autenticación segura',old:'A.9.4.2 / A.9.4.3',kind:'Tecnológico',implementation:'Aplicar autenticación individual y políticas robustas; no compartir credenciales de personas ni guardar contraseñas en el repositorio.',evidence:'Perfiles Oracle, revisión de cuentas y evidencia de autenticación protegida.',risk:'R-CONF-02, 003',required:true},
 {id:'8.9',title:'Gestión de la configuración',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Mantener una línea base revisada de cuentas y listener.',evidence:'Inventario versionado sin secretos.',risk:'R-CONF-02, 004'},
 {id:'8.11',title:'Enmascaramiento de datos',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Vista con datos sustituidos para la demostración. No equivale a Oracle Data Redaction.',evidence:'Resultado de vista enmascarada y denegación de tabla.',risk:'R-CONF-05'},
 {id:'8.10',title:'Eliminación de información',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Definir plazos de conservación y eliminación segura en producción; considerar copias, exportaciones, papelera de reciclaje y respaldos.',evidence:'Calendario aprobado y acta verificable de eliminación; la consulta de DBA_RECYCLEBIN es solo una comprobación parcial.',risk:'R-CONF-06',required:true},
 {id:'8.12',title:'Prevención de fuga de datos',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Restringir exportaciones y ubicaciones de evidencias. DLP empresarial queda como medida adicional.',evidence:'Política de exportación y revisión de accesos al almacenamiento.',risk:'R-CONF-06'},
 {id:'8.13',title:'Respaldo de la información',old:'A.12.3.1',kind:'Tecnológico',implementation:'Respaldar con frecuencia acordada, restringir acceso, separar custodia de claves y cifrar cuando el motor y licenciamiento lo permitan.',evidence:'Salida RMAN, estado de cifrado, permisos del repositorio y prueba de restauración.',risk:'R-CONF-08',required:true},
 {id:'8.15',title:'Registro de eventos',old:'A.12.4.1 / A.12.4.2 / A.12.4.3',kind:'Tecnológico',implementation:'Auditoría unificada y bitácora transaccional de la aplicación.',evidence:'Eventos de acceso y cambios con fecha y rol.',risk:'R-CONF-07'},
 {id:'8.16',title:'Actividades de monitoreo',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Revisar eventos y atender lecturas anómalas. El sitio no es un SIEM.',evidence:'Revisión periódica y caso de investigación.',risk:'R-CONF-07'},
 {id:'8.24',title:'Uso de criptografía',old:'A.10.1.1 / A.10.1.2',kind:'Tecnológico',implementation:'Cifrar respaldos y proteger conexiones con TLS o canal privado; separar claves y verificar licencias antes de TDE.',evidence:'Prueba de cifrado y gestión de claves.',risk:'R-CONF-04, 008'},
 {id:'8.20',title:'Seguridad de redes',old:'A.13.1.1 / A.13.1.2 / A.13.1.3',kind:'Tecnológico',implementation:'Restringir listener y rutas de red a orígenes autorizados; proteger el tráfico con TLS/TCPS y revisar reglas.',evidence:'Configuración del listener, reglas de red y negociación cifrada documentada.',risk:'R-CONF-04',required:true},
 {id:'8.28',title:'Codificación segura',old:'Nuevo en 2022',kind:'Tecnológico',implementation:'Consultas parametrizadas, validación, control de roles y pruebas.',evidence:'Pruebas de autorización e inyección.',risk:'R-CONF-03, 006'}
];
let CONTROL_VERIFICATION={
 '5.15':'Revisar la matriz RCONF_RUNTIME y RCONF_READONLY y los permisos de objeto con una cuenta DBA.',
 '5.16':'Contrastar el inventario de cuentas con DBA_USERS y las actas de alta o baja; requiere cuenta administrativa.',
 '5.17':'Revisar .env y el proceso de rotación en una ubicación restringida; nunca mostrar secretos en la web.',
 '5.18':'Comparar concesiones de RCONF_APP antes y después; completar con 04_verify_dba.sql.',
 '5.12':'Revisar inventario de datos, clasificación y reglas aprobadas para uso y exportación.',
 '5.33':'Revisar permisos, retención, responsables e integridad del rastro y del expediente.',
 '8.5':'Revisar DBA_USERS/DBA_PROFILES y el flujo de autenticación; no divulgar contraseñas.',
 '5.23':'Revisar responsabilidades y conectividad del plan Azure; el despliegue todavía no se ha probado.',
 '8.2':'Comprobar DBA_SYS_PRIVS y DBA_ROLE_PRIVS desde una sesión DBA; RCONF_APP no debe tener DBA ni privilegios ANY.',
 '8.3':'Ejecutar la comprobación local de SELECT y el script 05_verify_runtime.sql para lecturas permitidas y denegadas.',
 '8.9':'Conservar salida de 00_preflight.sql, configuración del listener y versión de scripts sin contraseñas.',
 '8.10':'Revisar DBA_RECYCLEBIN como señal parcial y contrastar con política y acta de eliminación.',
 '8.11':'Comparar MASKED_PERSONAL con la denegación de DEMO_PERSONAL en T07; la vista no es Oracle Data Redaction.',
 '8.12':'Revisar permisos y retención del almacén de evidencias y exportaciones; queda fuera de la prueba SELECT.',
 '8.13':'Revisar V$BACKUP_PIECE/RMAN, cifrado, custodia, acceso y evidencia de restauración.',
 '8.15':'Correlacionar 03_audit.sql con la política activa y el rastro consultado por 04_verify_dba.sql.',
 '8.16':'Investigar T11 en UNIFIED_AUDIT_TRAIL por hora, sesión y sentencia antes de cerrar el hallazgo.',
 '8.24':'Documentar configuración y prueba de TLS o TCPS y custodia de claves; aún no existe prueba de Azure.',
 '8.20':'Revisar listener, reglas de red y V$SESSION_CONNECT_INFO; la sesión local no acredita configuración de Azure.',
 '8.28':'Revisar las pruebas de autorización de la API y la parametrización; no ejecutar código desde el navegador.'
};
let DBA_TASKS=[
 ['Tarea 01 · usuarios','Altas, bajas, bloqueo y revisión periódica de cuentas.','R-CONF-02','5.16 · 5.18 · 8.5','DBA_USERS; acta del dueño de cuenta.'],
 ['Tarea 02 · privilegios','Separar dueño, aplicación y auditor; revisar privilegios directos, roles y ANY.','R-CONF-01','5.15 · 5.18 · 8.2 · 8.3','DBA_SYS_PRIVS, DBA_ROLE_PRIVS, DBA_TAB_PRIVS.'],
 ['Tarea 03 · autenticación','Aplicar perfiles, expiración/bloqueo proporcionados al entorno y custodia de credenciales.','R-CONF-02 · 03','5.17 · 8.5','DBA_PROFILES y procedimiento de rotación; no revelar secretos.'],
 ['Tarea 04 · TDE','Determinar necesidad, disponibilidad/licencia y configuración de TDE antes de activarlo.','R-CONF-08','8.24','Estado de wallet/cifrado y gestión de claves. No afirmado como habilitado en XE.'],
 ['Tarea 05 · enmascaramiento','Usar vistas reducidas con datos sintéticos; evaluar Data Redaction/VPD según licencia y arquitectura.','R-CONF-05','8.3 · 8.11','Consulta permitida a vista y denegada a tabla base.'],
 ['Tarea 06 · respaldo','Restringir archivos, cifrar cuando corresponda, separar claves y validar restauración.','R-CONF-08','8.13 · 8.24','RMAN, V$BACKUP_PIECE y acta de restauración.'],
 ['Tarea 07 · auditoría','Configurar eventos relevantes, revisar Unified Audit Trail y escalar anomalías.','R-CONF-07','5.33 · 8.15 · 8.16','03_audit.sql / 04_verify_dba.sql; correlación pendiente T11.'],
 ['Tarea 08 · parches','Mantener versión soportada y planificar parches, pruebas y reversión.','R-CONF-02 · 04','8.9','DBA_REGISTRY_SQLPATCH y registro de cambio.'],
 ['Tarea 09 · listener/red','Restringir listener y orígenes de conexión; evaluar TLS/TCPS.','R-CONF-04','8.20 · 8.24','listener.ora, reglas de red, V$SESSION_CONNECT_INFO.'],
 ['Tarea 10 · eliminación','Aplicar retención y borrado seguro a producción, exportaciones y respaldos según ciclo de vida.','R-CONF-06','5.12 · 8.10','Política y acta; DBA_RECYCLEBIN es evidencia parcial.'],
 ['Tarea 11 · logs','Limitar quién puede consultar y borrar logs; retenerlos y revisarlos.','R-CONF-07','5.33 · 8.15 · 8.16','Permisos, retención e investigación documentada.'],
 ['Tarea 12 · clones DEV/TEST','No copiar datos productivos directamente; enmascarar/sintetizar y controlar acceso al clon.','R-CONF-05 · 06','5.12 · 8.11 · 8.12','Aprobación, procedimiento de sanitización y evidencia del clon.']
].map(x=>({task:x[0],action:x[1],risk:x[2],controls:x[3],evidence:x[4]}));
let AUDIT_TESTS=[
 ['PT-01','Privilegios del rol de aplicación','DBA','Consultar DBA_SYS_PRIVS, DBA_ROLE_PRIVS y DBA_TAB_PRIVS para RCONF_APP y roles heredados.','No DBA, ANY ni acceso directo innecesario; solo sesión y grants explícitos.','SELECT de catálogo · 04_verify_dba.sql','Ejecutado según transcripción aportada; revisar salida original.'],
 ['PT-02','Vista de datos limitada','Positiva','Conectar como RCONF_APP y consultar MASKED_PERSONAL.','Devuelve solo datos sintéticos y campos enmascarados previstos.','SQL*Plus · 05_verify_runtime.sql','Conforme según salida aportada (T07).'],
 ['PT-03','Denegación de tabla sensible','Negativa','Como RCONF_APP intentar SELECT sobre RCONF_OWNER.DEMO_PERSONAL.','Denegación ORA-00942/ORA-01031; fallo inesperado invalida el control.','SQL*Plus · 05_verify_runtime.sql','Conforme según salida aportada (T07).'],
 ['PT-04','Vista de riesgos y protección de base','Positiva/negativa','Consultar RISK_VIEW y luego intentar SELECT a RISKS.','Vista disponible; tabla base inaccesible.','SQL*Plus · 05_verify_runtime.sql','Conforme según salida aportada (T08); la vista no tenía filas.'],
 ['PT-05','DML directo','Negativa','Como RCONF_APP intentar UPDATE directo a RCONF_OWNER.RISKS, incluso con WHERE 1=0.','Denegado; mutación no autorizada no debe depender de que haya filas.','SQL*Plus · 05_verify_runtime.sql','Conforme según salida aportada (T08).'],
 ['PT-06','Ciclo de vida de cuentas','Revisión','Revisar DBA_USERS, estados y dueño/justificación de cada cuenta no común.','Toda cuenta tiene dueño y necesidad vigente; las sobrantes están bloqueadas.','DBA · consulta de catálogo + acta','Pendiente de evidencia.'],
 ['PT-07','Perfil y autenticación','Revisión','Cruzar DBA_USERS.PROFILE con DBA_PROFILES y el procedimiento de secreto/rotación.','Política aprobada aplicada; sin contraseñas compartidas o en código.','DBA · consulta de catálogo + revisión repo','Pendiente de evidencia.'],
 ['PT-08','Clasificación / masking','Positiva/negativa','Revisar inventario y comparar vista de prueba con acceso a tabla origen.','Clasificación asignada; solo campos aprobados aparecen a RCONF_APP.','05_verify_runtime.sql + inventario','T07 cubre el ejemplo sintético; inventario pendiente.'],
 ['PT-09','Auditoría unificada','Revisión de rastro','Consultar política activa y correlacionar UNIFIED_AUDIT_TRAIL por hora, sesión, acción y retorno.','Acciones permitidas/denegadas atribuibles; eventos inesperados investigados.','DBA · 03_audit.sql / 04_verify_dba.sql','T11 pendiente: código 0 sobre DEMO_PERSONAL requiere correlación.'],
 ['PT-10','Eliminación y retención','Revisión','Contrastar política de retención, DBA_RECYCLEBIN y actas de eliminación.','Plazos aprobados y disposición verificable; recycle bin no es prueba suficiente por sí sola.','DBA_RECYCLEBIN + política/acta','Pendiente de evidencia.'],
 ['PT-11','Cifrado de respaldos','Revisión','Revisar V$BACKUP_PIECE/RMAN, repositorio, permisos y custodia de claves.','Copias cifradas según política; acceso a archivos y claves separado.','DBA · RMAN/consulta catálogo','Pendiente; no asumir TDE disponible en XE.'],
 ['PT-12','Canal de red Oracle','Revisión técnica','Revisar listener, reglas de firewall y V$SESSION_CONNECT_INFO de una sesión cliente.','Orígenes restringidos y cifrado/integridad acordes al diseño.','Listener · firewall · consulta V$','Pendiente; conexión local no acredita Azure.'],
 ['PT-13','Resguardo de evidencias/logs','Revisión','Revisar permisos, retención, acceso de escritura y revisión del repositorio de logs.','Evidencias de auditoría solo accesibles a roles aprobados y protegidas contra alteración.','Revisión de permisos y procedimiento','Pendiente de evidencia.'],
 ['PT-14','Parches y configuración','Revisión','Consultar DBA_REGISTRY_SQLPATCH; comparar versiones/configuración con línea base aprobada.','Parches evaluados y cambios trazables dentro del periodo definido.','DBA · DBA_REGISTRY_SQLPATCH + change log','Pendiente de evidencia.'],
 ['PT-15','Clones DEV/TEST y fuga','Revisión de proceso','Revisar aprobaciones de clones y procedimiento de sanitización antes de habilitar usuarios.','No hay datos productivos en claro en clones; exportaciones y salidas tienen destino autorizado.','Acta de clon + prueba de máscara + permisos','Pendiente de evidencia.']
].map(x=>({id:x[0],title:x[1],type:x[2],procedure:x[3],expected:x[4],tool:x[5],observed:x[6]}));
let REQUIRED_CONTROL_MATRIX=[
 ['5.12',1,'No cumple','Clasificación y tratamiento propuestos; inventario aprobado pendiente.','PT-08'],
 ['5.15',2,'Parcial','Matriz de autorización diseñada; revisión organizacional independiente pendiente.','PT-01'],
 ['5.16',1,'No cumple','Flujo de identidades propuesto; inventario de altas y bajas pendiente.','PT-06'],
 ['5.17',1,'No cumple','Custodia externa recomendada; evidencia de rotación/configuración no aportada.','PT-07'],
 ['5.18',2,'Parcial','Grants restringidos y denegación directa observada; revisión periódica pendiente.','PT-01'],
 ['5.33',1,'No cumple','Retención y protección de evidencia descritas; custodia probada pendiente.','PT-13'],
 ['8.2',2,'Parcial','Separación owner/app y pruebas denegadas; revisión integral de roles pendiente.','PT-01'],
 ['8.3',3,'Parcial','Vista y denegaciones probadas en laboratorio; revisor independiente y repetición pendientes.','PT-02–PT-05'],
 ['8.5',1,'No cumple','Configuración recomendada; revisión de perfil y autenticación pendiente.','PT-07'],
 ['8.10',1,'No cumple','Proceso de eliminación propuesto; acta y alcance de copias pendiente.','PT-10'],
 ['8.11',3,'Parcial','Vista sintética devuelve campo oculto; no es Data Redaction y su alcance es limitado.','PT-02 · PT-08'],
 ['8.12',1,'No cumple','Restricción de exportación propuesta; controles de DLP/almacén no probados.','PT-15'],
 ['8.13',1,'No cumple','Cifrado y custodia recomendados; configuración RMAN/restauración no aportada.','PT-11'],
 ['8.15',2,'Parcial','Política creada/activa y rastro consultado; evento con retorno 0 sin resolver.','PT-09'],
 ['8.20',1,'No cumple','Listener/TLS propuestos; configuración de red real no comprobada.','PT-12']
].map(x=>({id:x[0],score:x[1],status:x[2],evidence:x[3],test:x[4]}));
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
 ['Oracle 21c · autorización','Privilegios, roles y permisos de objetos','https://docs.oracle.com/en/database/oracle/oracle-database/21/dbseg/configuring-privilege-and-role-authorization.html'],
 ['Oracle 21c · perfiles de usuario','Perfiles de autenticación y DBA_PROFILES','https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/DBA_PROFILES.html'],
 ['Oracle 21c · auditoría unificada','Políticas de auditoría y Unified Audit Trail','https://docs.oracle.com/en/database/oracle/oracle-database/21/dbseg/configuring-audit-policies.html'],
 ['Oracle 21c · cifrado de red','Oracle Net Encryption and Integrity','https://docs.oracle.com/en/database/oracle/oracle-database/21/dbseg/configuring-network-data-encryption-and-integrity.html'],
 ['Oracle 21c · Advanced Security','TDE y Data Redaction, sujetos a licencia/edición','https://docs.oracle.com/en/database/oracle/oracle-database/21/asoag/introduction-to-oracle-advanced-security.html'],
 ['Costa Rica · Ley 8968','Protección de datos personales','https://www.pgrweb.go.cr/DOCS/NORMAS/1/VIGENTE/L/2010-2019/2010-2014/2011/1153F/DCEF7.HTML'],
 ['Costa Rica · Reglamento 37554-JP','Reglamento a la Ley 8968','https://www.pgrweb.go.cr/DOCS/NORMAS/1/VIGENTE/D/2010-2019/2010-2014/2012/12270/ECA5D.HTML'],
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
