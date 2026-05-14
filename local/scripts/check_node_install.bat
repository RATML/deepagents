@echo off
REM Valida instalacao do Node.js e se esta no PATH
REM Uso: scripts\check_node_install.bat

set OK=0
echo.
echo === Verificacao Node.js / npm no PATH ===
echo.

where node >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] node encontrado
    for /f "tokens=*" %%i in ('node --version 2^>nul') do echo      Versao: %%i
    for /f "tokens=*" %%i in ('where node 2^>nul') do echo      Caminho: %%i
) else (
    echo [FALTA] node nao encontrado no PATH
    set OK=1
)

echo.

where npm >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] npm encontrado
    for /f "tokens=*" %%i in ('npm --version 2^>nul') do echo      Versao: %%i
    for /f "tokens=*" %%i in ('where npm 2^>nul') do echo      Caminho: %%i
) else (
    echo [FALTA] npm nao encontrado no PATH
    set OK=1
)

echo.

if %OK% equ 0 (
    echo Resultado: Node.js esta instalado e no PATH. Pode usar npm no frontend.
) else (
    echo Resultado: Instale o Node.js LTS em https://nodejs.org e reinicie o terminal.
)

echo.
exit /b %OK%
