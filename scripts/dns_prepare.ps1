$project = Split-Path -Path $PSScriptRoot -Parent

if (
  [string]::IsNullOrWhiteSpace($env:LAN_IP) -or
  [string]::IsNullOrWhiteSpace($env:DOMAIN)
) {
  throw 'Check the configuration value: LanIp, Domain'
}

$local = Join-Path $project '.local\dns'
$hosts = Join-Path $local 'hosts.txt'

New-Item -ItemType Directory -Force -Path $local | Out-Null

$record = '{0} {1}' -f $env:LAN_IP, $env:DOMAIN

Set-Content -LiteralPath $hosts -Value $record -Encoding ascii -ErrorAction Stop
