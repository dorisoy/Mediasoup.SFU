# Mediasoup.SFU 

一个基于C++17开发的高性能SFU（Selective Forwarding Unit）服务器，采用mediasoup架构思想，重写了原有的JavaScript层以提升性能。服务器使用Oatpp作为应用层Web框架，通过FlatBuffers实现应用层与Worker进程间的高性能通信。底层集成libwebrtc处理音视频流，支持单进程与多进程运行模式。具备WebRTC信令处理、房间管理、媒体路由转发等核心功能，适用于实时音视频通信场景，具有高可扩展性和可维护性。

源自：[https://github.com/ouxianghui/mediasoup-server](https://github.com/ouxianghui/mediasoup-server)

[English](README.md) | [简体中文](README_CN.md)

基于 Mediasoup 的 SFU 服务器：

1. 使用 C++ 重写了 JavaScript 层
2. 支持单进程和多进程模式
3. 应用层使用 Oatpp 框架
4. 支持最新的 mediasoup，使用 flatbuffers 进行应用层与 worker 之间的通信
5. 应用层与 worker 通信支持管道和直接回调
6. 支持 Linux 部署脚本
7. 简单轻量
8. 高扩展性和可维护性

# 编译与运行

## 快速开始 (Windows)

对于 Windows 用户，我们提供了便捷的脚本来快速设置和运行 SFU 服务器：

```powershell
# 1. 生成 Visual Studio 项目（仅首次需要）
genvs2026.bat

# 2. 在 Visual Studio 中编译项目（Debug 或 Release）

# 3. 使用自动化脚本运行
run_sfu_debug.bat    # Debug 构建
run_sfu_release.bat  # Release 构建
```

运行脚本会自动执行：
- 如果不存在则生成 `config.json`
- 复制 OpenSSL DLL 到输出目录
- 检查 SSL 证书
- 启动 SFU 服务器

详细的设置说明请参见下面各平台的具体章节。

## 各平台编译说明

### 1. macOS

   a. 运行 builddeps.sh
   
   b. 运行 genxcode.sh

   c. 使用 Xcode 打开项目

### 2. Ubuntu

   a. 运行 build.sh

   b. 运行 ./build/RELEASE/sfu

   c. 部署
   
      1) cd install
      
      2) sudo ./install.sh
      
      3) sudo service sfu start|stop|restart|status
      
      4) sudo ./unstall.sh

