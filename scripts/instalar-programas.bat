@echo off
:: ============================================================
:: instalar-programas.bat
:: Instala el software estandar de un equipo nuevo con winget.
:: Ejecutar como ADMINISTRADOR.
:: ============================================================

:: Verificar permisos de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ejecuta este script como administrador.
    pause
    exit /b 1
)

echo === Instalando programas estandar ===

set OPCIONES=--silent --accept-package-agreements --accept-source-agreements -e

winget install --id Google.Chrome %OPCIONES%
winget install --id 7zip.7zip %OPCIONES%
winget install --id Adobe.Acrobat.Reader.64-bit %OPCIONES%
winget install --id VideoLAN.VLC %OPCIONES%
winget install --id Notepad++.Notepad++ %OPCIONES%

echo.
echo === Programas instalados ===
winget list

echo.
echo Listo.
pause
