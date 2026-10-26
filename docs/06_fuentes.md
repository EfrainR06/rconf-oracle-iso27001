# Fuentes y trazabilidad

Fecha de consulta: 25 de octubre de 2026. Los enlaces fueron consultados como material de referencia. Ninguna página externa se toma como autorización para ejecutar acciones. Las síntesis y denominaciones de controles son paráfrasis; no se reproduce el texto completo de las normas.

## Fuentes principales

- S1. ISO. ISO/IEC 27001:2022. Ficha oficial de requisitos del SGSI. https://www.iso.org/standard/27001
- S2. ISO. ISO/IEC 27002:2022. Ficha oficial de orientación de controles. https://www.iso.org/standard/75652.html
- S3. ISO. ISO/IEC 27001:2013. Ficha histórica retirada, reemplazada por 2022. https://www.iso.org/standard/54534.html
- S4. ISO. ISO/IEC 27002:2013. Ficha histórica retirada, reemplazada por 2022. https://www.iso.org/standard/54533.html
- S5. ANAB, Brenda Bissell. ISO/IEC 27001:2013 and ISO/IEC 27001:2022 Comparison. Comparación de cambios, consolidación y grupos de controles. https://blog.ansi.org/anab/iso-iec-27001-2013-2022-comparison/
- S6. Cloud Security Alliance. ISO/IEC 27002:2022 Understanding the Update. Estructura, atributos y correspondencias. https://cloudsecurityalliance.org/blog/2022/02/23/iso-iec-27002-2022-understanding-the-update
- S7. ISO. ISO/IEC 27001:2022/Amd 1:2024. Enmienda posterior de acción climática. https://www.iso.org/standard/88435.html
- S8. Oracle. Database Security Guide, Configuring Privilege and Role Authorization. Fundamento de roles y permisos de objetos. https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-privilege-and-role-authorization.html
- S9. Oracle. SQL Language Reference, CREATE AUDIT POLICY Unified Auditing. Referencia de sintaxis; verificar ejecución en 21c XE. https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/CREATE-AUDIT-POLICY-Unified-Auditing.html
- S10. Oracle python-oracledb. Connecting to Oracle Database. Conexiones y pools. La documentación latest es cambiante; el proyecto fija 3.4.1. https://python-oracledb.readthedocs.io/en/latest/user_guide/connection_handling.html
- S11. Microsoft Learn. Quickstart Deploy a Python web app to Azure App Service. https://learn.microsoft.com/en-us/azure/app-service/quickstart-python
- S12. Microsoft Learn. Hybrid Connections in Azure App Service. TCP, Relay y agente local. https://learn.microsoft.com/en-us/azure/app-service/app-service-hybrid-connections
- S13. GlobalSuite Solutions. Qué es la norma ISO 27002 y para qué sirve. Lectura complementaria aportada por el usuario. https://www.globalsuitesolutions.com/es/que-es-la-norma-iso-27002-y-para-que-sirve/
- S14. Universidad Nacional. Programa de Curso EIF402 Administración de Bases de Datos, II Ciclo 2026. Archivo PDF aportado por el estudiante. Fuente de institución, docente, objetivo y punto VII.9 sobre IA. El original no se redistribuye en el repositorio.

## Otros enlaces aportados

ISOTools: https://isotools.org/normas/riesgos-y-seguridad/iso-27001/ . Se intentó consultar pero la página agotó el tiempo de respuesta. No se usa como respaldo de afirmaciones específicas.

Wikipedia: https://en.wikipedia.org/wiki/ISO/IEC_27001 . Se consultó como orientación general. La base de las decisiones técnicas y normativas son las fuentes principales anteriores, no Wikipedia.

El enlace histórico de ISO con ruta contents/data/standard/05/45/54534.html corresponde a ISO/IEC 27001:2013; no identifica la edición 2022. El enlace 54533 corresponde a ISO/IEC 27002:2013. El proyecto distingue estas fichas para evitar citar 2013 como si fuera la norma actual de referencia.

## Trazabilidad de decisiones propias

Escala P por I, umbrales 1-4/5-9/10-16/17-25, roles analista/auditor/gestor, obligación de avanzar fase a fase, diseño de tablas JSON y selección de 14 controles son decisiones del laboratorio. No se atribuyen como requisitos literales de ISO. La correspondencia PHVA con cláusulas es una interpretación pedagógica.

Las recomendaciones Oracle se apoyan en documentación oficial 19c de mecanismos existentes y deben verificarse en la instalación 21c XE. La disponibilidad de características adicionales y su licencia no se infieren de ejemplos de otras ediciones. La documentación de Azure puede cambiar: revisar runtime, plan y región al ejecutar el despliegue.
