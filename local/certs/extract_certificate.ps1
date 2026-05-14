# Script para extrair certificado corporativo no Windows
# Execute este script para obter o certificado real da sua empresa

Write-Host "🔐 Extraindo certificado corporativo..." -ForegroundColor Cyan
Write-Host ""

# Método 1: Extrair do site do Google
Write-Host "Método 1: Extrair certificado do site do Google" -ForegroundColor Yellow
Write-Host "Executando: curl.exe --ssl-no-revoke -v https://generativelanguage.googleapis.com 2>&1" -ForegroundColor Gray
Write-Host ""

$output = curl.exe --ssl-no-revoke -v https://generativelanguage.googleapis.com 2>&1 | Out-String

# Procura pelo issuer do certificado
if ($output -match "issuer: (.+)") {
    $issuer = $matches[1]
    Write-Host "✓ Certificado emitido por: $issuer" -ForegroundColor Green
    Write-Host ""
}

# Método 2: Extrair via PowerShell
Write-Host "Método 2: Extrair certificado via PowerShell" -ForegroundColor Yellow
Write-Host ""

try {
    # Conecta ao site e obtém o certificado
    $url = "https://generativelanguage.googleapis.com"
    $request = [System.Net.HttpWebRequest]::Create($url)
    $request.Timeout = 10000
    
    try {
        $response = $request.GetResponse()
    } catch {
        # Ignora erro SSL, queremos apenas o certificado
    }
    
    # Obtém o certificado da cadeia
    $cert = $request.ServicePoint.Certificate
    
    if ($cert) {
        $certBytes = $cert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
        $certBase64 = [System.Convert]::ToBase64String($certBytes, [System.Base64FormattingOptions]::InsertLineBreaks)
        
        $certPem = "-----BEGIN CERTIFICATE-----`n$certBase64`n-----END CERTIFICATE-----"
        
        # Salva o certificado
        $certPath = "certs\corporate-ca.crt"
        $certPem | Out-File -FilePath $certPath -Encoding ASCII
        
        Write-Host "✓ Certificado extraído com sucesso!" -ForegroundColor Green
        Write-Host "✓ Salvo em: $certPath" -ForegroundColor Green
        Write-Host ""
        Write-Host "Conteúdo do certificado:" -ForegroundColor Cyan
        Write-Host $certPem -ForegroundColor Gray
        Write-Host ""
        Write-Host "Próximos passos:" -ForegroundColor Yellow
        Write-Host "1. Verifique o arquivo: certs\corporate-ca.crt" -ForegroundColor White
        Write-Host "2. Rebuilde o container: docker-compose down && docker-compose up --build -d" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "✗ Não foi possível extrair o certificado" -ForegroundColor Red
    }
    
} catch {
    Write-Host "✗ Erro ao extrair certificado: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Método alternativo:" -ForegroundColor Yellow
    Write-Host "1. Abra o Chrome/Edge" -ForegroundColor White
    Write-Host "2. Acesse: https://generativelanguage.googleapis.com" -ForegroundColor White
    Write-Host "3. Clique no cadeado 🔒 na barra de endereço" -ForegroundColor White
    Write-Host "4. Clique em 'Certificado'" -ForegroundColor White
    Write-Host "5. Vá na aba 'Caminho de Certificação'" -ForegroundColor White
    Write-Host "6. Selecione o certificado RAIZ (topo da árvore)" -ForegroundColor White
    Write-Host "7. Clique em 'Exibir Certificado'" -ForegroundColor White
    Write-Host "8. Vá na aba 'Detalhes'" -ForegroundColor White
    Write-Host "9. Clique em 'Copiar para Arquivo...'" -ForegroundColor White
    Write-Host "10. Escolha 'X.509 codificado em Base 64 (.CER)'" -ForegroundColor White
    Write-Host "11. Salve como: certs\corporate-ca.crt" -ForegroundColor White
}

Write-Host ""
Write-Host "Script finalizado." -ForegroundColor Cyan
