﻿﻿﻿# ============================================================
# GuguPet - 主启动脚本
# ============================================================
# 功能：统一入口，选择启动不同模块
# 使用：右键 -> 使用 PowerShell 运行
# ============================================================

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
        "Highlight" = "Magenta"
    }
    
    Write-Host $Message -ForegroundColor $colors[$Type]
}

# 打印标题
function Print-Header {
    Clear-Host
    Write-Host ""
    Write-ColorOutput "============================================================" "Highlight"
    Write-ColorOutput "                                                            " "Highlight"
    Write-ColorOutput "           职宠小窝 (GuguPet) - 开发环境启动器              " "Highlight"
    Write-ColorOutput "                                                            " "Highlight"
    Write-ColorOutput "============================================================" "Highlight"
    Write-Host ""
    Write-ColorOutput "  轻拟人电子宠物求职陪伴APP" "Title"
    Write-Host ""
    Write-ColorOutput "------------------------------------------------------------" "Info"
    Write-Host ""
}

# 显示模块状态
function Show-ModuleStatus {
    Write-ColorOutput "模块状态:" "Title"
    Write-Host ""
    
    # Flutter App
    $flutterStatus = "未安装"
    try {
        $flutterVersion = flutter --version 2>&1 | Select-String -Pattern "Flutter (\d+\.\d+\.\d+)"
        if ($flutterVersion) {
            $flutterStatus = "已安装 v$($flutterVersion.Matches.Groups[1].Value)"
            Write-Host "  [Flutter App]    " -NoNewline
            Write-Host $flutterStatus -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  [Flutter App]    " -NoNewline
        Write-Host $flutterStatus -ForegroundColor Red
    }
    
    # Python
    $pythonStatus = "未安装"
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
            $pythonStatus = "已安装 v$($Matches[1])"
            Write-Host "  [爬虫系统]      " -NoNewline
            Write-Host $pythonStatus -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  [爬虫系统]      " -NoNewline
        Write-Host $pythonStatus -ForegroundColor Red
    }
    
    # Node.js
    $nodeStatus = "未安装"
    try {
        $nodeVersion = node --version 2>&1
        if ($nodeVersion) {
            $nodeStatus = "已安装 $nodeVersion"
            Write-Host "  [微信小程序]    " -NoNewline
            Write-Host $nodeStatus -ForegroundColor Green
        }
    }
    catch {
        Write-Host "  [微信小程序]    " -NoNewline
        Write-Host $nodeStatus -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# 显示主菜单
function Show-MainMenu {
    Print-Header
    Show-ModuleStatus
    
    Write-ColorOutput "请选择要启动的模块:" "Title"
    Write-Host ""
    Write-Host "  [1] Flutter App    - 启动移动应用开发环境"
    Write-Host "  [2] 爬虫系统      - 启动职位数据爬取"
    Write-Host "  [3] 微信小程序    - 启动小程序开发环境"
    Write-Host ""
    Write-ColorOutput "------------------------------------------------------------" "Info"
    Write-Host ""
    Write-Host "  [4] 安装所有依赖  - 一键安装所有模块依赖"
    Write-Host "  [5] 环境检查      - 检查开发环境配置"
    Write-Host "  [6] 帮助信息      - 查看使用说明"
    Write-Host ""
    Write-Host "  [0] 退出"
    Write-Host ""
    
    $choice = Read-Host "请输入选项"
    
    switch ($choice) {
        "1" { Start-FlutterApp }
        "2" { Start-Crawler }
        "3" { Start-MiniProgram }
        "4" { Install-AllDependencies }
        "5" { Check-Environment }
        "6" { Show-Help }
        "0" { 
            Write-Host ""
            Write-ColorOutput "再见! 祝开发顺利!" "Success"
            return
        }
        default { 
            Write-ColorOutput "无效选项，请重新选择" "Warning"
            Start-Sleep -Seconds 1
            Show-MainMenu
        }
    }
}

# 启动Flutter App
function Start-FlutterApp {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         启动 Flutter App 开发环境" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    
    $scriptPath = Join-Path $PSScriptRoot "start-app.ps1"
    
    if (Test-Path $scriptPath) {
        & $scriptPath
    }
    else {
        Write-ColorOutput "[错误] 未找到启动脚本: $scriptPath" "Error"
        Read-Host "按回车键返回"
        Show-MainMenu
    }
}

# 启动爬虫系统
function Start-Crawler {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         启动爬虫系统" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    
    $scriptPath = Join-Path $PSScriptRoot "start-crawler.ps1"
    
    if (Test-Path $scriptPath) {
        & $scriptPath
    }
    else {
        Write-ColorOutput "[错误] 未找到启动脚本: $scriptPath" "Error"
        Read-Host "按回车键返回"
        Show-MainMenu
    }
}

# 启动微信小程序
function Start-MiniProgram {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         启动微信小程序开发环境" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    
    # 检查Node.js
    try {
        $nodeVersion = node --version 2>&1
        Write-ColorOutput "[检查] Node.js: $nodeVersion" "Success"
    }
    catch {
        Write-ColorOutput "[错误] 未安装 Node.js" "Error"
        Write-ColorOutput "请先安装 Node.js: https://nodejs.org/" "Warning"
        Read-Host "按回车键返回"
        Show-MainMenu
        return
    }
    
    Write-Host ""
    Write-ColorOutput "请选择操作:" "Title"
    Write-Host "  [1] 安装依赖 (npm install)"
    Write-Host "  [2] 开发模式 (npm run dev:weapp)"
    Write-Host "  [3] 构建生产版本 (npm run build:weapp)"
    Write-Host "  [0] 返回"
    Write-Host ""
    
    $choice = Read-Host "请选择"
    
    Push-Location "miniprogram"
    
    switch ($choice) {
        "1" {
            Write-ColorOutput "[执行] 安装依赖..." "Info"
            npm install
            Write-ColorOutput "[完成] 依赖安装完成" "Success"
        }
        "2" {
            Write-ColorOutput "[执行] 启动开发模式..." "Info"
            npm run dev:weapp
        }
        "3" {
            Write-ColorOutput "[执行] 构建生产版本..." "Info"
            npm run build:weapp
            Write-ColorOutput "[完成] 构建完成，输出目录: miniprogram/dist/" "Success"
        }
        "0" {
            Pop-Location
            Show-MainMenu
            return
        }
    }
    
    Pop-Location
    Write-Host ""
    Read-Host "按回车键返回"
    Show-MainMenu
}

# 安装所有依赖
function Install-AllDependencies {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         安装所有模块依赖" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    
    Write-ColorOutput "[1/3] Flutter App 依赖..." "Info"
    Push-Location "app"
    try {
        flutter pub get
        Write-ColorOutput "[成功] Flutter 依赖安装完成" "Success"
    }
    catch {
        Write-ColorOutput "[错误] Flutter 依赖安装失败" "Error"
    }
    Pop-Location
    
    Write-Host ""
    Write-ColorOutput "[2/3] 爬虫系统依赖..." "Info"
    Push-Location "crawler"
    try {
        pip install -r requirements.txt
        Write-ColorOutput "[成功] Python 依赖安装完成" "Success"
    }
    catch {
        Write-ColorOutput "[错误] Python 依赖安装失败" "Error"
    }
    Pop-Location
    
    Write-Host ""
    Write-ColorOutput "[3/3] 微信小程序依赖..." "Info"
    Push-Location "miniprogram"
    try {
        npm install
        Write-ColorOutput "[成功] 小程序依赖安装完成" "Success"
    }
    catch {
        Write-ColorOutput "[错误] 小程序依赖安装失败" "Error"
    }
    Pop-Location
    
    Write-Host ""
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "所有依赖安装完成!" "Success"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    Read-Host "按回车键返回"
    Show-MainMenu
}

# 环境检查
function Check-Environment {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         开发环境检查" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    
    $allOk = $true
    
    # Flutter
    Write-ColorOutput "[检查] Flutter SDK..." "Info"
    try {
        $flutterVersion = flutter --version 2>&1 | Select-String -Pattern "Flutter (\d+\.\d+\.\d+)"
        if ($flutterVersion) {
            Write-ColorOutput "  状态: 已安装 v$($flutterVersion.Matches.Groups[1].Value)" "Success"
        }
    }
    catch {
        Write-ColorOutput "  状态: 未安装" "Error"
        Write-ColorOutput "  下载: https://flutter.dev/docs/get-started/install" "Warning"
        $allOk = $false
    }
    
    Write-Host ""
    
    # Python
    Write-ColorOutput "[检查] Python..." "Info"
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
            Write-ColorOutput "  状态: 已安装 v$($Matches[1])" "Success"
        }
    }
    catch {
        Write-ColorOutput "  状态: 未安装" "Error"
        Write-ColorOutput "  下载: https://www.python.org/downloads/" "Warning"
        $allOk = $false
    }
    
    Write-Host ""
    
    # Node.js
    Write-ColorOutput "[检查] Node.js..." "Info"
    try {
        $nodeVersion = node --version 2>&1
        if ($nodeVersion) {
            Write-ColorOutput "  状态: 已安装 $nodeVersion" "Success"
        }
    }
    catch {
        Write-ColorOutput "  状态: 未安装 (小程序开发需要)" "Warning"
        Write-ColorOutput "  下载: https://nodejs.org/" "Warning"
    }
    
    Write-Host ""
    
    # Git
    Write-ColorOutput "[检查] Git..." "Info"
    try {
        $gitVersion = git --version 2>&1
        if ($gitVersion) {
            Write-ColorOutput "  状态: 已安装" "Success"
        }
    }
    catch {
        Write-ColorOutput "  状态: 未安装" "Warning"
        Write-ColorOutput "  下载: https://git-scm.com/" "Warning"
    }
    
    Write-Host ""
    Write-ColorOutput "------------------------------------------------------------" "Info"
    
    if ($allOk) {
        Write-ColorOutput "环境检查通过!" "Success"
    }
    else {
        Write-ColorOutput "部分环境缺失，请安装后再运行" "Warning"
    }
    
    Write-Host ""
    Read-Host "按回车键返回"
    Show-MainMenu
}

