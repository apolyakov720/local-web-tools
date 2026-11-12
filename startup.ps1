$ErrorActionPreference = 'Stop'

$project = $PSScriptRoot
$scripts = Join-Path $project 'scripts'

$dns = $null
$caddy = $null

& (Join-Path $scripts 'env_load_config.ps1')
& (Join-Path $scripts 'dns_prepare.ps1')

Push-Location -LiteralPath $project

try {
  # Проверяем конфигурацию и доступность файлов сертификатов
  & .\tools\caddy\caddy.exe validate --config .\tools\caddy\Caddyfile

  if ($LASTEXITCODE -ne 0) {
    throw 'Caddy configuration validation failed.'
  }

  # Каждый скрипт возвращает объект запущенного процесса
  $dns = & (Join-Path $scripts 'dns_start.ps1')
  $caddy = & (Join-Path $scripts 'caddy_start.ps1')

  Write-Host "CoreDNS launcher PID: $($dns.Id)"
  Write-Host "Caddy launcher PID: $($caddy.Id)"
  Write-Host "Application: https://$env:DOMAIN/"
  Write-Host 'Press Ctrl+C to stop the stand.'

  # Следим за процессами, пока работает общий скрипт
  while ($true) {
    foreach ($service in @($dns, $caddy)) {
      if ($service.HasExited) {
        throw (
          '{0} exited with code {1}. Check .local/logs.' -f
            $service.ServiceName,
          $service.ExitCode
        )
      }
    }

    Start-Sleep -Milliseconds 500
  }
}
finally {
  # Останавливаем оболочки cmd.exe вместе с запущенными ими серверами.
  foreach ($service in @($caddy, $dns)) {
    if ($null -ne $service) {
      try {
        if (-not $service.HasExited) {
          & taskkill.exe /PID $service.Id /T /F | Out-Null
        }

        if (-not $service.WaitForExit(5000)) {
          throw "Process $($service.Id) did not stop in time."
        }
      }
      catch {
        Write-Warning "Process cleanup failed: $_"
      }
    }
  }

  Pop-Location
}