### 3. Windows

   ## 前提条件
   
   在 Windows 上编译前，请确保已安装：
   
   - **Visual Studio 2026**（或 2022/2019 及相应的 genvs 批处理文件）
     - 工作负载：使用 C++ 的桌面开发
     - 组件：MSVC v143、Windows 10/11 SDK、CMake 工具
   
   - **CMake 3.20+**（通常随 Visual Studio 一起安装）
   
   - **OpenSSL for Windows**
     - 下载并安装：https://slproweb.com/products/Win32OpenSSL.html
     - 安装到默认位置：`C:\Program Files\OpenSSL-Win64`
     - 或通过 chocolatey 安装：`choco install openssl`
   
   - **Git**（用于克隆依赖项）
   
   ## 编译步骤
   
   ### a. 生成 Visual Studio 项目
   
   **重要提示**：如果您之前从不同路径生成过项目或重命名了项目目录，**必须**先删除 `vc2026` 文件夹以避免 CMake 缓存路径错误：
   
   ```powershell
   # 清理之前的构建（如果存在）
   Remove-Item -Path .\vc2026 -Recurse -Force
   
   # 生成新的 Visual Studio 解决方案
   genvs2026.bat
   ```
   
   可用的生成脚本：
   - `genvs2026.bat` - Visual Studio 2026
   - `genvs2019.bat` - Visual Studio 2019（如果可用）
   
   ### b. 编译项目
   
   **方式 1：使用 Visual Studio IDE**
   - 用 Visual Studio 打开 `vc2026/mediasoup-server.sln`
   - 从工具栏选择 **Debug** 或 **Release** 配置
   - 生成解决方案：`生成` → `生成解决方案` 或按 `Ctrl+Shift+B`
   
   **方式 2：使用命令行（MSBuild）**
   ```powershell
   # Debug 构建
   msbuild vc2026\mediasoup-server.sln /p:Configuration=Debug
   
   # Release 构建
   msbuild vc2026\mediasoup-server.sln /p:Configuration=Release
   ```
   
   编译输出：
   - Debug：`vc2026\Debug\sfu.exe`
   - Release：`vc2026\Release\sfu.exe`
   
   ### c. 生成配置文件
   
   SFU 需要 `config.json` 配置文件才能运行。使用提供的脚本来生成：
   
   **使用配置生成脚本：**
   ```powershell
   # 生成 Debug 构建的配置
   gen_config.bat --debug
   
   # 生成 Release 构建的配置
   gen_config.bat --release
   
   # 使用自定义 worker 路径生成
   gen_config.bat --debug --worker-path "C:\custom\path\mediasoup-worker.exe"
   
   # 显示所有选项
   gen_config.bat --help
   ```
   
   **脚本功能：**
   - 自动在 `vc2026\Debug\` 或 `vc2026\Release\` 创建 `config.json`
   - 自动检测 mediasoup-worker.exe 路径
   - 配置证书路径到 `sfu\cert\` 目录
   - 设置 WebRTC 传输和服务器选项
   - 配置媒体编解码器（Opus、VP8、VP9、H.264）
   
   **可用选项：**
   - `--debug`：生成 Debug 构建的配置（默认）
   - `--release`：生成 Release 构建的配置
   - `--worker-path PATH`：指定自定义 mediasoup-worker.exe 路径
   - `--help`：显示帮助信息
   
   这将在 `vc2026\Debug\` 或 `vc2026\Release\` 创建 `config.json`。
   
   **手动配置**（如果需要）：
   - 复制 `install\conf\config.json` 到构建目录
   - 更新 config.json 中的路径：
     - `workerPath`：`mediasoup-worker.exe` 的路径
     - `dtlsCertificateFile` 和 `cert`：SSL 证书路径
     - `dtlsPrivateKeyFile` 和 `key`：SSL 私钥路径
   
   ### d. 准备 SSL 证书
   
   将 SSL 证书文件放在 `sfu\cert\` 目录：
   - `test_cert.crt` - SSL 证书
   - `test_key.pem` - SSL 私钥
   
   用于测试时，可以生成自签名证书：
   ```powershell
   # 使用 OpenSSL
   openssl req -x509 -newkey rsa:4096 -keyout sfu\cert\test_key.pem -out sfu\cert\test_cert.crt -days 365 -nodes
   ```
   
   ### e. 设置 OpenSSL 运行时依赖
   
   SFU 可执行文件在运行时需要 OpenSSL DLL。
   
   **方式 1：添加到系统 PATH（推荐）**
   ```powershell
   # 将 OpenSSL bin 目录添加到 PATH（以管理员身份运行）
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSL-Win64\bin", "Machine")
   ```
   
   **方式 2：复制 DLL 到可执行文件目录**
   ```powershell
   # 用于 Debug 构建
   copy "C:\Program Files\OpenSSL-Win64\bin\libcrypto-3-x64.dll" .\vc2026\Debug\
   copy "C:\Program Files\OpenSSL-Win64\bin\libssl-3-x64.dll" .\vc2026\Debug\
   
   # 用于 Release 构建
   copy "C:\Program Files\OpenSSL-Win64\bin\libcrypto-3-x64.dll" .\vc2026\Release\
   copy "C:\Program Files\OpenSSL-Win64\bin\libssl-3-x64.dll" .\vc2026\Release\
   ```
   
   ### f. 运行 SFU 服务器
   
   **方法 1：使用辅助脚本快速启动（推荐）**
   ```powershell
   # Debug 构建 - 自动处理配置和依赖
   run_sfu_debug.bat
   
   # Release 构建
   run_sfu_release.bat
   ```
   
   **方法 2：使用配置直接执行**
   ```powershell
   # 导航到构建目录
   cd vc2026\Debug
   
   # 使用配置文件运行
   .\sfu.exe --config config.json
   
   # 或使用自定义配置路径运行
   .\sfu.exe --config C:\path\to\your\config.json
   ```
   
   **方法 3：在 Visual Studio 中运行**
   - 右键点击 `sfu` 项目 → `设为启动项目`
   - 右键点击 `sfu` 项目 → `属性` → `调试`
   - 设置 `命令参数`：`--config $(OutputPath)config.json`
   - 按 `F5`（调试）或 `Ctrl+F5`（不调试运行）
   
   **方法 4：查看帮助和选项**
   ```powershell
   .\vc2026\Debug\sfu.exe --help
   ```
   
   ### g. 验证服务器运行
   
   服务器成功启动时，您应该看到：
   ```
   [INFO] Mediasoup SFU Server starting...
   [INFO] Worker 0 started
   [INFO] Worker 1 started
   [INFO] HTTPS server listening on 127.0.0.1:4443
   ```
   
   ## 故障排除
   
   **CMake 缓存路径错误**
   - 错误："The source directory does not appear to contain CMakeLists.txt"
   - 解决方案：删除 `vc2026` 文件夹并重新生成：`genvs2026.bat`
   
   **缺少 OpenSSL DLL**
   - 错误："libssl-3-x64.dll not found"
   - 解决方案：按照上面的步骤 e 设置 OpenSSL 依赖
   
   **找不到 Worker**
   - 错误："mediasoup-worker.exe not found"
   - 解决方案：验证 `config.json` 中的 `workerPath` 指向正确位置
   
   **找不到证书文件**
   - 错误："Failed to load certificate"
   - 解决方案：确保 SSL 证书文件存在于 `sfu\cert\` 目录

## Windows 辅助脚本参考

项目提供了多个 Windows 批处理脚本来简化开发工作流程：

### 1. `gen_config.bat` - 配置文件生成器

**用途：** 自动生成带有正确路径的 `config.json` 配置文件。

**用法：**
```powershell
gen_config.bat [--debug|--release] [--worker-path PATH] [--help]
```

**示例：**
```powershell
# 生成 Debug 构建的配置（默认）
gen_config.bat
gen_config.bat --debug

