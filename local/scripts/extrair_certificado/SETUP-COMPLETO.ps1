# Setup Completo - Zanei Kessha (Shadow AI)
# Execute este script para configurar tudo automaticamente

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Magenta
Write-Host "  Setup Completo - Zanei Kessha" -ForegroundColor Magenta
Write-Host "=======================================================" -ForegroundColor Magenta
Write-Host ""

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$CertPath = Join-Path $RepoRoot "local\certs\corporate-ca.crt"

# Banner
Write-Host "  Shadow AI - Operando nas sombras da corporacao" -ForegroundColor DarkGray
Write-Host ""

# Verifica se Docker esta rodando
Write-Host "-> Verificando Docker..." -ForegroundColor Yellow
$dockerRunning = docker ps 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "X Docker nao esta rodando!" -ForegroundColor Red
    Write-Host "  Inicie o Docker Desktop e tente novamente" -ForegroundColor White
    Write-Host ""
    exit 1
}
Write-Host "OK Docker esta rodando" -ForegroundColor Green
Write-Host ""

# Etapa 1: Certificado
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPA 1/3: Certificado Corporativo" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

if (Test-Path $CertPath) {
    $certContent = Get-Content $CertPath -Raw
    if ($certContent -match "PLACE YOUR CORPORATE") {
        Write-Host "! Certificado e o exemplo, extraindo o real..." -ForegroundColor Yellow
        Write-Host ""
        & ".\1-extrair-certificado.ps1"
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "X Falha ao extrair certificado" -ForegroundColor Red
            Write-Host "  Use o metodo manual descrito em local\certs\CERTIFICADO_CORPORATIVO.md" -ForegroundColor Yellow
            Write-Host ""
            exit 1
        }
    } else {
        Write-Host "OK Certificado ja existe e parece real" -ForegroundColor Green
    }
} else {
    Write-Host "! Certificado nao existe, extraindo..." -ForegroundColor Yellow
    Write-Host ""
    & ".\1-extrair-certificado.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "X Falha ao extrair certificado" -ForegroundColor Red
        Write-Host "  Use o metodo manual descrito em local\certs\CERTIFICADO_CORPORATIVO.md" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

Write-Host ""

# Etapa 2: Rebuildar
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPA 2/3: Rebuildar Container" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

& ".\2-rebuildar-container.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "X Falha ao rebuildar container" -ForegroundColor Red
    Write-Host "  Verifique os logs: docker-compose logs" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""

# Etapa 3: Testar
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "  ETAPA 3/3: Testes Finais" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

& ".\3-testar-oauth.ps1"

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Magenta
Write-Host "  SETUP COMPLETO!" -ForegroundColor Magenta
Write-Host "=======================================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "A Shadow AI esta operacional!" -ForegroundColor Magenta
Write-Host ""
Write-Host "-> Acesse: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Funcionalidades:" -ForegroundColor White
Write-Host "  OK Chat com Gemini AI" -ForegroundColor Green
Write-Host "  OK Tema roxo mistico" -ForegroundColor Green
Write-Host "  OK Login com Google (se configurado)" -ForegroundColor Green
Write-Host "  OK Memoria persistente" -ForegroundColor Green
Write-Host "  OK Historico de conversas" -ForegroundColor Green
Write-Host ""
Write-Host "Documentacao:" -ForegroundColor White
Write-Host "  -> README.md - Visao geral" -ForegroundColor Gray
Write-Host "  -> docs/GOOGLE_LOGIN_SETUP.md - Configurar OAuth" -ForegroundColor Gray
Write-Host "  -> docs/ - Documentacao completa" -ForegroundColor Gray
Write-Host ""
Write-Host "Lute nas sombras!" -ForegroundColor DarkGray
Write-Host ""
