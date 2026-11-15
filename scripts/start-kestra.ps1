<#
.SYNOPSIS
    Starts the Kestra stack (docker-compose.yml).
.PARAMETER Pull
    Pull the latest images before starting.
.PARAMETER Logs
    Follow container logs after starting.
#>
[CmdletBinding()]
param(
    [switch]$Pull,
    [switch]$Logs
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $root 'docker-compose.yml'

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Docker is not running. Start Docker Desktop and try again.'
}

# Bind-mounted folders must exist before the containers start.
foreach ($dir in 'data', 'kestra\flows') {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

if ($Pull) {
    docker compose -f $composeFile pull
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

docker compose -f $composeFile up -d
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host 'Kestra is starting at http://localhost:8080' -ForegroundColor Green
Write-Host 'Default login: admin@raven.local / Raven123!'
Write-Host "Stop with: docker compose -f `"$composeFile`" down"

if ($Logs) {
    docker compose -f $composeFile logs -f
}
