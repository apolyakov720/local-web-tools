$project = Split-Path -Path $PSScriptRoot -Parent

$local = Join-Path $project '.local\public'
$logs = Join-Path $project '.local\logs'
$root = (mkcert -CAROOT).Trim()

if (-not (Test-Path -Path $local)) {
  New-Item -ItemType Directory -Path $local -Force | Out-Null
}

if (-not (Test-Path -Path $logs)) {
  New-Item -ItemType Directory -Path $logs -Force | Out-Null
}

Copy-Item -LiteralPath (Join-Path $root 'rootCA.pem') -Destination (Join-Path $local 'rootCA.crt')