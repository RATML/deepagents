# Valida instalação do Node.js e se está no PATH
# Uso (PowerShell):
#   .\scripts\check_node_install.ps1
# Se aparecer "execucao de scripts desabilitada", use uma das opcoes:
#   powershell -ExecutionPolicy Bypass -File .\scripts\check_node_install.ps1
#   OU (permanente para seu usuario): Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Alternativa sem PowerShell: scripts\check_node_install.bat

$ok = $true

Write-Host "`n=== Verificacao Node.js / npm no PATH ===" -ForegroundColor Cyan
Write-Host ""

# Node
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVer = node --version 2>&1
    Write-Host "[OK] node encontrado" -ForegroundColor Green
    Write-Host "     Versao: $nodeVer"
    Write-Host "     Caminho: $($nodeCmd.Source)"
} else {
    Write-Host "[FALTA] node nao encontrado no PATH" -ForegroundColor Red
    $ok = $false
}

Write-Host ""

# npm
$npmCmd = Get-Command npm -ErrorAction SilentlyContinue
if ($npmCmd) {
    $npmVer = npm --version 2>&1
    Write-Host "[OK] npm encontrado" -ForegroundColor Green
    Write-Host "     Versao: $npmVer"
    Write-Host "     Caminho: $($npmCmd.Source)"
} else {
    Write-Host "[FALTA] npm nao encontrado no PATH" -ForegroundColor Red
    $ok = $false
}

Write-Host ""

# Resumo do PATH (pastas que costumam ter Node)
$pathEnv = [Environment]::GetEnvironmentVariable("Path", "User") + ";" + [Environment]::GetEnvironmentVariable("Path", "Machine")
$pathEntries = $pathEnv -split ";" | Where-Object { $_ -match "node|npm|Program Files\\node" }
if ($pathEntries.Count -gt 0) {
    Write-Host "Entradas no PATH relacionadas a Node/npm:" -ForegroundColor Cyan
    $pathEntries | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "Nenhuma pasta tipica do Node encontrada no PATH." -ForegroundColor Yellow
}

Write-Host ""

if ($ok) {
    Write-Host "Resultado: Node.js esta instalado e no PATH. Pode usar 'npm install' e 'npm run dev' no frontend." -ForegroundColor Green
} else {
    Write-Host "Resultado: Instale o Node.js LTS em https://nodejs.org e reinicie o terminal (ou o Cursor)." -ForegroundColor Yellow
}

Write-Host ""
exit $(if ($ok) { 0 } else { 1 })
