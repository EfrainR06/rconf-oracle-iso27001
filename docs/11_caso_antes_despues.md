# Ensayo real de confidencialidad: antes y despues

El caso Faro Servicios usa datos sinteticos y cuentas nuevas RCONF_CASE_OWNER / RCONF_CASE_APP en XEPDB1. La debilidad inicial esta limitada a una sola tabla sintetica. No cambia RCONF_OWNER, RCONF_APP ni el riesgo que ya guardaste. En este laboratorio se ejecuto el ensayo el 29 de octubre de 2026 y se conservaron capturas originales antes y despues; la revision de auditoria permanece pendiente. No repetir la instalacion en una PDB donde ya existen las cuentas.

## Preparacion

Descargar el paquete ZIP desde Auditoria antes/despues y extraerlo en una carpeta local. La carpeta debe contener sql/. Abrir PowerShell dentro de esa carpeta y crear las carpetas de salida:

New-Item -ItemType Directory -Force local-evidence/antes,local-evidence/despues

Abrir sqlplus /nolog desde PowerShell. Los comandos CONNECT, SHOW y @sql/... se escriben dentro de SQLPlus. Las claves se introducen solo cuando Oracle las pide. No grabar credenciales ni usar SPOOL al crear cuentas. No ejecutar sobre produccion.

## Secuencia de ejecucion

1. DBA: CONNECT sys@localhost:1521/XEPDB1 AS SYSDBA. Verificar SHOW CON_NAME. Ejecutar @sql/11_case_accounts.sql una sola vez e introducir dos claves privadas. No se imprimen en el archivo SQL. Si las cuentas ya existen, detenerse y revisar; el script no las elimina ni reinicia.
2. Conectar RCONF_CASE_OWNER@localhost:1521/XEPDB1 y ejecutar @sql/12_case_schema.sql. Se crea CASE_CLIENTS con un correo sintetico, CASE_MASKED y lectura inicial de la tabla para la cuenta del caso.
3. DBA en XEPDB1: ejecutar @sql/13_case_audit.sql una sola vez. Crea la politica RCONF_CASE_READ solo para el caso. Conviene guardar aparte la salida de @sql/17_case_verify_dba.sql como diagnostico DBA inicial.
4. Conectar RCONF_CASE_APP@localhost:1521/XEPDB1 y ejecutar @sql/14_case_before.sql. Guarda automaticamente local-evidence/antes/caso_pruebas.txt. Estado esperado: RAW_SELECT=ALLOWED (hallazgo), MASKED_SELECT=DENIED (sin acceso a vista), DIRECT_UPDATE=DENIED (restriccion ya presente).
5. Conectar RCONF_CASE_OWNER y ejecutar @sql/15_case_remediate.sql. Se revoca SELECT de CASE_CLIENTS y se concede SELECT de CASE_MASKED. Es el tratamiento del riesgo R-CONF-01/05 del caso aislado.
6. Reconectar RCONF_CASE_APP y ejecutar @sql/16_case_after.sql. Guarda local-evidence/despues/caso_pruebas.txt. Repite las mismas tres pruebas. Esperado: RAW_SELECT=DENIED, MASKED_SELECT=MASKED, DIRECT_UPDATE=DENIED.
7. DBA: ejecutar @sql/17_case_verify_dba.sql y guardar su salida con SPOOL en local-evidence/despues/caso_dba.txt. Correlacionar politica, grants y eventos por hora, sentencia y sesion. No interpretar ausencia de filas como exito de auditoria.

## Mostrar las salidas en la pagina

Abrir Auditoria antes/despues. En el expediente Caso completo, cargar los dos caso_pruebas.txt en la etapa correspondiente. La pagina verifica contexto, fase, fecha, identificador de ejecucion y los tres marcadores de salida; calcula el numero de pruebas satisfactorias y las barras comparativas. No puntua los 15 controles ISO automaticamente. Un TXT puede ser editado: su contenido y autenticidad requieren revision humana contra el spool original.

