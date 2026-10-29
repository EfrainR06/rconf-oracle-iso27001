<#
R-CONF | 8.13 / 8.24: permisos NTFS de las piezas RMAN observadas en V$BACKUP_PIECE (solo lectura).
Uso: powershell -ExecutionPolicy Bypass -File tools\capturar_acl_respaldos.ps1
No lee el contenido de las piezas ni modifica permisos.
#>
param([string]$BackupDir = 'C:\app\Usuario\product\21c\KADE_RECOVERY')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root ("local-evidence\pruebas_dba_" + (Get-Date -Format 'yyyy-MM-dd'))
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$out = Join-Path $outDir ("acl_respaldos_{0}.txt" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
$lines = @(
  '================================================================'
  'R-CONF | EVIDENCIA ORIGINAL (PowerShell, salida sin editar)'
  'PROCEDIMIENTO: tools/capturar_acl_respaldos.ps1 | EFECTO: solo lectura'
  'ESPERADO: piezas accesibles solo para administradores, SYSTEM y cuentas de servicio Oracle.'
  'OBSERVADO: completar por el revisor tras leer la salida.'
  ('FECHA: ' + (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fff zzz'))
  ('CUENTA SO: ' + [Security.Principal.WindowsIdentity]::GetCurrent().Name)
  ('DIRECTORIO: ' + $BackupDir)
  '================================================================'
)
$body = foreach ($d in @($BackupDir) + (Get-ChildItem $BackupDir -Directory -Recurse | ForEach-Object FullName)) {
  "=== $d"
  (Get-Acl $d).Access | Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited | Format-Table -AutoSize | Out-String -Width 200
  Get-ChildItem $d -File | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize | Out-String -Width 200
}
($lines + $body) | Set-Content -Path $out -Encoding UTF8
Write-Host "-> $out"

