# 🧪 Script 3: Testar OAuth e SSL
# Execute para verificar se tudo está funcionando

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🧪 Testando OAuth e SSL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Teste 1: Verificar se container está rodando
Write-Host "Teste 1: Container rodando?" -ForegroundColor Yellow
$containerStatus = docker ps --filter "name=gemini-python-app" --format "{{.Status}}"

if ($containerStatus) {
    Write-Host "✓ Container está rodando" -ForegroundColor Green
    Write-Host "  Status: $containerStatus" -ForegroundColor Gray
} else {
    Write-Host "✗ Container não está rodando!" -ForegroundColor Red
    Write-Host "Execute: .\2-rebuildar-container.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""

# Teste 2: Verificar certificado no container
Write-Host "Teste 2: Certificado no container?" -ForegroundColor Yellow
$certCheck = docker-compose exec -T gemini-app test -f /usr/local/share/ca-certificates/corporate-ca.crt
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Certificado existe no container" -ForegroundColor Green
    
    # Verifica se não é o exemplo
    $certContent = docker-compose exec -T gemini-app cat /usr/local/share/ca-certificates/corporate-ca.crt
    if ($certContent -match "PLACE YOUR CORPORATE") {
        Write-Host "✗ Certificado ainda é o EXEMPLO!" -ForegroundColor Red
        Write-Host "Execute: .\1-extrair-certificado.ps1" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    } else {
        Write-Host "✓ Certificado parece real" -ForegroundColor Green
    }
} else {
    Write-Host "✗ Certificado não encontrado no container" -ForegroundColor Red
    Write-Host "Execute: .\2-rebuildar-container.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""

# Teste 3: Testar SSL dentro do container
Write-Host "Teste 3: SSL funcionando?" -ForegroundColor Yellow
$sslTest = docker-compose exec -T gemini-app curl -I https://generativelanguage.googleapis.com 2>&1 | Select-String "HTTP"

if ($sslTest -match "200") {
    Write-Host "✓ SSL funcionando perfeitamente!" -ForegroundColor Green
    Write-Host "  Resposta: $sslTest" -ForegroundColor Gray
} else {
    Write-Host "✗ SSL ainda com problemas" -ForegroundColor Red
    Write-Host "  Resposta: $sslTest" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Possíveis causas:" -ForegroundColor Yellow
    Write-Host "1. Certificado incorreto" -ForegroundColor White
    Write-Host "2. Certificado não é o raiz da cadeia" -ForegroundColor White
    Write-Host "3. Formato do arquivo incorreto" -ForegroundColor White
    Write-Host ""
}

Write-Host ""

# Teste 4: Verificar se Streamlit está acessível
Write-Host "Teste 4: Streamlit acessível?" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Streamlit está acessível!" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Streamlit não está acessível" -ForegroundColor Red
    Write-Host "  Erro: $_" -ForegroundColor Gray
}

Write-Host ""

# Teste 5: Verificar credentials.json
Write-Host "Teste 5: Credenciais OAuth configuradas?" -ForegroundColor Yellow
if (Test-Path "credentials.json") {
    Write-Host "✓ credentials.json existe" -ForegroundColor Green
    
    # Verifica se não é o exemplo
    $credContent = Get-Content "credentials.json" -Raw | ConvertFrom-Json
    if ($credContent.web.client_id -match "123456789") {
        Write-Host "⚠ credentials.json ainda é o EXEMPLO!" -ForegroundColor Yellow
        Write-Host "  Baixe o arquivo real do Google Cloud Console" -ForegroundColor Gray
    } else {
        Write-Host "✓ credentials.json parece real" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ credentials.json não encontrado" -ForegroundColor Yellow
    Write-Host "  OAuth não funcionará sem este arquivo" -ForegroundColor Gray
    Write-Host "  Veja: GOOGLE_LOGIN_SETUP.md" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📊 RESUMO DOS TESTES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Resumo
$allOk = $true

if ($containerStatus) {
    Write-Host "✓ Container rodando" -ForegroundColor Green
} else {
    Write-Host "✗ Container não rodando" -ForegroundColor Red
    $allOk = $false
}

if ($certCheck -eq 0 -and $certContent -notmatch "PLACE YOUR CORPORATE") {
    Write-Host "✓ Certificado configurado" -ForegroundColor Green
} else {
    Write-Host "✗ Certificado não configurado" -ForegroundColor Red
    $allOk = $false
}

if ($sslTest -match "200") {
    Write-Host "✓ SSL funcionando" -ForegroundColor Green
} else {
    Write-Host "✗ SSL com problemas" -ForegroundColor Red
    $allOk = $false
}

if (Test-Path "credentials.json") {
    Write-Host "✓ OAuth configurado" -ForegroundColor Green
} else {
    Write-Host "⚠ OAuth não configurado (opcional)" -ForegroundColor Yellow
}

Write-Host ""

if ($allOk) {
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  🎉 TUDO FUNCIONANDO!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acesse agora: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🌑 影の結社 Zanei Kessha está pronta!" -ForegroundColor Magenta
    Write-Host ""
} else {
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  ⚠ ALGUNS PROBLEMAS ENCONTRADOS" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Verifique os erros acima e corrija antes de continuar." -ForegroundColor White
    Write-Host ""
}
