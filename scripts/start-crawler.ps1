# ============================================================
# GuguPet - 爬虫系统启动脚本
# ============================================================
# 功能：检查环境、安装依赖、运行爬虫、同步数据
# 使用：右键 -> 使用 PowerShell 运行
# ============================================================

param(
    [string]$Action = "menu",
    [string]$Platform = ""
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
    Write-ColorOutput "         职宠小窝 (GuguPet) - 爬虫系统启动器" "Title"
    Write-ColorOutput "============================================================" "Title"
    Write-Host ""
}

# 检查Python环境
function Test-PythonEnv {
    Write-ColorOutput "[检查] Python 环境..." "Info"
    
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+\.\d+\.\d+)") {
            Write-ColorOutput "[成功] Python 版本: $($Matches[1])" "Success"
            return $true
        }
    }
    catch {
        Write-ColorOutput "[错误] 未找到 Python 环境" "Error"
        Write-ColorOutput "请先安装 Python 3.10+: https://www.python.org/downloads/" "Warning"
        return $false
    }
    return $false
}

# 检查pip
function Test-PipEnv {
    Write-ColorOutput "[检查] pip 环境..." "Info"
    
    try {
        $pipVersion = pip --version 2>&1
        if ($pipVersion) {
            Write-ColorOutput "[成功] pip 已安装" "Success"
            return $true
        }
    }
    catch {
        Write-ColorOutput "[错误] 未找到 pip" "Error"
        return $false
    }
    return $false
}

# 检查.env配置
function Test-EnvConfig {
    $envFile = "crawler\.env"
    $envExample = "crawler\.env.example"
    
    Write-ColorOutput "[检查] 环境配置文件..." "Info"
    
    if (Test-Path $envFile) {
        Write-ColorOutput "[成功] .env 配置文件存在" "Success"
        return $true
    }
    elseif (Test-Path $envExample) {
        Write-ColorOutput "[警告] .env 文件不存在，发现 .env.example" "Warning"
        Write-Host ""
        $copy = Read-Host "是否复制 .env.example 为 .env? (y/n)"
        
        if ($copy -eq "y") {
            Copy-Item $envExample $envFile
            Write-ColorOutput "[成功] 已创建 .env 文件，请编辑配置" "Success"
            Write-ColorOutput "提示: 需要生成加密密钥并填入 COOKIE_ENCRYPTION_KEY" "Warning"
            return $true
        }
        return $false
    }
    else {
        Write-ColorOutput "[错误] 未找到配置文件模板" "Error"
        return $false
    }
}

# 安装Python依赖
function Install-PythonDependencies {
    Write-ColorOutput "" "Info"
    Write-ColorOutput "[执行] 安装 Python 依赖..." "Info"
    
    Push-Location "crawler"
    
    try {
        pip install -r requirements.txt
        Write-ColorOutput "[成功] 依赖安装完成" "Success"
    }
    catch {
        Write-ColorOutput "[错误] 依赖安装失败: $_" "Error"
    }
    
    Pop-Location
}

# 生成加密密钥
function New-EncryptionKey {
    Write-ColorOutput "" "Info"
    Write-ColorOutput "[执行] 生成 Cookie 加密密钥..." "Info"
    
    try {
        $key = python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
        Write-ColorOutput "[成功] 生成的密钥:" "Success"
        Write-Host ""
        Write-Host $key -ForegroundColor Yellow
        Write-Host ""
        Write-ColorOutput "请将此密钥复制到 crawler/.env 文件的 COOKIE_ENCRYPTION_KEY 变量中" "Warning"
    }
    catch {
        Write-ColorOutput "[错误] 密钥生成失败: $_" "Error"
        Write-ColorOutput "请确保已安装 cryptography: pip install cryptography" "Warning"
    }
}

# 运行登录脚本
function Start-Login {
    param([string]$Platform)
    
    Write-ColorOutput "" "Info"
    
    if ([string]::IsNullOrEmpty($Platform)) {
        Write-ColorOutput "选择登录平台:" "Title"
        Write-Host "  [1] Boss直聘"
        Write-Host "  [2] 智联招聘"
        Write-Host "  [3] 前程无忧"
        Write-Host ""
        $choice = Read-Host "请选择"
        
        $Platform = switch ($choice) {
            "1" { "boss" }
            "2" { "zhilian" }
            "3" { "qiancheng" }
            default { "boss" }
        }
    }
    
    Write-ColorOutput "[执行] 登录 $Platform..." "Info"
    Write-Host ""
    
    Push-Location "crawler"
    python login.py $Platform
    Pop-Location
}

# 运行爬虫
function Start-Crawler {
    param([string]$Platform)
    
    Write-ColorOutput "" "Info"
    
    if ([string]::IsNullOrEmpty($Platform)) {
        Write-ColorOutput "选择爬虫平台:" "Title"
        Write-Host "  [1] Boss直聘"
        Write-Host "  [2] 智联招聘"
        Write-Host "  [3] 前程无忧"
        Write-Host "  [4] 所有平台"
        Write-Host ""
        $choice = Read-Host "请选择"
        
        $Platform = switch ($choice) {
            "1" { "boss" }
            "2" { "zhilian" }
            "3" { "qiancheng" }
            "4" { "all" }
            default { "all" }
        }
    }
    
    Write-ColorOutput "[执行] 启动爬虫..." "Info"
    Write-Host ""
    
    Push-Location "crawler"
    
    if ($Platform -eq "all") {
        python main.py
    }
    else {
        python main.py $Platform
    }
    
    Pop-Location
}

