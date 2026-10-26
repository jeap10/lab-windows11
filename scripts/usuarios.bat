@echo off
:: ============================================================
:: usuarios.bat
:: Menu simple para gestionar usuarios locales de Windows.
:: Ejecutar como ADMINISTRADOR.
:: ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Ejecuta este script como administrador.
    pause
    exit /b 1
)

:menu
cls
echo ==============================
echo   Gestion de usuarios locales
echo ==============================
echo 1. Listar usuarios
echo 2. Crear usuario
echo 3. Agregar usuario a Administradores
echo 4. Ver informacion de un usuario
echo 5. Eliminar usuario
echo 6. Salir
echo.
set /p op=Elige una opcion:

if "%op%"=="1" goto listar
if "%op%"=="2" goto crear
if "%op%"=="3" goto admin
if "%op%"=="4" goto info
if "%op%"=="5" goto eliminar
if "%op%"=="6" exit /b 0
goto menu

:listar
net user
pause
goto menu

:crear
set /p usr=Nombre del nuevo usuario:
:: El * pide la contrasena sin mostrarla en pantalla
net user %usr% * /add
pause
goto menu

:admin
set /p usr=Usuario a agregar a Administradores:
net localgroup Administradores %usr% /add
pause
goto menu

:info
set /p usr=Usuario:
net user %usr%
pause
goto menu

:eliminar
set /p usr=Usuario a eliminar:
set /p conf=Seguro que deseas eliminar %usr%? (S/N):
if /i "%conf%"=="S" net user %usr% /delete
pause
goto menu
