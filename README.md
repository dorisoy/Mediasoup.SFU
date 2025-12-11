# Mediasoup.SFU

[English](README.md) | [简体中文](README_CN.md)

Mediasoup based SFU:

1. Rewrote the JavaScript layer in C++
2. Supports single process and multi process modes
3. Use Oatpp at the application layer
4. Support the latest mediasoup and use flatbuffers for communication between the application layer and workers
5. Application layer and worker communication support pipe and direct callback
6. Support Linux deployment scripts
7. Simple and lightweight
8. High scalability and maintainability

# Build & Run

## Quick Start (Windows)

For Windows users, we provide convenient scripts to quickly set up and run the SFU server:

```powershell
# 1. Generate Visual Studio project (first time only)
genvs2026.bat

# 2. Build the project in Visual Studio (Debug or Release)

# 3. Run with automatic setup
run_sfu_debug.bat    # For Debug build
run_sfu_release.bat  # For Release build
```

The run scripts will automatically:
- Generate `config.json` if not exists
- Copy OpenSSL DLLs to the output directory
- Check for SSL certificates
- Start the SFU server

For detailed setup instructions, see the platform-specific sections below.

## Platform-Specific Build Instructions

1. macOS

   a. run builddeps.sh
   
   b. run genxcode.sh

   c. open project with xcode

2. Ubuntu

   a. run build.sh

   b. run ./build/RELEASE/sfu

   c. deploy
   
      1) cd install
      
      2) sudo ./install.sh
      
      3) sudo service sfu start|stop|restart|status
      
      4) sudo ./unstall.sh

