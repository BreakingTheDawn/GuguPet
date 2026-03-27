﻿﻿﻿# ============================================================
# GuguPet - Flutter App 启动脚本
# ============================================================
# 功能：检查环境、安装依赖、启动Flutter应用
# 使用：右键 -> 使用 PowerShell 运行
# ============================================================

param(
    [string]$Action = "run",
    [string]$Device = ""
)

# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $colors = @{
        "Info"    = "White"
        "Success" = "Green"
        "Warning" = "Yellow"
        "Error"   = "Red"
        "Title"   = "Cyan"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Type]
}

# 打印标题
function Print-Header {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         职宠小窝 (GuguPet) - Flutter App 启动器" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
}

# 检查Flutter环境
function Test-FlutterEnv {
    Write-ColorOutput "[检查] Flutter 环境..." "Info"
    
    try {
        $flutterVersion = flutter --version 2>&1 | Select-String -Pattern "Flutter (\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
        if ($flutterVersion) {
            Write-ColorOutput "[成功] Flutter 版本: $flutterVersion" "Success"
            return $true
        }
    }
    catch {
        Write-ColorOutput "[错误] 未找到 Flutter 环境" "Error"
        Write-ColorOutput "请先安装 Flutter SDK: https://flutter.dev/docs/get-started/install" "Warning"
        return $false
    }
    return $false
}

# 检查Dart环境
function Test-DartEnv {
    Write-ColorOutput "[检查] Dart 环境..." "Info"
    
    try {
        $dartVersion = dart --version 2>&1 | Select-String -Pattern "Dart SDK version: (\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
        if ($dartVersion) {
            Write-ColorOutput "[成功] Dart 版本: $dartVersion" "Success"
            return $true
        }
    }
    catch {
        Write-ColorOutput "[错误] 未找到 Dart 环境" "Error"
        return $false
    }
    return $false
}

# 安装依赖
function Install-Dependencies {
    Write-ColorOutput "[执行] 安装 Flutter 依赖..." "Info"
    
    Push-Location "app"
    
    try {
        flutter pub get
        Write-ColorOutput "[成功] 依赖安装完成" "Success"
    }
    catch {
        Write-ColorOutput "[错误] 依赖安装失败: $_" "Error"
    }
    
    Pop-Location
}

# 获取可用设备
function Get-AvailableDevices {
    $devices = flutter devices 2>&1 | Select-String -Pattern "([\w-]+)\s+•\s+(.+?)\s+•" -AllMatches
    
    $deviceList = @()
    foreach ($match in $devices.Matches) {
        $deviceList += @{
            Id = $match.Groups[1].Value.Trim()
            Name = $match.Groups[2].Value.Trim()
        }
    }
    
    return $deviceList
}

# 显示设备选择菜单
function Select-Device {
    Write-ColorOutput "[检查] 可用设备列表..." "Info"
    
    $devices = Get-AvailableDevices
    
    if ($devices.Count -eq 0) {
        Write-ColorOutput "[警告] 未检测到可用设备" "Warning"
        Write-ColorOutput "请确保已连接设备或启动模拟器" "Warning"
        Write-Host ""
        Write-ColorOutput "常用设备启动命令:" "Info"
        Write-Host "  - Android模拟器: flutter emulators --launch <emulator_id>"
        Write-Host "  - Chrome浏览器:   flutter run -d chrome"
        Write-Host "  - Windows桌面:   flutter run -d windows"
        Write-Host ""
        
        $choice = Read-Host "请输入设备名称 (windows/chrome/web)"
        return $choice
    }
    
    Write-Host ""
    Write-ColorOutput "可用设备:" "Title"
    for ($i = 0; $i -lt $devices.Count; $i++) {
        Write-Host "  [$($i+1)] $($devices[$i].Name) ($($devices[$i].Id))"
    }
    Write-Host ""
    
    $choice = Read-Host "请选择设备编号 (直接回车使用默认设备)"
    
    if ([string]::IsNullOrEmpty($choice)) {
        return ""
    }
    
    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $devices.Count) {
        return $devices[$index].Id
    }
    
    return ""
}

