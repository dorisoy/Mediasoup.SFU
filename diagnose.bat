@echo off
REM ========================================
REM SFU Diagnostic Tool - 诊断工具
REM ========================================

setlocal

echo.
echo ========================================
echo SFU 诊断工具
echo ========================================
echo.

set "ERROR_COUNT=0"

REM 检查配置文件
echo [1/6] 检查配置文件...
if exist "vc2026\Debug\config.json" (
    echo     [OK] config.json 存在于 vc2026\Debug\
) else (
    echo     [ERROR] config.json 不存在！
    echo     解决方案: 运行 gen_config.bat --debug
    set /a ERROR_COUNT+=1
)

REM 检查 SSL 证书
echo.
echo [2/6] 检查 SSL 证书...
if exist "sfu\cert\test_cert.crt" (
    echo     [OK] SSL 证书存在: sfu\cert\test_cert.crt
) else (
    echo     [ERROR] SSL 证书不存在！
    echo     解决方案: openssl req -x509 -newkey rsa:4096 -keyout sfu\cert\test_key.pem -out sfu\cert\test_cert.crt -days 365 -nodes
    set /a ERROR_COUNT+=1
)

if exist "sfu\cert\test_key.pem" (
    echo     [OK] SSL 私钥存在: sfu\cert\test_key.pem
) else (
    echo     [ERROR] SSL 私钥不存在！
    set /a ERROR_COUNT+=1
)

REM 检查可执行文件
echo.
echo [3/6] 检查可执行文件...
if exist "vc2026\Debug\sfu.exe" (
    echo     [OK] sfu.exe 已编译
) else (
    echo     [ERROR] sfu.exe 不存在！
    echo     解决方案: 在 Visual Studio 中编译项目
    set /a ERROR_COUNT+=1
)

if exist "vc2026\worker\Debug\mediasoup-worker.exe" (
    echo     [OK] mediasoup-worker.exe 已编译
) else (
    echo     [WARNING] mediasoup-worker.exe 不存在
    echo     这可能导致运行时错误
    set /a ERROR_COUNT+=1
)

REM 检查 OpenSSL DLL
echo.
echo [4/6] 检查 OpenSSL DLL...
where libssl-3-x64.dll >nul 2>&1
if %errorlevel% equ 0 (
    echo     [OK] OpenSSL DLL 在系统 PATH 中
) else (
    if exist "vc2026\Debug\libssl-3-x64.dll" (
        echo     [OK] OpenSSL DLL 在可执行文件目录
    ) else (
        echo     [WARNING] OpenSSL DLL 未找到
        echo     解决方案: 运行 run_sfu_debug.bat 会自动复制
        set /a ERROR_COUNT+=1
    )
)

REM 验证配置文件内容
echo.
echo [5/6] 验证配置文件内容...
if exist "vc2026\Debug\config.json" (
    findstr /C:"useWebRtcServer" "vc2026\Debug\config.json" >nul
    if %errorlevel% equ 0 (
        echo     [OK] 配置文件格式正确
    ) else (
        echo     [WARNING] 配置文件可能格式不正确
    )
    
    findstr /C:"workerPath" "vc2026\Debug\config.json" >nul
    if %errorlevel% equ 0 (
        echo     [OK] workerPath 已配置
    ) else (
        echo     [ERROR] workerPath 未配置
        set /a ERROR_COUNT+=1
    )
)

REM 检查端口占用
echo.
echo [6/6] 检查端口占用...
netstat -ano | findstr ":4443" >nul
if %errorlevel% equ 0 (
    echo     [WARNING] 端口 4443 已被占用
    echo     请确保没有其他进程使用此端口
) else (
    echo     [OK] 端口 4443 可用
)

REM 总结
echo.
echo ========================================
echo 诊断结果
echo ========================================
if %ERROR_COUNT% equ 0 (
    echo [SUCCESS] 所有检查通过，可以运行 SFU 服务器
    echo.
    echo 运行命令:
    echo     run_sfu_debug.bat
    echo.
    echo 或手动运行:
    echo     cd vc2026\Debug
    echo     sfu.exe --config config.json
) else (
    echo [FAILED] 发现 %ERROR_COUNT% 个问题，请先解决
    echo.
    echo 快速修复:
    echo     1. 生成配置: gen_config.bat --debug
    echo     2. 运行服务: run_sfu_debug.bat
)

echo.
echo 详细配置信息:
echo     配置文件: vc2026\Debug\config.json
echo     SSL 证书: sfu\cert\test_cert.crt
echo     SSL 私钥: sfu\cert\test_key.pem
echo     Worker: vc2026\worker\Debug\mediasoup-worker.exe
echo.

pause
