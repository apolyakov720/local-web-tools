$project = Split-Path -Path $PSScriptRoot -Parent

New-Item -ItemType Directory -Force -Path (Join-Path $project '.local\logs') | Out-Null

# > пересоздаёт журнал, 2>&1 объединяет обычный вывод и ошибки.
$parameters = @{
    FilePath = $env:ComSpec
    ArgumentList = '/d /s /c ""tools\caddy\caddy.exe" run --config "tools\caddy\Caddyfile" > ".local\logs\caddy.log" 2>&1"'
    WorkingDirectory = $project
    WindowStyle = 'Hidden'
    PassThru = $true
    ErrorAction = 'Stop'
}

$process = Start-Process @parameters
Add-Member -InputObject $process -NotePropertyName ServiceName -NotePropertyValue 'Caddy' -PassThru