3. Windows

   ## Prerequisites
   
   Before building on Windows, ensure you have:
   
   - **Visual Studio 2026** (or 2022/2019 with corresponding genvs batch file)
     - Workload: Desktop development with C++
     - Components: MSVC v143, Windows 10/11 SDK, CMake tools
   
   - **CMake 3.20+** (usually included with Visual Studio)
   
   - **OpenSSL for Windows**
     - Download and install from: https://slproweb.com/products/Win32OpenSSL.html
     - Install to default location: `C:\Program Files\OpenSSL-Win64`
     - Or install via chocolatey: `choco install openssl`
   
   - **Git** (for cloning dependencies)
   
   ## Build Steps
   
   ### a. Generate Visual Studio project
   
   **IMPORTANT**: If you previously generated the project from a different path or renamed the project directory, you **MUST** delete the `vc2026` folder first to avoid CMake cache path errors:
   
   ```powershell
   # Clean previous build (if exists)
   Remove-Item -Path .\vc2026 -Recurse -Force
   
   # Generate new Visual Studio solution
   genvs2026.bat
   ```
   
   Available generation scripts:
   - `genvs2026.bat` - Visual Studio 2026
   - `genvs2019.bat` - Visual Studio 2019 (if available)
   
   ### b. Build the project
   
   **Option 1: Using Visual Studio IDE**
   - Open `vc2026/mediasoup-server.sln` with Visual Studio
   - Select **Debug** or **Release** configuration from toolbar
   - Build Solution: `Build` → `Build Solution` or press `Ctrl+Shift+B`
   
   **Option 2: Using command line (MSBuild)**
   ```powershell
   # Debug build
   msbuild vc2026\mediasoup-server.sln /p:Configuration=Debug
   
   # Release build
   msbuild vc2026\mediasoup-server.sln /p:Configuration=Release
   ```
   
   Build outputs:
   - Debug: `vc2026\Debug\sfu.exe`
   - Release: `vc2026\Release\sfu.exe`
   
   ### c. Generate configuration file
   
   SFU requires a `config.json` file to run. Use the provided script to generate it:
   
   **Using the configuration generator script:**
   ```powershell
   # Generate config for Debug build
   gen_config.bat --debug
   
   # Generate config for Release build
   gen_config.bat --release
   
   # Generate with custom worker path
   gen_config.bat --debug --worker-path "C:\custom\path\mediasoup-worker.exe"
   
   # Show all options
   gen_config.bat --help
   ```
   
   **Script features:**
   - Automatically creates `config.json` in `vc2026\Debug\` or `vc2026\Release\`
   - Auto-detects mediasoup-worker.exe path
   - Configures certificate paths to `sfu\cert\` directory
   - Sets up WebRTC transport and server options
   - Configures media codecs (Opus, VP8, VP9, H.264)
   
   **Available options:**
   - `--debug`: Generate config for Debug build (default)
   - `--release`: Generate config for Release build  
   - `--worker-path PATH`: Specify custom mediasoup-worker.exe path
   - `--help`: Display help message
   
   This will create `config.json` in `vc2026\Debug\` or `vc2026\Release\`.
   
   **Manual configuration** (if needed):
   - Copy `install\conf\config.json` to build directory
   - Update paths in config.json:
     - `workerPath`: Path to `mediasoup-worker.exe`
     - `dtlsCertificateFile` & `cert`: Path to SSL certificate
     - `dtlsPrivateKeyFile` & `key`: Path to SSL private key
   
   ### d. Prepare SSL certificates
   
   Place your SSL certificate files in `sfu\cert\`:
   - `test_cert.crt` - SSL certificate
   - `test_key.pem` - SSL private key
   
   For testing, you can generate self-signed certificates:
   ```powershell
   # Using OpenSSL
   openssl req -x509 -newkey rsa:4096 -keyout sfu\cert\test_key.pem -out sfu\cert\test_cert.crt -days 365 -nodes
   ```
   
   ### e. Setup OpenSSL runtime dependencies
   
   The SFU executable requires OpenSSL DLLs at runtime.
   
   **Option 1: Add to system PATH (Recommended)**
   ```powershell
   # Add OpenSSL bin directory to PATH (run as Administrator)
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSL-Win64\bin", "Machine")
   ```
   
   **Option 2: Copy DLLs to executable directory**
   ```powershell
   # For Debug build
   copy "C:\Program Files\OpenSSL-Win64\bin\libcrypto-3-x64.dll" .\vc2026\Debug\
   copy "C:\Program Files\OpenSSL-Win64\bin\libssl-3-x64.dll" .\vc2026\Debug\
   
   # For Release build
   copy "C:\Program Files\OpenSSL-Win64\bin\libcrypto-3-x64.dll" .\vc2026\Release\
   copy "C:\Program Files\OpenSSL-Win64\bin\libssl-3-x64.dll" .\vc2026\Release\
   ```
   
   ### f. Run the SFU server
   
   **Method 1: Quick start with helper script (Recommended)**
   ```powershell
   # Debug build - Automatically handles config and dependencies
   run_sfu_debug.bat
   
   # Release build
   run_sfu_release.bat
   ```
   
   **Method 2: Direct execution with config**
   ```powershell
   # Navigate to build directory
   cd vc2026\Debug
   
   # Run with config file
   .\sfu.exe --config config.json
   
   # Or run with custom config path
   .\sfu.exe --config C:\path\to\your\config.json
   ```
   
   **Method 3: Run in Visual Studio**
   - Right-click `sfu` project → `Set as Startup Project`
   - Right-click `sfu` project → `Properties` → `Debugging`
   - Set `Command Arguments`: `--config $(OutputPath)config.json`
   - Press `F5` (Debug) or `Ctrl+F5` (Run without debugging)
   
   **Method 4: View help and options**
   ```powershell
   .\vc2026\Debug\sfu.exe --help
   ```
   
   ### g. Verify the server is running
   
   When the server starts successfully, you should see:
   ```
   [INFO] Mediasoup SFU Server starting...
   [INFO] Worker 0 started
   [INFO] Worker 1 started
   [INFO] HTTPS server listening on 127.0.0.1:4443
   ```
   
   ## Troubleshooting
   
   **CMake cache path error**
   - Error: "The source directory does not appear to contain CMakeLists.txt"
   - Solution: Delete `vc2026` folder and regenerate: `genvs2026.bat`
   
   **Missing OpenSSL DLLs**
   - Error: "libssl-3-x64.dll not found"
   - Solution: Follow step e above to setup OpenSSL dependencies
   
   **Worker not found**
   - Error: "mediasoup-worker.exe not found"
   - Solution: Verify `workerPath` in `config.json` points to correct location
   
   **Certificate files not found**
   - Error: "Failed to load certificate"
   - Solution: Ensure SSL certificate files exist in `sfu\cert\` directory

## Windows Helper Scripts Reference

The project provides several Windows batch scripts to simplify development workflow:

### 1. `gen_config.bat` - Configuration File Generator

**Purpose:** Automatically generate `config.json` with correct paths for your build configuration.

**Usage:**
```powershell
gen_config.bat [--debug|--release] [--worker-path PATH] [--help]
```

**Examples:**
```powershell
# Generate config for Debug build (default)
gen_config.bat
gen_config.bat --debug