# 同步数据到App
function Start-Sync {
    param([string]$Platform, [switch]$Clear)
    
    Write-ColorOutput "" "Info"
    Write-ColorOutput "[执行] 同步数据到 App..." "Info"
    
    Push-Location "crawler"
    
    $command = "python sync_to_app.py"
    
    if (-not [string]::IsNullOrEmpty($Platform)) {
        $command += " $Platform"
    }
    
    if ($Clear) {
        $command += " --clear"
    }
    
    Write-ColorOutput "[执行] $command" "Info"
    Write-Host ""
    
    Invoke-Expression $command
    
    Pop-Location
    
    Write-ColorOutput "" "Info"
    Write-ColorOutput "[完成] 数据已同步到 app/assets/data/jobs.db" "Success"
}

# 显示帮助
function Show-Help {
    Write-Host ""
    Write-ColorOutput "使用方法:" "Title"
    Write-Host "  .\start-crawler.ps1                    # 显示交互菜单"
    Write-Host "  .\start-crawler.ps1 -Action login      # 运行登录脚本"
    Write-Host "  .\start-crawler.ps1 -Action crawl      # 运行爬虫"
    Write-Host "  .\start-crawler.ps1 -Action sync       # 同步数据"
    Write-Host "  .\start-crawler.ps1 -Action install    # 安装依赖"
    Write-Host "  .\start-crawler.ps1 -Action key        # 生成加密密钥"
    Write-Host ""
    Write-ColorOutput "可用参数:" "Title"
    Write-Host "  -Action: login | crawl | sync | install | key | help"
    Write-Host "  -Platform: boss | zhilian | qiancheng | all"
    Write-Host ""
}

# 交互菜单
function Show-Menu {
    Print-Header
    
    # 检查环境
    if (-not (Test-PythonEnv)) {
        Write-Host ""
        Read-Host "按回车键退出"
        return
    }
    
    if (-not (Test-PipEnv)) {
        Write-Host ""
        Read-Host "按回车键退出"
        return
    }
    
    # 检查配置
    Test-EnvConfig | Out-Null
    
    Write-Host ""
    Write-ColorOutput "请选择操作:" "Title"
    Write-Host ""
    Write-Host "  [1] 安装依赖"
    Write-Host "  [2] 生成加密密钥"
    Write-Host "  [3] 登录招聘网站"
    Write-Host "  [4] 运行爬虫"
    Write-Host "  [5] 同步数据到App"
    Write-Host "  [6] 一键运行 (登录+爬取+同步)"
    Write-Host "  [7] 帮助信息"
    Write-Host "  [0] 退出"
    Write-Host ""
    
    $choice = Read-Host "请输入选项"
    
    switch ($choice) {
        "1" { 
            Install-PythonDependencies
            Write-Host ""
            Read-Host "按回车键继续"
            Show-Menu
        }
        "2" { 
            New-EncryptionKey
            Write-Host ""
            Read-Host "按回车键继续"
            Show-Menu
        }
        "3" { 
            Start-Login
            Write-Host ""
            Read-Host "按回车键继续"
            Show-Menu
        }
        "4" { 
            Start-Crawler
            Write-Host ""
            Read-Host "按回车键继续"
            Show-Menu
        }
        "5" { 
            Start-Sync
            Write-Host ""
            Read-Host "按回车键继续"
            Show-Menu
        }
        "6" {
            Write-ColorOutput "" "Info"
            Write-ColorOutput "[一键运行] 开始执行完整流程..." "Title"
            Start-Login
            Start-Crawler
            Start-Sync
            Write-ColorOutput "" "Info"
            Write-ColorOutput "[完成] 一键运行结束" "Success"
            Write-Host ""
            Read-Host "按回车键继续"
            Show-Menu
        }
        "7" { 
            Show-Help
            Read-Host "按回车键继续"
            Show-Menu
        }
        "0" { 
            Write-Host ""
            Write-ColorOutput "再见!" "Info"
            return
        }
        default { 
            Write-ColorOutput "无效选项，请重新选择" "Warning"
            Start-Sleep -Seconds 1
            Show-Menu
        }
    }
}

# 主程序入口
switch ($Action.ToLower()) {
    "login" {
        Print-Header
        if (Test-PythonEnv) {
            Start-Login -Platform $Platform
        }
    }
    "crawl" {
        Print-Header
        if (Test-PythonEnv) {
            Start-Crawler -Platform $Platform
        }
    }
    "sync" {
        Print-Header
        if (Test-PythonEnv) {
            Start-Sync -Platform $Platform
        }
    }
    "install" {
        Print-Header
        if (Test-PythonEnv -and (Test-PipEnv)) {
            Install-PythonDependencies
        }
    }
    "key" {
        Print-Header
        if (Test-PythonEnv) {
            New-EncryptionKey
        }
    }
    "help" {
        Print-Header
        Show-Help
    }
    default {
        Show-Menu
    }
}
