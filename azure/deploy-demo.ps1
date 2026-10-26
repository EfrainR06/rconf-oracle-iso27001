param(
 [Parameter(Mandatory=$true)][string]$SubscriptionId,
 [Parameter(Mandatory=$true)][string]$ResourceGroup,
 [Parameter(Mandatory=$true)][string]$Location,
 [Parameter(Mandatory=$true)][string]$AppName,
 [Parameter(Mandatory=$true)][string]$PlanName
)
$ErrorActionPreference='Stop'
function Invoke-AzChecked {
 param([string[]]$Arguments)
 & az @Arguments
 if ($LASTEXITCODE -ne 0) { throw ('Azure CLI failed: '+$Arguments[0]+' '+$Arguments[1]) }
}
if (!(Get-Command az -ErrorAction SilentlyContinue)) { throw 'Install Microsoft Azure CLI first, then run az login.' }
Invoke-AzChecked @('account','set','--subscription',$SubscriptionId)
Invoke-AzChecked @('group','show','--name',$ResourceGroup,'--output','none')
$existingWeb = & az webapp show --name $AppName --resource-group $ResourceGroup --query id -o tsv 2>$null
if ($LASTEXITCODE -eq 0 -and $existingWeb) { throw 'App already exists. Review it; this first-deploy script will not overwrite it.' }
$existingPlan = & az appservice plan show --name $PlanName --resource-group $ResourceGroup --query id -o tsv 2>$null
if ($LASTEXITCODE -eq 0 -and $existingPlan) { throw 'Plan already exists. Choose a new name or plan an explicit reuse.' }
Write-Host 'Creating a Linux B1 plan and web. These Azure resources can generate charges.'
Invoke-AzChecked @('appservice','plan','create','--name',$PlanName,'--resource-group',$ResourceGroup,'--location',$Location,'--is-linux','--sku','B1','--output','none')
Invoke-AzChecked @('webapp','create','--name',$AppName,'--resource-group',$ResourceGroup,'--plan',$PlanName,'--runtime','PYTHON:3.12','--output','none')
Invoke-AzChecked @('webapp','update','--name',$AppName,'--resource-group',$ResourceGroup,'--https-only','true','--output','none')
Invoke-AzChecked @('webapp','config','set','--name',$AppName,'--resource-group',$ResourceGroup,'--min-tls-version','1.2','--ftps-state','Disabled','--startup-file','gunicorn --bind=0.0.0.0:8000 --workers=2 --threads=4 --timeout=90 app.server:app','--output','none')
Invoke-AzChecked @('webapp','config','appsettings','set','--name',$AppName,'--resource-group',$ResourceGroup,'--settings','APP_MODE=demo','SCM_DO_BUILD_DURING_DEPLOYMENT=true','--output','none')
$projectRoot = Split-Path $PSScriptRoot -Parent
$archivePath = Join-Path ([System.IO.Path]::GetTempPath()) ('rconf-demo-'+[guid]::NewGuid().ToString('N')+'.zip')
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[System.IO.Compression.ZipFile]::Open($archivePath,[System.IO.Compression.ZipArchiveMode]::Create)
try {
 $files=@(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'app') -Recurse -File | Where-Object { $_.FullName -notmatch '__pycache__' })
 $files+=Get-Item -LiteralPath (Join-Path $projectRoot 'requirements.txt')
 foreach ($file in $files) {
  $entry=$file.FullName.Substring($projectRoot.Length+1).Replace('\','/')
  [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$file.FullName,$entry) | Out-Null
 }
} finally { $zip.Dispose() }
Invoke-AzChecked @('webapp','deploy','--name',$AppName,'--resource-group',$ResourceGroup,'--src-path',$archivePath,'--type','zip','--output','none')
Write-Host ('Deployment submitted. Verify https://'+$AppName+'.azurewebsites.net/health and the site in demo mode.')
Write-Host ('Deployment archive: '+$archivePath)
