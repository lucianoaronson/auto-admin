$LogDir = '..\..\docs\evidencias'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$log = Join-Path $LogDir ("win_patch_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

$ErrorActionPreference = 'Stop'
Try { Import-Module PSWindowsUpdate -ErrorAction Stop }
Catch {
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
  Install-Module -Name PSWindowsUpdate -Force
  Import-Module PSWindowsUpdate
}

Checkpoint-Computer -Description "PrePatch" -RestorePointType 'MODIFY_SETTINGS' | Out-Null

"== AVAILABLE UPDATES ==" | Out-File -FilePath $log -Encoding utf8
Get-WindowsUpdate | Out-File -Append -FilePath $log -Encoding utf8

"== INSTALL ==" | Out-File -Append -FilePath $log -Encoding utf8
Install-WindowsUpdate -AcceptAll -AutoReboot | Out-File -Append -FilePath $log -Encoding utf8
