Param(
  [string[]]$Source = @('C:\Users\Public','C:\Windows\System32\drivers\etc'),
  [string]$Dest = 'C:\Backups\auto-admin',
  [int]$RetainDays = 7,
  [string]$LogDir = '..\..\docs\evidencias'
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $Dest,$LogDir | Out-Null
$ts  = Get-Date -Format 'yyyyMMdd_HHmmss'
$zip = Join-Path $Dest "backup_$ts.zip"
$log = Join-Path $LogDir "win_backup_$ts.log"

Compress-Archive -Path $Source -DestinationPath $zip -Force
"[DONE] Backup: $zip" | Tee-Object -FilePath $log -Append

Get-ChildItem $Dest -Filter 'backup_*.zip' |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$RetainDays) } |
  Remove-Item -Force

"[OK] Rotación aplicada ($RetainDays días)" | Tee-Object -FilePath $log -Append
