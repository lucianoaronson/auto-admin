Param(
  [Parameter(Mandatory=$true)] [string]$CsvPath = ".\users.csv",
  [string]$LogDir = "..\..\docs\evidencias"
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$log = Join-Path $LogDir ("win_create_user_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

Import-Csv $CsvPath | ForEach-Object {
  $u = $_.Username.Trim()
  $n = $_.FullName.Trim()
  $p = $_.Password
  $g = $_.Groups

  if ([string]::IsNullOrWhiteSpace($u) -or [string]::IsNullOrWhiteSpace($p)) {
    "[WARN] Fila inválida (usuario/pass vacío)" | Tee-Object -FilePath $log -Append
    return
  }

  if (Get-LocalUser -Name $u -ErrorAction SilentlyContinue) {
    "[OK] Usuario $u ya existe" | Tee-Object -FilePath $log -Append
  } else {
    $secure = ConvertTo-SecureString $p -AsPlainText -Force
    New-LocalUser -Name $u -FullName $n -Password $secure -PasswordNeverExpires:$false -AccountNeverExpires:$false
    if ($g) { $g.Split(',') | ForEach-Object { $_ = $_.Trim(); if($_){ Add-LocalGroupMember -Group $_ -Member $u -ErrorAction SilentlyContinue } } }
    "[DONE] Creado $u" | Tee-Object -FilePath $log -Append
  }
}
"[END] Log en $log" | Tee-Object -FilePath $log -Append