# Generate config for Release build
gen_config.bat --release

# Use custom worker executable path
gen_config.bat --debug --worker-path "D:\custom\mediasoup-worker.exe"
```

**What it does:**
- Creates `config.json` in `vc2026\Debug\` or `vc2026\Release\`
- Sets up correct paths for worker executable
- Configures SSL certificate paths (`sfu\cert\test_cert.crt`, `sfu\cert\test_key.pem`)
- Configures WebRTC transports, media codecs, and server settings
- Warns if certificate files are missing

### 2. `run_sfu_debug.bat` - Quick Start (Debug)

**Purpose:** One-click script to set up and run the Debug build.

**Usage:**
```powershell
run_sfu_debug.bat
```

**What it does:**
1. Checks if Visual Studio solution exists
2. Verifies `sfu.exe` is built
3. Generates `config.json` if missing
4. Copies OpenSSL DLLs to Debug directory (if needed)
5. Checks for SSL certificates
6. Starts the SFU server in Debug mode

### 3. `run_sfu_release.bat` - Quick Start (Release)

**Purpose:** One-click script to set up and run the Release build.

**Usage:**
```powershell
run_sfu_release.bat
```

**What it does:** Same as `run_sfu_debug.bat` but for Release configuration.

### 4. `genvs2026.bat` / `genvs2019.bat` - Project Generation

**Purpose:** Generate Visual Studio solution and project files.

**Usage:**
```powershell
genvs2026.bat    # For Visual Studio 2026
genvs2019.bat    # For Visual Studio 2019
```

**Important:** If you encounter CMake cache errors or moved the project directory:
```powershell
# Clean and regenerate
Remove-Item -Path .\vc2026 -Recurse -Force
genvs2026.bat
```

## Configuration File Reference

The `config.json` file controls all SFU server settings:

### Key Configuration Sections:

**HTTPS Server:**
```json
"https": {
  "listenIp": "127.0.0.1",      // Server bind IP
  "listenPort": 4443,            // HTTPS port
  "tls": {
    "cert": "path/to/cert.crt",  // SSL certificate
    "key": "path/to/key.pem"     // SSL private key
  }
}
```

**Mediasoup Worker:**
```json
"mediasoup": {
  "numWorkers": 2,               // Number of worker processes
  "multiprocess": false,         // Enable multi-process mode
  "workerPath": "path/to/mediasoup-worker.exe",
  "workerSettings": {
    "logLevel": "debug",         // debug, warn, error
    "dtlsCertificateFile": "...",
    "dtlsPrivateKeyFile": "..."
  }
}
```

**WebRTC Transport:**
```json
"webRtcTransportOptions": {
  "listenInfos": [
    {
      "protocol": "udp",
      "ip": "127.0.0.1",
      "announcedAddress": "127.0.0.1",  // Public IP for clients
      "portRange": { "min": 40000, "max": 49999 }
    }
  ]
}
```

**Media Codecs:**
- Audio: Opus (48kHz, 2 channels)
- Video: VP8, VP9, H.264 (multiple profiles)

For complete configuration reference, see `install/conf/config.json`.
