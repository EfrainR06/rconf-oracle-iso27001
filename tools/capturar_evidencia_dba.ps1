<#
R-CONF | Captura de evidencia DBA de solo lectura (Oracle 21c XE, XEPDB1).

Uso (desde la carpeta del proyecto, como usuario del grupo ORA_DBA del servidor local):
    powershell -ExecutionPolicy Bypass -File tools\capturar_evidencia_dba.ps1
    powershell -ExecutionPolicy Bypass -File tools\capturar_evidencia_dba.ps1 -Scripts 04_verify_dba.sql,19_audit_correlation.sql

- Usa autenticacion del sistema operativo ("/ as sysdba"): no pide ni escribe contrasenas.
- Solo permite scripts de LECTURA de la lista blanca. No ejecuta instaladores ni reversiones.
- Cada salida se guarda sin editar en local-evidence\pruebas_dba_<fecha>\ con un encabezado
  (fecha, cuenta, PDB, procedimiento, esperado) que genera la misma sesion de Oracle.
- El campo OBSERVADO lo completa el revisor despues de leer la salida; el script no concluye.
#>
param(
    [string[]]$Scripts = @('04_verify_dba.sql', '08_auditor_controls.sql', '19_audit_correlation.sql', '23_investigacion_observaciones.sql', '24_correlacion_t11.sql'),
    [string]$Container = 'XEPDB1'
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$readOnly = @{
    '04_verify_dba.sql'                  = 'Grants minimos de RCONF_APP/roles, sin PUBLIC sobre RCONF_OWNER; politica RCONF_ACCESS_POLICY habilitada; eventos correlacionables.'
    '08_auditor_controls.sql'            = 'Observaciones de catalogo para los 15 controles; sin filas o sin evidencia no equivale a Cumple.'
    '17_case_verify_dba.sql'             = 'Grants del caso aislado y eventos RCONF_CASE_READ correlacionables.'
    '19_audit_correlation.sql'           = 'Eventos de RCONF_APP sobre RCONF_OWNER con hora, sesion, sentencia y codigo; correlacionar con el spool runtime.'
    '22_diagnostico_actual.sql'          = 'Estado actual de permisos, perfiles, objetos, auditoria y respaldos; no es un antes historico.'
    '23_investigacion_observaciones.sql' = 'Detalle de piezas RMAN (cifrado, ubicacion, configuracion, wallet) y del perfil DEFAULT (funcion de verificacion).'
    '24_correlacion_t11.sql'             = 'Cada sentencia del spool runtime 29/10 00:22:58 (RCONF_APP) con evento de igual hora y sesion, o explicada su ausencia.'
}
if ($Container -notin @('XEPDB1', 'CDB$ROOT')) { throw 'Contenedor no permitido.' }
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outDir = Join-Path $root ("local-evidence\pruebas_dba_" + (Get-Date -Format 'yyyy-MM-dd'))
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

foreach ($name in $Scripts) {
    if (-not $readOnly.ContainsKey($name)) { throw "Script no permitido (no es de solo lectura): $name" }
    $sqlPath = Join-Path $root "sql\$name"
    if (-not (Test-Path $sqlPath)) { throw "No existe $sqlPath" }
    $suffix = if ($Container -eq 'XEPDB1') { '' } else { '_CDBROOT' }
    $outFile = Join-Path $outDir ("{0}{1}_{2}.txt" -f [IO.Path]::GetFileNameWithoutExtension($name), $suffix, $stamp)
    $spool = $outFile -replace '\\', '/'
    $sqlRef = $sqlPath -replace '\\', '/'
    $session = @"
WHENEVER OSERROR EXIT FAILURE
SET SQLBLANKLINES ON
ALTER SESSION SET CONTAINER=$Container;
SPOOL "$spool"
PROMPT ================================================================
PROMPT R-CONF | EVIDENCIA ORIGINAL DE SQL*PLUS (salida sin editar)
PROMPT PROCEDIMIENTO: $name  |  EFECTO: solo lectura
PROMPT ESPERADO: $($readOnly[$name])
PROMPT OBSERVADO: completar por el revisor tras leer la salida.
PROMPT EJECUTOR: tools/capturar_evidencia_dba.ps1 (autenticacion SO, sin contrasena)
SET HEADING OFF FEEDBACK OFF
SELECT 'FECHA: '||TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD"T"HH24:MI:SS.FF3 TZH:TZM')||CHR(10)||
       'CUENTA: '||SYS_CONTEXT('USERENV','SESSION_USER')||CHR(10)||
       'PDB/CONTENEDOR: '||SYS_CONTEXT('USERENV','CON_NAME')||CHR(10)||
       'SESION (AUDSID/SID): '||SYS_CONTEXT('USERENV','SESSIONID')||' / '||SYS_CONTEXT('USERENV','SID')||CHR(10)||
       'HOST CLIENTE: '||SYS_CONTEXT('USERENV','HOST')
FROM dual;
SET HEADING ON FEEDBACK ON
PROMPT ================================================================
@"$sqlRef"
SPOOL OFF
EXIT
"@
    Write-Host "Ejecutando $name en $Container ..."
    $session | sqlplus -S -L "/ as sysdba" | Out-Null
    Write-Host "  -> $outFile ($((Get-Item $outFile).Length) bytes)"
}
Write-Host 'Revisar cada TXT antes de compartirlo (SQL_TEXT y rutas pueden ser sensibles).'
