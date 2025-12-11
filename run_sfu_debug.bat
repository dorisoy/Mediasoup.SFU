@echo off
REM ========================================
REM Quick Setup and Run SFU (Debug)
REM ========================================

setlocal

echo.
echo ========================================
echo Mediasoup SFU - Quick Setup
echo ========================================
echo.

REM Check if Visual Studio solution exists
if not exist "vc2026\mediasoup-server.sln" (
    echo ERROR: Visual Studio solution not found.
    echo Please run: genvs2026.bat first
    echo.
    pause
    exit /b 1
)

REM Check if sfu.exe exists
if not exist "vc2026\Debug\sfu.exe" (
    echo ERROR: sfu.exe not found in vc2026\Debug\
    echo.
    echo Please build the project first:
    echo 1. Open vc2026\mediasoup-server.sln in Visual Studio
    echo 2. Select Debug configuration
    echo 3. Build Solution (Ctrl+Shift+B)
    echo.
    echo Or use command line:
    echo    msbuild vc2026\mediasoup-server.sln /p:Configuration=Debug
    echo.
    pause
    exit /b 1
)

REM Generate config if not exists
if not exist "vc2026\Debug\config.json" (
    echo Generating configuration file...
    call gen_config.bat --debug
    if errorlevel 1 (
        echo ERROR: Failed to generate config file
        pause
        exit /b 1
    )
    echo.
)

REM Check OpenSSL DLLs
set "OPENSSL_BIN=C:\Program Files\OpenSSL-Win64\bin"
set "DLL_CRYPTO=libcrypto-3-x64.dll"
set "DLL_SSL=libssl-3-x64.dll"

echo Checking OpenSSL dependencies...
where %DLL_CRYPTO% >nul 2>&1
if errorlevel 1 (
    if exist "%OPENSSL_BIN%\%DLL_CRYPTO%" (
        echo Copying OpenSSL DLLs to Debug directory...
        copy "%OPENSSL_BIN%\%DLL_CRYPTO%" "vc2026\Debug\" >nul
        copy "%OPENSSL_BIN%\%DLL_SSL%" "vc2026\Debug\" >nul
        echo Done.
    ) else (
        echo.
        echo WARNING: OpenSSL DLLs not found!
        echo Please install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html
        echo Or install via chocolatey: choco install openssl
        echo.
        pause
    )
)

REM Check certificate files
if not exist "sfu\cert\test_cert.crt" (
    echo.
    echo WARNING: SSL certificate not found: sfu\cert\test_cert.crt
    echo The server may fail to start without SSL certificates.
    echo.
    echo To generate self-signed certificate:
    echo    openssl req -x509 -newkey rsa:4096 -keyout sfu\cert\test_key.pem -out sfu\cert\test_cert.crt -days 365 -nodes
    echo.
)

echo.
echo ========================================
echo Starting SFU Server (Debug)
echo ========================================
echo.
echo Server will start on: https://127.0.0.1:4443
echo.
echo Press Ctrl+C to stop the server
echo.

cd vc2026\Debug
sfu.exe --config config.json

echo.
echo Server stopped.
pause
