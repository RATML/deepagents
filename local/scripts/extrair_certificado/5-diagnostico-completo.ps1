# 🔍 Script 5: Diagnóstico Completo
# Execute quando algo não estiver funcionando

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔍 Diagnóstico Completo do Sistema" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$CertDir = Join-Path $RepoRoot "local\certs"
$CertPath = Join-Path $CertDir "corporate-ca.crt"

$report = @()
$errors = @()

# ============================================================
# 1. AMBIENTE
# ============================================================
Write-Host "1️⃣ Verificando Ambiente..." -ForegroundColor Yellow
Write-Host ""

# Docker
Write-Host "→ Docker:" -ForegroundColor Gray
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ $dockerVersion" -ForegroundColor Green
    $report += "✓ Docker instalado: $dockerVersion"
} else {
    Write-Host "  ✗ Docker não encontrado" -ForegroundColor Red
    $errors += "Docker não está instalado ou não está no PATH"
}

# Docker Compose
Write-Host "→ Docker Compose:" -ForegroundColor Gray
$composeVersion = docker-compose --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ $composeVersion" -ForegroundColor Green
    $report += "✓ Docker Compose instalado: $composeVersion"
} else {
    Write-Host "  ✗ Docker Compose não encontrado" -ForegroundColor Red
    $errors += "Docker Compose não está instalado"
}

# Docker rodando
Write-Host "→ Docker Daemon:" -ForegroundColor Gray
$dockerPs = docker ps 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Docker está rodando" -ForegroundColor Green
    $report += "✓ Docker daemon ativo"
} else {
    Write-Host "  ✗ Docker não está rodando" -ForegroundColor Red
    $errors += "Docker Desktop não está iniciado"
}

Write-Host ""

# ============================================================
# 2. ARQUIVOS DE CONFIGURAÇÃO
# ============================================================
Write-Host "2️⃣ Verificando Arquivos de Configuração..." -ForegroundColor Yellow
Write-Host ""

# .env
Write-Host "→ .env:" -ForegroundColor Gray
if (Test-Path ".env") {
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "GOOGLE_API_KEY=AIza") {
        Write-Host "  ✓ .env existe com API Key configurada" -ForegroundColor Green
        $report += "✓ .env configurado"
    } elseif ($envContent -match "GOOGLE_API_KEY=") {
        Write-Host "  ⚠ .env existe mas API Key parece inválida" -ForegroundColor Yellow
        $errors += ".env existe mas GOOGLE_API_KEY não começa com 'AIza'"
    } else {
        Write-Host "  ⚠ .env existe mas sem GOOGLE_API_KEY" -ForegroundColor Yellow
        $errors += ".env não contém GOOGLE_API_KEY"
    }
} else {
    Write-Host "  ✗ .env não encontrado" -ForegroundColor Red
    $errors += ".env não existe (copie de .env.example)"
}

# Dockerfile
Write-Host "→ Dockerfile:" -ForegroundColor Gray
if (Test-Path "Dockerfile") {
    Write-Host "  ✓ Dockerfile existe" -ForegroundColor Green
    $report += "✓ Dockerfile presente"
} else {
    Write-Host "  ✗ Dockerfile não encontrado" -ForegroundColor Red
    $errors += "Dockerfile não existe"
}

# docker-compose.yaml
Write-Host "→ docker-compose.yaml:" -ForegroundColor Gray
if (Test-Path "docker-compose.yaml") {
    Write-Host "  ✓ docker-compose.yaml existe" -ForegroundColor Green
    $report += "✓ docker-compose.yaml presente"
} else {
    Write-Host "  ✗ docker-compose.yaml não encontrado" -ForegroundColor Red
    $errors += "docker-compose.yaml não existe"
}

# requirements.txt
Write-Host "→ requirements.txt:" -ForegroundColor Gray
if (Test-Path "requirements.txt") {
    Write-Host "  ✓ requirements.txt existe" -ForegroundColor Green
    $report += "✓ requirements.txt presente"
} else {
    Write-Host "  ✗ requirements.txt não encontrado" -ForegroundColor Red
    $errors += "requirements.txt não existe"
}

Write-Host ""

# ============================================================
# 3. CERTIFICADO
# ============================================================
Write-Host "3️⃣ Verificando Certificado..." -ForegroundColor Yellow
Write-Host ""