Resultado esperado del diseno: 1 de 3 antes y 3 de 3 despues. Es una prediccion hasta ejecutar y revisar los archivos reales. Las capturas reales de este laboratorio se guardaron en local-evidence; las plantillas del paquete siguen sin contener resultados. Correlacionar el rastro como DBA antes de concluir.

En cada script del catalogo tambien se pueden cargar dos TXT y descargar las salidas seleccionadas. Los archivos permanecen en memoria de la pestaña. Exportar expediente JSON antes de recargar; importar ese JSON permite continuar en otra sesion. Revisar secretos antes de exportar o compartir.

## Formato TXT de todos los scripts

El paquete incluye sql/ con codigo ejecutable y txt/scripts/ con el mismo codigo en TXT. txt/antes/ y txt/despues/ contienen fichas PENDIENTE - NO EJECUTADO para cada script: son plantillas, no salidas Oracle. No ejecutar esas fichas como SQL ni repetir todos los scripts de instalacion y reversion para generar evidencia.

Los scripts 11, 12 y 13 son de primera instalacion; 15 aplica el tratamiento una vez; 14 y 16 son las mediciones comparables; 17 observa el rastro. La aplicacion no recibe credenciales SYS ni permisos administrativos.

Al terminar, el DBA puede bloquear las cuentas del caso conforme al mantenimiento del laboratorio y conservar las evidencias. No hay DROP USER automatico. El rastro del caso nuevo no resuelve retrospectivamente T11 de RCONF_APP; son expedientes distintos.


## Grafica de madurez por bloques, como la referencia visual

Auditoria antes/despues incluye una grafica de lineas en escala 0–4, ocho riesgos y promedio de los 20 controles del catalogo. Abrir la tabla de niveles para registrar ANTES, DESPUES, referencias (archivo, fecha y revisor), bloque y confirmacion de revision por control. Estos valores son evaluaciones manuales; los tres ensayos del caso no asignan automaticamente madurez a los 20 controles.

Una serie se dibuja cuando todos sus controles tienen ambos niveles, referencias y revision. El promedio exige los 20. En cada bloque intermedio, cada control conserva ANTES hasta que alcanza su bloque; luego toma DESPUES. Los puntos huecos son proyecciones calculadas, los llenos son los extremos registrados. No se afirma haber medido Oracle despues de cada bloque. La meta 3,10 es editable y no la exige ISO. Un nivel posterior menor se dibuja como reduccion, sin forzar una mejora.

Las valoraciones se guardan en Oracle al pulsar Guardar matriz en Oracle; tambien se pueden exportar junto con los TXT en un expediente JSON. La relacion de controles por riesgo se puede consultar debajo de la tabla. TDE, RMAN y Red son bloques del plan; no acreditan que las opciones esten disponibles o instaladas. La segunda grafica conserva el resultado de las tres pruebas tecnicas derivado de los TXT del caso.

El boton Ver ejemplo ilustrativo muestra curvas ficticias solo para revisar el formato. No modifica niveles, no se exporta como evidencia y se identifica en pantalla como ejemplo. Volver a mis evaluaciones recupera los registros propios.

## Ejecucion local del 29 de octubre de 2026

El ensayo aislado fue ejecutado en XEPDB1 con datos sinteticos. Las capturas originales se encuentran en local-evidence/antes/caso_pruebas.txt y local-evidence/despues/caso_pruebas.txt; las revisiones DBA se conservaron junto a ellas como caso_dba.txt. Antes: tabla permitida, vista denegada, UPDATE denegado. Despues: tabla denegada, vista enmascarada permitida y UPDATE denegado. La lectura automatica usa los marcadores y no autentica por si misma la evidencia. La revision de eventos y la decision residual siguen pendientes. Las credenciales generadas estan protegidas mediante Windows DPAPI en local-secrets y no forman parte de los ZIP ni se muestran en la web.
