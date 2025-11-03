Param([string]$LogDir='..\..\docs\evidencias')

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$csv = Join-Path $LogDir ("win_audit_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

$rows = @()

# Logons fallidos (4625) últimos 7 días
$rows += Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, @{n='Message';e={$_.Message -replace '\r|\n',' '}}

# Servicio instalado/cambiado (7045) últimos 7 días
$rows += Get-WinEvent -FilterHashtable @{LogName='System'; Id=7045; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, @{n='Message';e={$_.Message -replace '\r|\n',' '}}

# Elevaciones especiales (4672) últimos 7 días
$rows += Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4672; StartTime=(Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Id, ProviderName, @{n='Message';e={$_.Message -replace '\r|\n',' '}}

$rows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csv
Write-Host "[DONE] Reporte: $csv"
