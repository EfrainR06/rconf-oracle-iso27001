# Declaración de uso de inteligencia artificial generativa

Efrain Retana Segura. EIF402 Administración de Bases de Datos. Universidad Nacional. II Ciclo 2026. Elaboración y revisión asistidas: 25 y 26 de octubre de 2026.

## Propósito de la declaración

Este documento registra la asistencia recibida en la preparación de R-CONF Oracle Security Lab. Su finalidad es permitir que el docente distinga el material generado con ayuda de IA de la validación y las contribuciones efectivamente realizadas por el estudiante. La declaración debe actualizarse después de ejecutar las tareas locales y antes de presentar el trabajo.

El programa del curso, apartado VII, punto 9, indica que el uso evaluativo de IA generativa depende de autorización expresa de la persona docente y exige declarar las herramientas cuando se permita. El estado de esa autorización no fue aportado en esta conversación. Antes de una entrega evaluativa, el estudiante debe comprobar las condiciones correspondientes; este documento no las sustituye.

## Herramienta y alcance real de la asistencia

Se utilizó Codex de OpenAI en una sesión de asistencia. El asistente consultó el programa de curso, fuentes públicas sobre las normas, documentación Oracle y Microsoft, y generó una propuesta extensa de código, scripts, documentos y pruebas. El material entregado tiene una participación sustancial de IA en su elaboración inicial.

La asistencia incluyó interpretación del alcance de confidencialidad; diseño del registro R-CONF y PHVA; interfaz y API; scripts de cuentas, vistas, paquete y auditoría; borradores de documentos; preparación de pruebas automatizadas; revisión de la demostración y preparación del repositorio. No se afirma que esta asistencia consistiera solo en corrección ortográfica o búsqueda bibliográfica.

El asistente confirmó inicialmente que el listener local anunciaba xepdb1. Las pruebas automatizadas de la API se ejecutaron usando un almacén simulado. Posteriormente, el estudiante ejecutó los scripts de instalación y compartió salidas de las pruebas T07, T08 y T11 en Oracle 21c XE. La asistencia interpretó esas salidas y señaló una fila de auditoría que requiere correlación; no accedió con una cuenta DBA a la PDB para verificarlas independientemente. TCPS y conectividad Azure siguen sin probarse; el despliegue en Azure fue pospuesto por el usuario. El expediente preliminar documenta observaciones y límites.

## Solicitud efectivamente recibida

La solicitud del estudiante pidió un sitio basado en ISO/IEC 27001:2022 e ISO/IEC 27002:2022 para mitigar riesgos R-CONF de motores Oracle mediante PHVA y mínimo privilegio. También solicitó comparación con 2013, documentos, repositorio GitHub, scripts para Oracle local y orientación para alojar en Azure. Aportó el programa del curso y enlaces de ISO, GlobalSuite, ISOTools y Wikipedia.

Durante el intercambio el estudiante confirmó Oracle versión 21 y la existencia de una suscripción Azure. Después indicó dejar para más adelante la publicación en Azure. Esos datos orientaron la preparación técnica. Este apartado resume la solicitud real; no es una transcripción íntegra ni un registro automático de todos los mensajes.

## Ejemplo de prompt para una consulta futura

El siguiente prompt fue redactado como ejemplo y no se presenta como una consulta efectivamente enviada ni como prueba de contribución personal:

> Revisá mi matriz R-CONF para Oracle 21c XE. Para cada escenario, señalá si el control propuesto limita lecturas indebidas, qué permiso mínimo necesita la cuenta de aplicación y qué prueba positiva y negativa debería ejecutar. Relacioná la decisión con ISO/IEC 27001:2022 e ISO/IEC 27002:2022, explicá las diferencias relevantes frente a 2013 y marcá los puntos que requieran verificación en fuentes oficiales. No atribuyás resultados a pruebas que no haya ejecutado.

Si el estudiante utiliza este u otro prompt, deberá conservar la consulta real, su respuesta y las correcciones realizadas. No se debe reemplazar un historial existente por uno inventado para aparentar menor intervención de IA.

## Registro de contribuciones

- Aporte del estudiante confirmado en la conversación: definición de tema y alcance, identificación personal, archivo del programa del curso, enlaces iniciales, versión Oracle, elección de Azure y decisión de posponer publicación. El estudiante también ejecutó los scripts de instalación y pruebas SQL en XEPDB1, compartió las salidas, conectó la web en modo Oracle y registró un riesgo con referencia EV-001.
- Aporte inicial del asistente: borrador sustancial de aplicación, scripts, documentación, búsqueda de fuentes y pruebas de lógica. El estudiante debe revisar estos componentes antes de asumir su contenido.
- Aporte posterior del estudiante pendiente de documentar: guardar archivos originales de las salidas, correlacionar T11, justificar riesgos y decisiones residuales, revisar los cambios de diseño y preparar su demostración oral.
- En la revisión del 26 de octubre, el estudiante aportó dos audios de un compañero. Se tomaron como sugerencias de presentación: hacer visibles los controles, explicar un escenario ficticio con antes y después, mostrar salidas de scripts y destacar la declaración de IA. Los audios no prueban que el docente haya evaluado este prototipo.
- Aporte conjunto posible: revisión de hallazgos y adaptación del diseño a partir de resultados. Solo registrar tareas cuando ocurran y vincularlas con commits o evidencias reales.

No se asigna un porcentaje de autoría. Para afirmar que el estudiante realizó la mayor parte se requeriría evidencia verificable de ese trabajo; no se dispone de ella en la elaboración inicial.

## Plantilla para completar tras la validación

Actividad: ____________________. Fecha real: ____________________. Archivo o commit: ____________________. Evidencia restringida: ____________________. Trabajo realizado personalmente: ____________________. Asistencia recibida: ____________________. Corrección o decisión propia y su justificación: ____________________.

Repetir esta ficha para instalación, pruebas de mínimo privilegio, revisión de auditoría, ajustes del modelo de riesgo y despliegue. No copiar las referencias DEM como si fueran resultados personales.

## Revisión responsable del contenido

El estudiante deberá comprobar referencias y denominaciones, comprender los permisos concedidos, explicar el paquete con derechos del definidor y reproducir las pruebas relevantes. Si detecta un error de IA, registrará el problema y la corrección. La responsabilidad por el contenido presentado no se delega a la herramienta.

La documentación no incluye texto completo de las normas ni atribuye una certificación al prototipo. Los escenarios iniciales son sintéticos; las estimaciones residuales requieren verificación. El estudiante deberá usar únicamente material permitido por los lineamientos de la actividad y conservar esta declaración junto a la versión finalmente presentada.
