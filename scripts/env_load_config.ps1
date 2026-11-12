$project = Split-Path -Path $PSScriptRoot -Parent

$configPath = Join-Path $project 'config.psd1'
$config = Import-PowerShellDataFile -LiteralPath $configPath -ErrorAction Stop

$env:DOMAIN = [string] $config.Domain
$env:LAN_IP = [string] $config.LanIp
$env:ALLOWED_SUBNET = [string] $config.AllowedSubnet
$env:DNS_FORWARDERS = $config.DnsForwarders -join ' '
$env:DNS_TTL = [string] $config.DnsTtl
$env:APP_UPSTREAM = [string] $config.AppUpstream
