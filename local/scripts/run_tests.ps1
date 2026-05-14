# Script para rodar todos os testes do projeto (backend + frontend)
# Uso: .\scripts\run_tests.ps1   ou   pwsh -File scripts\run_tests.ps1
# Opcional: .\scripts\run_tests.ps1 -InstallDeps   instala dependências antes de rodar

param([switch]$InstallDeps)

$ErrorActionPreference = "Continue"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$failed = 0

if ($InstallDeps) {
    Write-Host "`nInstalando dependencias do backend..." -ForegroundColor Cyan
    python -m pip install -r backend/requirements.txt -q
    if (Test-Path (Join-Path $root "frontend\package.json")) {
        Write-Host "Instalando dependencias do frontend..." -ForegroundColor Cyan
        Push-Location (Join-Path $root "frontend")
        npm install 2>&1 | Out-Null
        Pop-Location
    }
}

Write-Host "`n========== Backend (pytest) ==========" -ForegroundColor Cyan
$pytestOk = $false
try {
    python -m pytest backend/tests/ -v --tb=short 2>&1
    $pytestOk = ($LASTEXITCODE -eq 0)
    if (-not $pytestOk) { $failed = 1 }
} catch {
    $pytestOk = $false
    $failed = 1
}
if (-not $pytestOk) {
    Write-Host "Dica: instale as dependencias do backend com: python -m pip install -r backend/requirements.txt" -ForegroundColor Yellow
    Write-Host "Ou rode este script com -InstallDeps: .\scripts\run_tests.ps1 -InstallDeps" -ForegroundColor Yellow
}

Write-Host "`n========== Frontend (Vitest) ==========" -ForegroundColor Cyan
$frontendPath = Join-Path $root "frontend"
$hasNode = $null -ne (Get-Command node -ErrorAction SilentlyContinue)
if (-not $hasNode) {
    Write-Host "Node.js nao encontrado. Instale em https://nodejs.org para rodar os testes do frontend." -ForegroundColor Yellow
} elseif (Test-Path (Join-Path $frontendPath "node_modules")) {
    try {
        Push-Location $frontendPath
        npm run test:run 2>&1
        if ($LASTEXITCODE -ne 0) { $failed = 1 }
    } catch {
        Write-Host "Erro ao rodar testes do frontend." -ForegroundColor Yellow
        $failed = 1
    } finally {
        Pop-Location
    }
} else {
    Write-Host "Frontend: node_modules não encontrado. Execute: cd frontend; npm install" -ForegroundColor Yellow
    Write-Host "Depois rode este script novamente." -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
if ($failed -eq 0) {
    Write-Host "Todos os testes concluídos com sucesso." -ForegroundColor Green
} else {
    Write-Host "Alguns testes falharam ou não puderam ser executados." -ForegroundColor Red
}
exit $failed
