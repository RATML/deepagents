# 🗑️ Script 4: Limpar Histórico de Conversas
# CUIDADO: Isso apaga TODAS as conversas salvas!

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "  🗑️ LIMPAR HISTÓRICO DE CONVERSAS" -ForegroundColor Red
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""
Write-Host "⚠️  ATENÇÃO: Isso apagará TODAS as conversas salvas!" -ForegroundColor Yellow
Write-Host ""

# Verifica se o banco existe
if (-not (Test-Path "data\conversations.db")) {
    Write-Host "✓ Banco de dados não existe (já está limpo)" -ForegroundColor Green
    Write-Host ""
    exit 0
}

# Mostra estatísticas antes de apagar
Write-Host "→ Estatísticas atuais:" -ForegroundColor Cyan
$dbSize = (Get-Item "data\conversations.db").Length / 1KB
Write-Host "  Tamanho do banco: $([math]::Round($dbSize, 2)) KB" -ForegroundColor Gray

# Conta registros (aproximado)
$dbContent = Get-Content "data\conversations.db" -Raw
$sessionCount = ([regex]::Matches($dbContent, "session_id")).Count
Write-Host "  Sessões aproximadas: $sessionCount" -ForegroundColor Gray
Write-Host ""

# Confirmação
$confirmation = Read-Host "Tem certeza que deseja apagar TUDO? (digite SIM para confirmar)"

if ($confirmation -ne "SIM") {
    Write-Host ""
    Write-Host "✓ Operação cancelada" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "→ Criando backup..." -ForegroundColor Yellow

# Cria backup antes de apagar
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = "data\conversations_backup_$timestamp.db"

try {
    Copy-Item "data\conversations.db" $backupPath
    Write-Host "✓ Backup criado: $backupPath" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro ao criar backup: $_" -ForegroundColor Red
    Write-Host "Operação cancelada por segurança" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "→ Apagando banco de dados..." -ForegroundColor Yellow

try {
    Remove-Item "data\conversations.db" -Force
    Write-Host "✓ Banco de dados apagado" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro ao apagar: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Apaga também o cache OAuth (se existir)
if (Test-Path "data\.oauth_state.json") {
    Remove-Item "data\.oauth_state.json" -Force
    Write-Host "✓ Cache OAuth limpo" -ForegroundColor Green
}

if (Test-Path "data\user_tokens.json") {
    Write-Host ""
    $cleanTokens = Read-Host "Apagar também os tokens de login Google? (S/N)"
    if ($cleanTokens -eq "S") {
        Remove-Item "data\user_tokens.json" -Force
        Write-Host "✓ Tokens de login apagados" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✓ HISTÓRICO LIMPO COM SUCESSO!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "→ Backup salvo em: $backupPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "O banco será recriado automaticamente vazio quando você" -ForegroundColor Gray
Write-Host "enviar a primeira mensagem." -ForegroundColor Gray
Write-Host ""
Write-Host "Para restaurar o backup:" -ForegroundColor Yellow
Write-Host "  Copy-Item $backupPath data\conversations.db" -ForegroundColor White
Write-Host ""