Write-Host "→ Pasta local\certs:" -ForegroundColor Gray
if (Test-Path $CertDir) {
    Write-Host "  ✓ Pasta local\certs existe" -ForegroundColor Green
    $report += "✓ Pasta local\certs presente"
} else {
    Write-Host "  ✗ Pasta local\certs não encontrada" -ForegroundColor Red
    $errors += "Pasta local\certs não existe"
}

Write-Host "→ Certificado corporativo:" -ForegroundColor Gray
if (Test-Path $CertPath) {
    $certContent = Get-Content $CertPath -Raw
    $certSize = (Get-Item $CertPath).Length
    
    if ($certContent -match "PLACE YOUR CORPORATE") {
        Write-Host "  ⚠ Certificado é o EXEMPLO (placeholder)" -ForegroundColor Yellow
        $errors += "Certificado ainda é o exemplo. Execute: .\1-extrair-certificado.ps1"
    } elseif ($certSize -lt 500) {
        Write-Host "  ⚠ Certificado muito pequeno ($certSize bytes)" -ForegroundColor Yellow
        $errors += "Certificado parece inválido (muito pequeno)"
    } else {
        Write-Host "  ✓ Certificado existe e parece válido ($certSize bytes)" -ForegroundColor Green
        $report += "✓ Certificado corporativo configurado"
    }
} else {
    Write-Host "  ✗ Certificado não encontrado" -ForegroundColor Red
    $errors += "local\certs\corporate-ca.crt não existe. Execute: .\1-extrair-certificado.ps1"
}

Write-Host ""

# ============================================================
# 4. CONTAINER
# ============================================================
Write-Host "4️⃣ Verificando Container..." -ForegroundColor Yellow
Write-Host ""

Write-Host "→ Container existe:" -ForegroundColor Gray
$containerExists = docker ps -a --filter "name=gemini-python-app" --format "{{.Names}}" 2>&1
if ($containerExists -match "gemini-python-app") {
    Write-Host "  ✓ Container existe" -ForegroundColor Green
    $report += "✓ Container criado"
    
    Write-Host "→ Container rodando:" -ForegroundColor Gray
    $containerRunning = docker ps --filter "name=gemini-python-app" --format "{{.Status}}" 2>&1
    if ($containerRunning) {
        Write-Host "  ✓ Container está rodando" -ForegroundColor Green
        Write-Host "    Status: $containerRunning" -ForegroundColor Gray
        $report += "✓ Container ativo: $containerRunning"
    } else {
        Write-Host "  ✗ Container existe mas não está rodando" -ForegroundColor Red
        $errors += "Container parado. Execute: docker-compose up -d"
    }
} else {
    Write-Host "  ✗ Container não existe" -ForegroundColor Red
    $errors += "Container não foi criado. Execute: .\2-rebuildar-container.ps1"
}

Write-Host ""

# ============================================================
# 5. CONECTIVIDADE
# ============================================================
Write-Host "5️⃣ Verificando Conectividade..." -ForegroundColor Yellow
Write-Host ""

Write-Host "→ Frontend (localhost:3000):" -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
    Write-Host "  ✓ Streamlit acessível (HTTP $($response.StatusCode))" -ForegroundColor Green
    $report += "✓ Frontend respondendo na porta 3000"
} catch {
    Write-Host "  ✗ Streamlit não acessível" -ForegroundColor Red
    $errors += "Não foi possível acessar http://localhost:3000"
}

Write-Host "→ Google API (generativelanguage.googleapis.com):" -ForegroundColor Gray
try {
    $apiTest = curl.exe --ssl-no-revoke -I https://generativelanguage.googleapis.com 2>&1 | Select-String "HTTP"
    if ($apiTest -match "200") {
        Write-Host "  ✓ Google API acessível" -ForegroundColor Green
        $report += "✓ Conexão com Google API OK"
    } else {
        Write-Host "  ⚠ Google API retornou: $apiTest" -ForegroundColor Yellow
        $errors += "Google API não retornou 200 OK"
    }
} catch {
    Write-Host "  ✗ Erro ao conectar com Google API" -ForegroundColor Red
    $errors += "Falha ao conectar com generativelanguage.googleapis.com"
}

Write-Host ""

# ============================================================
# 6. OAUTH (OPCIONAL)
# ============================================================
Write-Host "6️⃣ Verificando OAuth (Opcional)..." -ForegroundColor Yellow
Write-Host ""

