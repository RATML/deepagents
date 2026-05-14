# 🗑️ Script 6: Limpar Tokens de Autenticação
# Execute se estiver com problemas de login

Write-Host ""
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host "  Limpar Tokens de Autenticacao" -ForegroundColor Yellow
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host ""

$tokensFile = "data\user_tokens.json"
$oauthStateFile = "data\.oauth_state.json"

$cleaned = $false

# Limpa user_tokens.json
if (Test-Path $tokensFile) {
    Remove-Item $tokensFile -Force
    Write-Host "OK Tokens de usuario removidos" -ForegroundColor Green
    $cleaned = $true
} else {
    Write-Host "! Nenhum token de usuario encontrado" -ForegroundColor Gray
}

# Limpa .oauth_state.json
if (Test-Path $oauthStateFile) {
    Remove-Item $oauthStateFile -Force
    Write-Host "OK Cache OAuth removido" -ForegroundColor Green
    $cleaned = $true
} else {
    Write-Host "! Nenhum cache OAuth encontrado" -ForegroundColor Gray
}

Write-Host ""

if ($cleaned) {
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "  Tokens Limpos com Sucesso!" -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Proximo passo:" -ForegroundColor Cyan
    Write-Host "1. Adicione seu email como testador no Google Cloud Console" -ForegroundColor White
    Write-Host "2. Acesse: http://localhost:3000" -ForegroundColor White
    Write-Host "3. Faca login novamente" -ForegroundColor White
} else {
    Write-Host "=======================================================" -ForegroundColor Gray
    Write-Host "  Nenhum Token para Limpar" -ForegroundColor Gray
    Write-Host "=======================================================" -ForegroundColor Gray
}

Write-Host ""
