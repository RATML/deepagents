@echo off
REM Script para rodar todos os testes do projeto (backend + frontend)
REM Uso: scripts\run_tests.bat

set ROOT=%~dp0..
cd /d "%ROOT%"
set FAILED=0

echo.
echo ========== Backend (pytest) ==========
python -m pytest backend/tests/ -v --tb=short
if errorlevel 1 set FAILED=1

echo.
echo ========== Frontend (Vitest) ==========
if exist "frontend\node_modules" (
    cd frontend
    call npm run test:run
    if errorlevel 1 set FAILED=1
    cd ..
) else (
    echo Frontend: node_modules nao encontrado.
    echo   No CMD:       cd frontend ^&^& npm install
    echo   No PowerShell: cd frontend; npm install
    echo   Depois rode este script novamente.
)

echo.
echo ========================================
if %FAILED%==0 (
    echo Todos os testes concluidos com sucesso.
) else (
    echo Alguns testes falharam ou nao puderam ser executados.
)
exit /b %FAILED%