# 运行应用
function Start-FlutterApp {
    param([string]$DeviceId)
    
    Write-ColorOutput "[启动] Flutter 应用..." "Info"
    
    Push-Location "app"
    
    $command = "flutter run"
    
    if (-not [string]::IsNullOrEmpty($DeviceId)) {
        $command += " -d $DeviceId"
    }
    
    Write-ColorOutput "[执行] $command" "Info"
    Write-Host ""
    
    Invoke-Expression $command
    
    Pop-Location
}

# 构建应用
function Build-FlutterApp {
    param([string]$Platform)
    
    Write-ColorOutput "[构建] Flutter 应用 ($Platform)..." "Info"
    
    Push-Location "app"
    
    $command = "flutter build $Platform --release"
    
    Write-ColorOutput "[执行] $command" "Info"
    Write-Host ""
    
    Invoke-Expression $command
    
    Pop-Location
    
    Write-Host ""
    Write-ColorOutput "[完成] 构建产物位置:" "Success"
    switch ($Platform) {
        "windows" { Write-Host "  app\build\windows\runner\Release\" }
        "apk"     { Write-Host "  app\build\app\outputs\flutter-apk\" }
        "web"     { Write-Host "  app\build\web\" }
        "ios"     { Write-Host "  app\build\ios\iphoneos\" }
    }
}

# 清理项目
function Clean-FlutterApp {
    Write-ColorOutput "[清理] Flutter 项目..." "Info"
    
    Push-Location "app"
    
    flutter clean
    flutter pub get
    
    Pop-Location
    
    Write-ColorOutput "[完成] 清理完成" "Success"
}

# 显示帮助
function Show-Help {
    Write-Host ""
    Write-ColorOutput "使用方法:" "Title"
    Write-Host "  .\start-app.ps1               # 交互式启动"
    Write-Host "  .\start-app.ps1 -Action run   # 直接运行"
    Write-Host "  .\start-app.ps1 -Action build # 构建应用"
    Write-Host "  .\start-app.ps1 -Action clean # 清理项目"
    Write-Host "  .\start-app.ps1 -Device windows  # 指定Windows设备"
    Write-Host ""
    Write-ColorOutput "可用参数:" "Title"
    Write-Host "  -Action: run | build | clean | help"
    Write-Host "  -Device: windows | chrome | web | <device_id>"
    Write-Host ""
}

# 主函数
function Main {
    Print-Header
    
    # 检查环境
    if (-not (Test-FlutterEnv)) {
        Write-Host ""
        Read-Host "按回车键退出"
        return
    }
    
    if (-not (Test-DartEnv)) {
        Write-Host ""
        Read-Host "按回车键退出"
        return
    }
    
    Write-Host ""
    
    # 根据Action执行不同操作
    switch ($Action.ToLower()) {
        "run" {
            Install-Dependencies
            Write-Host ""
            $deviceId = if ([string]::IsNullOrEmpty($Device)) { Select-Device } else { $Device }
            Write-Host ""
            Start-FlutterApp -DeviceId $deviceId
        }
        "build" {
            Install-Dependencies
            Write-Host ""
            Write-ColorOutput "选择构建平台:" "Title"
            Write-Host "  [1] Windows 桌面应用"
            Write-Host "  [2] Android APK"
            Write-Host "  [3] Web 应用"
            Write-Host ""
            $platformChoice = Read-Host "请选择 (1/2/3)"
            
            $platform = switch ($platformChoice) {
                "1" { "windows" }
                "2" { "apk" }
                "3" { "web" }
                default { "windows" }
            }
            
            Build-FlutterApp -Platform $platform
        }
        "clean" {
            Clean-FlutterApp
        }
        "help" {
            Show-Help
        }
        default {
            Show-Help
        }
    }
}

# 执行主函数
Main
