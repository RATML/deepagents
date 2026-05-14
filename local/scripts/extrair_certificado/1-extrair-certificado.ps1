# 🔐 Script 1: Extrair Certificado Corporativo
# Execute este script para obter o certificado real da sua empresa

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔐 Extraindo Certificado Corporativo" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$CertPath = Join-Path $RepoRoot "local\certs\corporate-ca.crt"
$CertDir = Split-Path $CertPath -Parent
if (-not (Test-Path $CertDir)) { New-Item -ItemType Directory -Path $CertDir -Force | Out-Null }

# Testa conexão primeiro
Write-Host "→ Testando conexão com Google API..." -ForegroundColor Yellow
$testResult = curl.exe --ssl-no-revoke -I https://generativelanguage.googleapis.com 2>&1 | Select-String "HTTP"

if ($testResult) {
    Write-Host "✓ Conexão OK" -ForegroundColor Green
} else {
    Write-Host "✗ Erro de conexão" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "→ Extraindo certificado..." -ForegroundColor Yellow

# Extrai o certificado usando OpenSSL (se disponível) ou PowerShell
try {
    # Método PowerShell nativo
    $tcpClient = New-Object System.Net.Sockets.TcpClient("generativelanguage.googleapis.com", 443)
    $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })
    
    try {
        $sslStream.AuthenticateAsClient("generativelanguage.googleapis.com")
        $cert = $sslStream.RemoteCertificate
        
        # Converte para X509Certificate2 para obter a cadeia
        $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
        
        # Obtém a cadeia de certificados
        $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
        $chain.Build($cert2) | Out-Null
        
        # Pega o certificado raiz (último da cadeia)
        $rootCert = $chain.ChainElements[$chain.ChainElements.Count - 1].Certificate
        
        Write-Host "✓ Certificado encontrado!" -ForegroundColor Green
        Write-Host "  Emissor: $($rootCert.Issuer)" -ForegroundColor Gray
        Write-Host "  Válido até: $($rootCert.NotAfter)" -ForegroundColor Gray
        Write-Host ""
        
        # Exporta como PEM
        $certBytes = $rootCert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
        $certBase64 = [System.Convert]::ToBase64String($certBytes, [System.Base64FormattingOptions]::InsertLineBreaks)
        
        $certPem = "-----BEGIN CERTIFICATE-----`n$certBase64`n-----END CERTIFICATE-----"
        
        # Salva o certificado
        $certPem | Out-File -FilePath $CertPath -Encoding ASCII -NoNewline
        
        Write-Host "✓ Certificado salvo em: $CertPath" -ForegroundColor Green
        Write-Host ""
        Write-Host "→ Verificando arquivo..." -ForegroundColor Yellow
        
        $fileSize = (Get-Item $CertPath).Length
        Write-Host "  Tamanho: $fileSize bytes" -ForegroundColor Gray
        
        if ($fileSize -gt 500) {
            Write-Host "✓ Arquivo parece válido!" -ForegroundColor Green
        } else {
            Write-Host "⚠ Arquivo muito pequeno, pode estar incorreto" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "  ✓ CERTIFICADO EXTRAÍDO COM SUCESSO!" -ForegroundColor Green
        Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host ""
        Write-Host "Próximo passo: Execute o script 2-rebuildar-container.ps1" -ForegroundColor Cyan
        Write-Host ""
        
    } finally {
        $sslStream.Close()
        $tcpClient.Close()
    }
    
} catch {
    Write-Host "✗ Erro ao extrair certificado: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  ⚠ MÉTODO MANUAL NECESSÁRIO" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Siga estas instruções:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Abra Chrome/Edge" -ForegroundColor White
    Write-Host "2. Acesse: https://generativelanguage.googleapis.com" -ForegroundColor White
    Write-Host "3. Clique no cadeado 🔒" -ForegroundColor White
    Write-Host "4. Clique em 'Certificado'" -ForegroundColor White
    Write-Host "5. Aba 'Caminho de Certificação' → Selecione o TOPO" -ForegroundColor White
    Write-Host "6. 'Exibir Certificado' → Aba 'Detalhes'" -ForegroundColor White
    Write-Host "7. 'Copiar para Arquivo...'" -ForegroundColor White
    Write-Host "8. Formato: 'X.509 codificado em Base-64 (.CER)'" -ForegroundColor White
    Write-Host "9. Salvar como: local\certs\corporate-ca.crt (na raiz do repositório)" -ForegroundColor White
    Write-Host ""
    Write-Host "Depois execute: .\2-rebuildar-container.ps1" -ForegroundColor Cyan
    Write-Host ""
}
