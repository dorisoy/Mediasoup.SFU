@echo off
REM ========================================
REM Generate config.json for SFU
REM ========================================

setlocal enabledelayedexpansion

REM Get script directory (project root)
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Parse command line arguments
set "BUILD_TYPE=Debug"
set "WORKER_PATH="

:parse_args
if "%~1"=="" goto check_args
if /i "%~1"=="--release" (
    set "BUILD_TYPE=Release"
    shift
    goto parse_args
)
if /i "%~1"=="--debug" (
    set "BUILD_TYPE=Debug"
    shift
    goto parse_args
)
if /i "%~1"=="--worker-path" (
    set "WORKER_PATH=%~2"
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--help" (
    goto show_help
)
echo Unknown option: %~1
goto show_help

:check_args
REM Set output directory
set "OUTPUT_DIR=%SCRIPT_DIR%vc2026\%BUILD_TYPE%"

REM Create output directory if not exists
if not exist "%OUTPUT_DIR%" (
    echo Creating directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

REM Auto-detect worker path if not provided
if "%WORKER_PATH%"=="" (
    set "WORKER_PATH=%SCRIPT_DIR%vc2026\worker\%BUILD_TYPE%\mediasoup-worker.exe"
)

REM Convert paths to forward slashes for JSON
set "WORKER_PATH_JSON=!WORKER_PATH:\=/!"
set "OUTPUT_DIR_JSON=!OUTPUT_DIR:\=/!"

REM Check if cert directory exists in sfu directory
set "CERT_DIR=%SCRIPT_DIR%sfu\cert"
if not exist "%CERT_DIR%" (
    echo WARNING: Certificate directory not found: %CERT_DIR%
    echo Creating example certificate directory...
    mkdir "%CERT_DIR%"
    echo NOTE: You need to place your SSL certificate files here:
    echo   - test_cert.crt
    echo   - test_key.pem
    echo.
)

set "CERT_FILE=!CERT_DIR!\test_cert.crt"
set "KEY_FILE=!CERT_DIR!\test_key.pem"
set "CERT_FILE_JSON=!CERT_FILE:\=/!"
set "KEY_FILE_JSON=!KEY_FILE:\=/!"

REM Generate config.json
set "CONFIG_FILE=%OUTPUT_DIR%\config.json"

echo Generating configuration file...
echo Output: %CONFIG_FILE%
echo Build Type: %BUILD_TYPE%
echo Worker Path: %WORKER_PATH%
echo.

(
echo {
echo 	"domain": "127.0.0.1",
echo 	"https": {
echo 		"listenIp": "127.0.0.1",
echo 		"listenPort": 4443,
echo 		"tls": {
echo 			"cert": "!CERT_FILE_JSON!",
echo 			"key": "!KEY_FILE_JSON!"
echo 		}
echo 	},
echo 	"mediasoup": {
echo 		"numWorkers": 2,
echo 		"useWebRtcServer": false,
echo 		"multiprocess": false,
echo 		"workerPath": "!WORKER_PATH_JSON!",
echo 		"workerSettings": {
echo 			"dtlsCertificateFile": "!CERT_FILE_JSON!",
echo 			"dtlsPrivateKeyFile": "!KEY_FILE_JSON!",
echo 			"logLevel": "debug",
echo 			"logTags": [
echo 				"info",
echo 				"ice",
echo 				"dtls",
echo 				"rtp",
echo 				"srtp",
echo 				"rtcp",
echo 				"rtx",
echo 				"bwe",
echo 				"score",
echo 				"simulcast",
echo 				"svc",
echo 				"sctp"
echo 			]
echo 		},
echo 		"routerOptions": {
echo 			"mediaCodecs": [
echo 				{
echo 					"kind": "audio",
echo 					"mimeType": "audio/opus",
echo 					"clockRate": 48000,
echo 					"channels": 2
echo 				},
echo 				{
echo 					"kind": "video",
echo 					"mimeType": "video/VP8",
echo 					"clockRate": 90000,
echo 					"parameters": {
echo 						"x-google-start-bitrate": 1000
echo 					}
echo 				},
echo 				{
echo 					"kind": "video",
echo 					"mimeType": "video/VP9",
echo 					"clockRate": 90000,
echo 					"parameters": {
echo 						"profile-id": 2,
echo 						"x-google-start-bitrate": 1000
echo 					}
echo 				},
echo 				{
echo 					"kind": "video",
echo 					"mimeType": "video/h264",
echo 					"clockRate": 90000,
echo 					"parameters": {
echo 						"packetization-mode": 1,
echo 						"profile-level-id": "4d0032",
echo 						"level-asymmetry-allowed": 1,
echo 						"x-google-start-bitrate": 1000
echo 					}
echo 				},
echo 				{
echo 					"kind": "video",
echo 					"mimeType": "video/h264",
echo 					"clockRate": 90000,
echo 					"parameters": {
echo 						"packetization-mode": 1,
echo 						"profile-level-id": "42e01f",
echo 						"level-asymmetry-allowed": 1,
echo 						"x-google-start-bitrate": 1000
echo 					}
echo 				}
echo 			]
echo 		},
echo 		"webRtcServerOptions": {
echo 			"listenInfos": [
echo 				{
echo 					"protocol": "udp",
echo 					"ip": "127.0.0.1",
echo 					"announcedAddress": "127.0.0.1",
echo 					"port": 44447
echo 				},
echo 				{
echo 					"protocol": "tcp",
echo 					"ip": "127.0.0.1",
echo 					"announcedAddress": "127.0.0.1",
echo 					"port": 44447
echo 				}
echo 			]
echo 		},
echo 		"webRtcTransportOptions": {
echo 			"listenInfos": [
echo 				{
echo 					"protocol": "udp",
echo 					"ip": "127.0.0.1",
echo 					"announcedAddress": "127.0.0.1",
echo 					"portRange": {
echo 						"min": 40000,
echo 						"max": 49999
echo 					}
echo 				},
echo 				{
echo 					"protocol": "tcp",
echo 					"ip": "127.0.0.1",
echo 					"announcedAddress": "127.0.0.1",
echo 					"portRange": {
echo 						"min": 40000,
echo 						"max": 49999
echo 					}
echo 				}
echo 			],
echo 			"initialAvailableOutgoingBitrate": 1300000,
echo 			"minimumAvailableOutgoingBitrate": 600000,
echo 			"maxSctpMessageSize": 262144,
echo 			"maxIncomingBitrate": 2500000
echo 		},
echo 		"plainTransportOptions": {
echo 			"listenInfo": {
echo 				"protocol": "udp",
echo 				"ip": "0.0.0.0",
echo 				"announcedAddress": "127.0.0.1",
echo 				"portRange": {
echo 					"min": 40000,
echo 					"max": 49999
echo 				}
echo 			},
echo 			"maxSctpMessageSize": 262144
echo 		}
echo 	}
echo }
) > "%CONFIG_FILE%"

echo.
echo ========================================
echo Configuration file generated successfully!
echo ========================================
echo File: %CONFIG_FILE%
echo.
echo IMPORTANT: Before running SFU, ensure you have:
echo 1. SSL certificate files in: %CERT_DIR%
echo    - test_cert.crt
echo    - test_key.pem
echo.
echo 2. OpenSSL DLLs accessible (add to PATH or copy to exe directory):
echo    C:\Program Files\OpenSSL-Win64\bin\libcrypto-3-x64.dll
echo    C:\Program Files\OpenSSL-Win64\bin\libssl-3-x64.dll
echo.
echo 3. Run SFU with configuration:
echo    cd "%OUTPUT_DIR%"
echo    sfu.exe --config config.json
echo.
goto :eof

:show_help
echo.
echo Usage: gen_config.bat [OPTIONS]
echo.
echo Generate config.json for Mediasoup SFU server
echo.
echo OPTIONS:
echo   --debug              Generate config for Debug build (default)
echo   --release            Generate config for Release build
echo   --worker-path PATH   Specify custom mediasoup-worker.exe path
echo   --help               Show this help message
echo.
echo EXAMPLES:
echo   gen_config.bat
echo   gen_config.bat --release
echo   gen_config.bat --debug --worker-path "C:\path\to\mediasoup-worker.exe"
echo.
exit /b 0