Write-Host "→ credentials.json:" -ForegroundColor Gray
if (Test-Path "credentials.json") {
    try {
        $credContent = Get-Content "credentials.json" -Raw | ConvertFrom-Json
        if ($credContent.web.client_id -match "123456789") {
            Write-Host "  ⚠ credentials.json é o EXEMPLO" -ForegroundColor Yellow
            $errors += "credentials.json ainda é o exemplo. Baixe o real do Google Cloud Console"
        } else {
            Write-Host "  ✓ credentials.json configurado" -ForegroundColor Green
            $report += "✓ OAuth configurado"
        }
    } catch {
        Write-Host "  ⚠ credentials.json inválido (JSON malformado)" -ForegroundColor Yellow
        $errors += "credentials.json não é um JSON válido"
    }
} else {
    Write-Host "  ⚠ credentials.json não encontrado (OAuth desabilitado)" -ForegroundColor Yellow
    Write-Host "    Isso é opcional. Veja: GOOGLE_LOGIN_SETUP.md" -ForegroundColor Gray
}

Write-Host ""

# ============================================================
# 7. BANCO DE DADOS
# ============================================================
Write-Host "7️⃣ Verificando Banco de Dados..." -ForegroundColor Yellow
Write-Host ""

Write-Host "→ Pasta data/:" -ForegroundColor Gray
if (Test-Path "data") {
    Write-Host "  ✓ Pasta data/ existe" -ForegroundColor Green
    $report += "✓ Pasta data/ presente"
} else {
    Write-Host "  ✗ Pasta data/ não encontrada" -ForegroundColor Red
    $errors += "Pasta data/ não existe"
}

Write-Host "→ conversations.db:" -ForegroundColor Gray
if (Test-Path "data\conversations.db") {
    $dbSize = (Get-Item "data\conversations.db").Length / 1KB
    Write-Host "  ✓ Banco de dados existe ($([math]::Round($dbSize, 2)) KB)" -ForegroundColor Green
    $report += "✓ Banco de dados criado"
} else {
    Write-Host "  ⚠ Banco ainda não foi criado" -ForegroundColor Yellow
    Write-Host "    Será criado automaticamente na primeira mensagem" -ForegroundColor Gray
}

Write-Host ""

# ============================================================
# RESUMO
# ============================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📊 RESUMO DO DIAGNÓSTICO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ Itens OK ($($report.Count)):" -ForegroundColor Green
foreach ($item in $report) {
    Write-Host "  $item" -ForegroundColor Gray
}

Write-Host ""

if ($errors.Count -gt 0) {
    Write-Host "❌ Problemas Encontrados ($($errors.Count)):" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  • $error" -ForegroundColor Yellow
    }
    Write-Host ""
    
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  🔧 AÇÕES RECOMENDADAS" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    
    # Sugestões baseadas nos erros
    if ($errors -match "Docker não está") {
        Write-Host "→ Inicie o Docker Desktop" -ForegroundColor White
    }
    if ($errors -match ".env") {
        Write-Host "→ Configure o arquivo .env com sua API Key" -ForegroundColor White
        Write-Host "  cp .env.example .env" -ForegroundColor Gray
        Write-Host "  # Edite .env e adicione GOOGLE_API_KEY" -ForegroundColor Gray
    }
    if ($errors -match "Certificado") {
        Write-Host "→ Extraia o certificado corporativo:" -ForegroundColor White
        Write-Host "  .\1-extrair-certificado.ps1" -ForegroundColor Gray
    }
    if ($errors -match "Container") {
        Write-Host "→ Rebuilde o container:" -ForegroundColor White
        Write-Host "  .\2-rebuildar-container.ps1" -ForegroundColor Gray
    }
    if ($errors -match "credentials.json") {
        Write-Host "→ Configure OAuth (opcional):" -ForegroundColor White
        Write-Host "  Veja: GOOGLE_LOGIN_SETUP.md" -ForegroundColor Gray
    }
    
    Write-Host ""
    
} else {
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  🎉 TUDO OK!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "Sistema está funcionando perfeitamente!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
    Write-Host ""
}

# Salva relatório em arquivo
$reportFile = "diagnostico_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$fullReport = @"
═══════════════════════════════════════════════════════
🔍 DIAGNÓSTICO COMPLETO - Zanei Kessha
═══════════════════════════════════════════════════════

Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

✅ ITENS OK ($($report.Count)):
$($report -join "`n")

❌ PROBLEMAS ENCONTRADOS ($($errors.Count)):
$($errors -join "`n")

═══════════════════════════════════════════════════════
"@

$fullReport | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host "→ Relatório salvo em: $reportFile" -ForegroundColor Cyan
Write-Host ""
