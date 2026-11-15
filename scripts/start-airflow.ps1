<#
.SYNOPSIS
    Starts the Airflow stack (docker-compose.airflow.yml).
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
$composeFile = Join-Path $root 'docker-compose.airflow.yml'

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Docker is not running. Start Docker Desktop and try again.'
}

# Bind-mounted folders must exist before the containers start.
foreach ($dir in 'airflow\dags', 'airflow\logs', 'airflow\plugins', 'airflow\config', 'data') {
    New-Item -ItemType Directory -Force -Path (Join-Path $root $dir) | Out-Null
}

if ($Pull) {
    docker compose -f $composeFile pull
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

# --build rebuilds the custom image (with DuckDB) when the Dockerfile or requirements change.
docker compose -f $composeFile up -d --build
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ''
Write-Host 'Airflow is starting at http://localhost:8088 (first start can take a minute or two)' -ForegroundColor Green
Write-Host 'Default login: airflow / airflow'
Write-Host "Stop with: docker compose -f `"$composeFile`" down"

if ($Logs) {
    docker compose -f $composeFile logs -f
}
