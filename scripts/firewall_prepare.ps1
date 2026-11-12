$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'env_load_config.ps1')

$project = Split-Path -Path $PSScriptRoot -Parent

foreach ($name in @('LAN_IP', 'ALLOWED_SUBNET')) {
  $value = [Environment]::GetEnvironmentVariable($name)

  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Environment variable $name is not set."
  }
}

$caddyExe = Join-Path $project 'tools\caddy\caddy.exe'
$dnsExe = Join-Path $project 'tools\coredns\coredns.exe'

$rules = @(
  @{
    Name = 'PwaLocalTools-HTTP'
    Protocol = 'TCP'
    LocalPort = 80
    Program = $caddyExe
  }
  @{
    Name = 'PwaLocalTools-HTTPS'
    Protocol = 'TCP'
    LocalPort = 443
    Program = $caddyExe
  }
  @{
    Name = 'PwaLocalTools-DNS-TCP'
    Protocol = 'TCP'
    LocalPort = 53
    Program = $dnsExe
  }
  @{
    Name = 'PwaLocalTools-DNS-UDP'
    Protocol = 'UDP'
    LocalPort = 53
    Program = $dnsExe
  }
)

$common = @{
  Direction = 'Inbound'
  Action = 'Allow'
  Enabled = 'True'
  Profile = 'Any'
  LocalAddress = $env:LAN_IP
  RemoteAddress = $env:ALLOWED_SUBNET
}

foreach ($rule in $rules) {
  $existing = Get-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue

  if ($null -ne $existing) {
    Set-NetFirewallRule @rule @common
  } else {
    New-NetFirewallRule @rule @common -DisplayName $rule.Name | Out-Null
  }

  Write-Host "Firewall rule applied: $($rule.Name)"
}
