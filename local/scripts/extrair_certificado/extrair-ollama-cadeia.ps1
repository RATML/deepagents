# Extrair cadeia completa de certificados de ollama.com
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
$CertDir = Join-Path $RepoRoot "local\certs"
if (-not (Test-Path $CertDir)) { New-Item -ItemType Directory -Path $CertDir -Force | Out-Null }

Write-Host "Extraindo certificados de ollama.com..." -ForegroundColor Cyan

$tcpClient = New-Object System.Net.Sockets.TcpClient("ollama.com", 443)
$sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, { $true })

try {
    $sslStream.AuthenticateAsClient("ollama.com")
    $cert = $sslStream.RemoteCertificate
    $cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($cert)
    
    # Obter cadeia completa
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    $chain.Build($cert2) | Out-Null
    
    Write-Host "Certificados na cadeia: $($chain.ChainElements.Count)" -ForegroundColor Green
    
    # Salvar TODOS os certificados da cadeia
    $allCerts = ""
    for ($i = 0; $i -lt $chain.ChainElements.Count; $i++) {
        $element = $chain.ChainElements[$i]
        $c = $element.Certificate
        Write-Host "[$i] $($c.Subject)" -ForegroundColor Gray
        
        $bytes = $c.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
        $b64 = [System.Convert]::ToBase64String($bytes, [System.Base64FormattingOptions]::InsertLineBreaks)
        $allCerts += "-----BEGIN CERTIFICATE-----`n$b64`n-----END CERTIFICATE-----`n`n"
    }
    
    # Salvar bundle
    $bundlePath = Join-Path $CertDir "ollama-ca-bundle.crt"
    $allCerts | Out-File -FilePath $bundlePath -Encoding ASCII -NoNewline
    
    Write-Host ""
    Write-Host "Bundle salvo em: $bundlePath" -ForegroundColor Green
    Write-Host "Tamanho: $((Get-Item $bundlePath).Length) bytes" -ForegroundColor Gray
    
} catch {
    Write-Host "ERRO: $_" -ForegroundColor Red
} finally {
    $sslStream.Close()
    $tcpClient.Close()
}
