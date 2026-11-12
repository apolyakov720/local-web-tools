. (Join-Path $PSScriptRoot 'env_load_config.ps1')

$project = Split-Path -Path $PSScriptRoot -Parent

$local = Join-Path $project '.local\certs'
$cert = Join-Path $local "$env:DOMAIN.pem"
$key = Join-Path $local "$env:DOMAIN-key.pem"

if (-not (Test-Path -Path $local)) {
  New-Item -ItemType Directory -Path $local -Force | Out-Null
}

mkcert -cert-file $cert -key-file $key $env:DOMAIN
