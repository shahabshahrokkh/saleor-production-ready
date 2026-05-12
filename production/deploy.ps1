#!/usr/bin/env pwsh
# Production deployment script for Windows
# Run from the production/ directory

param(
    [switch]$SkipStorefront,
    [switch]$Rebuild
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "=== Saleor Production Deploy ===" -ForegroundColor Cyan

# Check .env exists
if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found. Copy .env.example to .env and configure it." -ForegroundColor Red
    exit 1
}

# Step 1: Build and start backend services
Write-Host "`n[1/3] Building and starting backend (api, worker, db, redis)..." -ForegroundColor Yellow
if ($Rebuild) {
    docker compose build --no-cache api worker
} else {
    docker compose build api worker
}
docker compose up -d db redis
Write-Host "Waiting for database to be ready..."
Start-Sleep -Seconds 5
docker compose up -d api worker

# Step 2: Wait for API to be healthy
Write-Host "`n[2/3] Waiting for API to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
do {
    $attempt++
    Start-Sleep -Seconds 3
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/graphql/" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "API is ready!" -ForegroundColor Green
            break
        }
    } catch {}
    Write-Host "  Attempt $attempt/$maxAttempts..."
} while ($attempt -lt $maxAttempts)

if ($attempt -ge $maxAttempts) {
    Write-Host "ERROR: API did not start in time. Check logs: docker compose logs api" -ForegroundColor Red
    exit 1
}

# Step 3: Build and start storefront
if (-not $SkipStorefront) {
    Write-Host "`n[3/3] Building storefront (requires API to be running)..." -ForegroundColor Yellow
    
    $apiUrl = if ($env:NEXT_PUBLIC_SALEOR_API_URL) { $env:NEXT_PUBLIC_SALEOR_API_URL } else { "http://localhost:8000/graphql/" }
    $storefrontUrl = if ($env:NEXT_PUBLIC_STOREFRONT_URL) { $env:NEXT_PUBLIC_STOREFRONT_URL } else { "http://localhost:3000" }
    $channel = if ($env:NEXT_PUBLIC_DEFAULT_CHANNEL) { $env:NEXT_PUBLIC_DEFAULT_CHANNEL } else { "default-channel" }
    
    $buildCmd = "docker build --network=host " +
        "--build-arg NEXT_PUBLIC_SALEOR_API_URL=$apiUrl " +
        "--build-arg NEXT_PUBLIC_STOREFRONT_URL=$storefrontUrl " +
        "--build-arg NEXT_PUBLIC_DEFAULT_CHANNEL=$channel " +
        "-f production/Dockerfile.storefront -t production-storefront .."
    
    if ($Rebuild) { $buildCmd += " --no-cache" }
    Invoke-Expression $buildCmd
    
    docker compose -f production/docker-compose.yml up -d storefront
}

Write-Host "`n=== Deployment Complete ===" -ForegroundColor Green
Write-Host "  API:        http://localhost:8000/graphql/" -ForegroundColor Cyan
Write-Host "  Storefront: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "To create admin user: docker compose exec api python manage.py createsuperuser"
