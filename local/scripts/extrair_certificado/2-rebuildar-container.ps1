# 🐳 Script 2: Rebuildar Container Docker
# Execute após extrair o certificado corporativo

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🐳 Rebuildando Container Docker" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$CertPath = Join-Path $RepoRoot "local\certs\corporate-ca.crt"

# Verifica se o certificado existe
if (-not (Test-Path $CertPath)) {
    Write-Host "✗ ERRO: Certificado não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Execute primeiro: .\1-extrair-certificado.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Verifica se o certificado não é o exemplo
$certContent = Get-Content $CertPath -Raw
if ($certContent -match "PLACE YOUR CORPORATE") {
    Write-Host "✗ ERRO: Certificado ainda é o exemplo!" -ForegroundColor Red
    Write-Host ""
    Write-Host "O arquivo em $CertPath precisa ser o certificado REAL da empresa." -ForegroundColor Yellow
    Write-Host "Execute: .\1-extrair-certificado.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "✓ Certificado encontrado" -ForegroundColor Green
$fileSize = (Get-Item $CertPath).Length
Write-Host "  Tamanho: $fileSize bytes" -ForegroundColor Gray
Write-Host ""

# Para containers existentes
Write-Host "→ Parando containers..." -ForegroundColor Yellow
docker-compose down

Write-Host ""
Write-Host "→ Rebuildando imagem (isso pode levar 1-2 minutos)..." -ForegroundColor Yellow
Write-Host ""

# Rebuilda com o novo certificado
docker-compose up --build -d

Write-Host ""
Write-Host "→ Aguardando container iniciar..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Verifica se está rodando
$status = docker-compose ps --format json | ConvertFrom-Json
if ($status.State -eq "running") {
    Write-Host "✓ Container rodando!" -ForegroundColor Green
} else {
    Write-Host "⚠ Container não está rodando" -ForegroundColor Yellow
    Write-Host "Verificando logs..." -ForegroundColor Gray
    docker-compose logs --tail=20
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ CONTAINER REBUILDADO!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Próximo passo: Execute o script 3-testar-oauth.ps1" -ForegroundColor Cyan
Write-Host "Ou acesse: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
