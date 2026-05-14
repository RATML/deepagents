# Deep Agents Launcher
# Usa Ollama Cloud com SSL desabilitado (igual --ssl-no-revoke do curl)

param(
    [string]$Prompt = ""
)

# Carregar .env
$repoRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $repoRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Item -Path "env:$key" -Value $value
        }
    }
    Write-Host "ENV carregado de: $envFile" -ForegroundColor Green
}

# Desabilitar verificacao SSL (igual --ssl-no-revoke do curl)
Set-Item -Path "env:PYTHONHTTPSVERIFY" -Value "0"
Set-Item -Path "env:CURL_CA_BUNDLE" -Value ""
Set-Item -Path "env:REQUESTS_CA_BUNDLE" -Value ""
Set-Item -Path "env:SSL_CERT_FILE" -Value ""
Set-Item -Path "env:SSL_CERT_DIR" -Value ""
Write-Host "SSL verification: DISABLED (modo compativel com curl --ssl-no-revoke)" -ForegroundColor Yellow

# Configurar como OpenAI-compativel
if ($env:OLLAMA_HOST -and $env:OLLAMA_HOST -ne "http://localhost:11434") {
    Set-Item -Path "env:OPENAI_API_KEY" -Value $env:OLLAMA_API_KEY
    Set-Item -Path "env:OPENAI_BASE_URL" -Value $env:OLLAMA_HOST
    Write-Host ""
    Write-Host "Configurando como OpenAI-compativel:" -ForegroundColor Cyan
    Write-Host "  OPENAI_BASE_URL = $env:OLLAMA_HOST" -ForegroundColor Cyan
    Write-Host "  OPENAI_API_KEY  = $($env:OLLAMA_API_KEY.Substring(0,20))..." -ForegroundColor Cyan
}

Write-Host ""

# Executar
if ($Prompt) {
    deepagents -n $Prompt
} else {
    deepagents
}