# 生成 Release 构建的配置
gen_config.bat --release

# 使用自定义 worker 可执行文件路径
gen_config.bat --debug --worker-path "D:\custom\mediasoup-worker.exe"
```

**功能说明：**
- 在 `vc2026\Debug\` 或 `vc2026\Release\` 创建 `config.json`
- 设置 worker 可执行文件的正确路径
- 配置 SSL 证书路径（`sfu\cert\test_cert.crt`，`sfu\cert\test_key.pem`）
- 配置 WebRTC 传输、媒体编解码器和服务器设置
- 如果证书文件缺失则发出警告

### 2. `run_sfu_debug.bat` - 快速启动（Debug）

**用途：** 一键脚本，设置并运行 Debug 构建。

**用法：**
```powershell
run_sfu_debug.bat
```

**功能说明：**
1. 检查 Visual Studio 解决方案是否存在
2. 验证 `sfu.exe` 是否已编译
3. 如果缺失则生成 `config.json`
4. 复制 OpenSSL DLL 到 Debug 目录（如果需要）
5. 检查 SSL 证书
6. 以 Debug 模式启动 SFU 服务器

### 3. `run_sfu_release.bat` - 快速启动（Release）

**用途：** 一键脚本，设置并运行 Release 构建。

**用法：**
```powershell
run_sfu_release.bat
```

**功能说明：** 与 `run_sfu_debug.bat` 相同，但用于 Release 配置。

### 4. `genvs2026.bat` / `genvs2019.bat` - 项目生成

**用途：** 生成 Visual Studio 解决方案和项目文件。

**用法：**
```powershell
genvs2026.bat    # 用于 Visual Studio 2026
genvs2019.bat    # 用于 Visual Studio 2019
```

**重要提示：** 如果遇到 CMake 缓存错误或移动了项目目录：
```powershell
# 清理并重新生成
Remove-Item -Path .\vc2026 -Recurse -Force
genvs2026.bat
```

## 配置文件参考

`config.json` 文件控制所有 SFU 服务器设置：

### 主要配置部分：

**HTTPS 服务器：**
```json
"https": {
  "listenIp": "127.0.0.1",      // 服务器绑定 IP
  "listenPort": 4443,            // HTTPS 端口
  "tls": {
    "cert": "path/to/cert.crt",  // SSL 证书
    "key": "path/to/key.pem"     // SSL 私钥
  }
}
```

**Mediasoup Worker：**
```json
"mediasoup": {
  "numWorkers": 2,               // Worker 进程数量
  "multiprocess": false,         // 启用多进程模式
  "workerPath": "path/to/mediasoup-worker.exe",
  "workerSettings": {
    "logLevel": "debug",         // debug、warn、error
    "dtlsCertificateFile": "...",
    "dtlsPrivateKeyFile": "..."
  }
}
```

**WebRTC 传输：**
```json
"webRtcTransportOptions": {
  "listenInfos": [
    {
      "protocol": "udp",
      "ip": "127.0.0.1",
      "announcedAddress": "127.0.0.1",  // 客户端使用的公网 IP
      "portRange": { "min": 40000, "max": 49999 }
    }
  ]
}
```

**媒体编解码器：**
- 音频：Opus（48kHz，2 声道）
- 视频：VP8、VP9、H.264（多个配置文件）

完整的配置参考请查看 `install/conf/config.json`。
