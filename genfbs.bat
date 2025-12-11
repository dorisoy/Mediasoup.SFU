@echo off
REM Script to generate FlatBuffers C++ headers for Windows
REM This script builds flatc compiler and generates FBS headers

setlocal enabledelayedexpansion

set CURRENT_DIR=%~dp0
set FLATBUFFERS_DIR=%CURRENT_DIR%deps\flatbuffers
set FBS_SOURCE_DIR=%CURRENT_DIR%worker\fbs
set FBS_OUTPUT_DIR=%CURRENT_DIR%generated\fbs\FBS

echo ======================================
echo Generating FlatBuffers C++ headers
echo ======================================

REM Create output directories
if not exist "%CURRENT_DIR%generated" mkdir "%CURRENT_DIR%generated"
if not exist "%CURRENT_DIR%generated\fbs" mkdir "%CURRENT_DIR%generated\fbs"
if not exist "%FBS_OUTPUT_DIR%" mkdir "%FBS_OUTPUT_DIR%"

REM Check if flatc already exists in flatbuffers build
set FLATC_EXE=

REM Check common build output locations
if exist "%FLATBUFFERS_DIR%\build\Release\flatc.exe" (
    set FLATC_EXE=%FLATBUFFERS_DIR%\build\Release\flatc.exe
    goto :found_flatc
)
if exist "%FLATBUFFERS_DIR%\build\Debug\flatc.exe" (
    set FLATC_EXE=%FLATBUFFERS_DIR%\build\Debug\flatc.exe
    goto :found_flatc
)
if exist "%FLATBUFFERS_DIR%\Release\flatc.exe" (
    set FLATC_EXE=%FLATBUFFERS_DIR%\Release\flatc.exe
    goto :found_flatc
)
if exist "%FLATBUFFERS_DIR%\Debug\flatc.exe" (
    set FLATC_EXE=%FLATBUFFERS_DIR%\Debug\flatc.exe
    goto :found_flatc
)

REM flatc not found, need to build it
echo flatc.exe not found, building FlatBuffers compiler...
echo.

REM Create build directory for flatbuffers
if not exist "%FLATBUFFERS_DIR%\build" mkdir "%FLATBUFFERS_DIR%\build"
cd "%FLATBUFFERS_DIR%\build"

REM Generate VS project and build flatc
echo Generating Visual Studio project for FlatBuffers...
cmake .. -G "Visual Studio 17 2022" -DFLATBUFFERS_BUILD_TESTS=OFF -DFLATBUFFERS_BUILD_FLATLIB=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF

if errorlevel 1 (
    echo Failed to generate CMake project. Trying VS2019...
    cmake .. -G "Visual Studio 16 2019" -DFLATBUFFERS_BUILD_TESTS=OFF -DFLATBUFFERS_BUILD_FLATLIB=OFF -DFLATBUFFERS_BUILD_FLATHASH=OFF
)

if errorlevel 1 (
    echo ERROR: Failed to generate CMake project for FlatBuffers
    cd "%CURRENT_DIR%"
    pause
    exit /b 1
)

echo Building flatc compiler...
cmake --build . --config Release --target flatc

if errorlevel 1 (
    echo ERROR: Failed to build flatc compiler
    cd "%CURRENT_DIR%"
    pause
    exit /b 1
)

REM Check for built flatc
if exist "%FLATBUFFERS_DIR%\build\Release\flatc.exe" (
    set FLATC_EXE=%FLATBUFFERS_DIR%\build\Release\flatc.exe
) else (
    echo ERROR: flatc.exe not found after build
    cd "%CURRENT_DIR%"
    pause
    exit /b 1
)

:found_flatc
echo.
echo Using flatc: %FLATC_EXE%
echo.

cd "%CURRENT_DIR%"

REM Generate C++ headers from all .fbs files (iterate each file since Windows doesn't support wildcards)
echo Generating C++ headers from .fbs files...
echo Output directory: %FBS_OUTPUT_DIR%
echo.

set ERROR_COUNT=0
set SUCCESS_COUNT=0

for %%f in ("%FBS_SOURCE_DIR%\*.fbs") do (
    echo Processing: %%~nxf
    "%FLATC_EXE%" --cpp --cpp-field-case-style lower --reflect-names --scoped-enums --filename-suffix "" -I "%FBS_SOURCE_DIR%" -o "%FBS_OUTPUT_DIR%" "%%f"
    if errorlevel 1 (
        echo   ERROR: Failed to process %%~nxf
        set /a ERROR_COUNT+=1
    ) else (
        echo   OK
        set /a SUCCESS_COUNT+=1
    )
)

echo.
if !ERROR_COUNT! GTR 0 (
    echo ======================================
    echo WARNING: !ERROR_COUNT! file(s) failed to generate
    echo ======================================
) else (
    echo ======================================
    echo FBS headers generated successfully!
    echo Total: !SUCCESS_COUNT! files processed
    echo ======================================
)
echo.
echo Generated files in: %FBS_OUTPUT_DIR%
dir "%FBS_OUTPUT_DIR%"
echo.

endlocal
pause