# 显示帮助
function Show-Help {
    Clear-Host
    Write-ColorOutput "============================================================" "Title"
    Write-ColorOutput "         使用帮助" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
    
    Write-ColorOutput "项目结构:" "Title"
    Write-Host "  GuguPet/"
    Write-Host "  ├── app/           Flutter 移动应用"
    Write-Host "  ├── crawler/       Python 职位爬虫"
    Write-Host "  ├── miniprogram/   微信小程序"
    Write-Host "  └── scripts/       启动脚本"
    Write-Host ""
    
    Write-ColorOutput "启动脚本:" "Title"
    Write-Host "  start.ps1          主启动器 (本脚本)"
    Write-Host "  start-app.ps1      Flutter App 启动器"
    Write-Host "  start-crawler.ps1  爬虫系统启动器"
    Write-Host ""
    
    Write-ColorOutput "使用方法:" "Title"
    Write-Host "  1. 右键点击脚本 -> 使用 PowerShell 运行"
    Write-Host "  2. 或在 PowerShell 中执行: .\start.ps1"
    Write-Host ""
    
    Write-ColorOutput "环境要求:" "Title"
    Write-Host "  - Flutter SDK 3.10.4+"
    Write-Host "  - Python 3.10+"
    Write-Host "  - Node.js 18+ (小程序开发)"
    Write-Host "  - Git"
    Write-Host ""
    
    Write-ColorOutput "文档:" "Title"
    Write-Host "  README.md          项目说明文档"
    Write-Host ""
    
    Read-Host "按回车键返回"
    Show-MainMenu
}

# 程序入口
Show-MainMenu
