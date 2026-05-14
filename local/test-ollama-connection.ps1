# Testar conectividade Ollama Cloud com varias configuracoes

Write-Host "=== Teste 1: PowerShell Invoke-WebRequest (default) ===" -ForegroundColor Yellow
try {
    $resp = Invoke-WebRequest -Uri "https://ollama.com/v1/models" -Headers @{ "Authorization" = "Bearer $env:OLLAMA_API_KEY" } -TimeoutSec 5 -ErrorAction Stop
    Write-Host "OK! Status: $($resp.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "FALHA: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Teste 2: Com -SkipCertificateCheck ===" -ForegroundColor Yellow
try {
    $resp = Invoke-WebRequest -Uri "https://ollama.com/v1/models" -Headers @{ "Authorization" = "Bearer $env:OLLAMA_API_KEY" } -TimeoutSec 5 -SkipCertificateCheck -ErrorAction Stop
    Write-Host "OK! Status: $($resp.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "FALHA: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Teste 3: Python requests com verify=False ===" -ForegroundColor Yellow
python -c @"
import urllib3
urllib3.disable_warnings()
try:
    import requests
    resp = requests.get('https://ollama.com/v1/models', headers={'Authorization': 'Bearer $env:OLLAMA_API_KEY'}, timeout=5, verify=False)
    print(f'OK! Status: {resp.status_code}')
except Exception as e:
    print(f'FALHA: {type(e).__name__}: {e}')
"@

Write-Host ""
Write-Host "=== Teste 4: Python httpx (usado pelo langchain-openai) ===" -ForegroundColor Yellow
python -c @"
import httpx, os, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
try:
    with httpx.Client(verify=False, timeout=5) as client:
        resp = client.get('https://ollama.com/v1/models', headers={'Authorization': f\"Bearer {os.environ['OLLAMA_API_KEY']}\"})
        print(f'OK! Status: {resp.status_code}')
except Exception as e:
    print(f'FALHA: {type(e).__name__}: {e}')
"@

Write-Host ""
Write-Host "=== Teste 5: Verificar certificados do sistema ===" -ForegroundColor Yellow
python -c @"
import certifi, ssl
print(f'Certifi bundle: {certifi.where()}')
try:
    ctx = ssl.create_default_context()
    ctx.load_verify_locations(certifi.where())
    print('Certificados carregados OK')
except Exception as e:
    print(f'Erro certificados: {e}')
"@
