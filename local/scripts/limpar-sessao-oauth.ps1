# Script para limpar sessão OAuth expirada
# Use este script se estiver tendo problemas com "OAuth session expired"

Write-Host "🔧 Limpando sessão OAuth..." -ForegroundColor Cyan
Write-Host ""

# 1. Remove cache OAuth
$oauthCache = "data/.oauth_state.json"
if (Test-Path $oauthCache) {
    Remove-Item $oauthCache -Force
    Write-Host "✅ Cache OAuth removido" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Cache OAuth não encontrado" -ForegroundColor Yellow
}

# 2. Remove tokens de usuário (opcional - descomente se necessário)
# $tokensFile = "data/user_tokens.json"
# if (Test-Path $tokensFile) {
#     Remove-Item $tokensFile -Force
#     Write-Host "✅ Tokens de usuário removidos" -ForegroundColor Green
# }

# 3. Reinicia o container Docker
Write-Host ""
Write-Host "🔄 Reiniciando container Docker..." -ForegroundColor Cyan
docker-compose restart gemini-app

Write-Host ""
Write-Host "✅ Sessão OAuth limpa com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📌 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Aguarde o container reiniciar (5-10 segundos)"
Write-Host "   2. Acesse http://localhost:3000"
Write-Host "   3. Faça login novamente com sua conta Google"
Write-Host ""
