# 职位爬虫定时任务配置脚本
# 以管理员权限运行此脚本

$TaskName = "GuguPet_JobCrawler"
$PythonPath = (Get-Command python -ErrorAction SilentlyContinue).Source
$ScriptPath = "e:\GuguPet\crawler\main.py"
$WorkingDir = "e:\GuguPet\crawler"

# 检查Python路径
if (-not $PythonPath) {
    Write-Error "未找到Python，请确保Python已安装并添加到PATH"
    exit 1
}

Write-Host "Python路径: $PythonPath"
Write-Host "脚本路径: $ScriptPath"

# 删除已存在的任务
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "删除已存在的定时任务..."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# 创建定时任务
Write-Host "创建定时任务..."

# 任务动作
$Action = New-ScheduledTaskAction -Execute $PythonPath -Argument $ScriptPath -WorkingDirectory $WorkingDir

# 触发器：每天凌晨2点执行
$Trigger = New-ScheduledTaskTrigger -Daily -At 2am

# 任务设置
$Settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -DontStopOnIdleEnd `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 4)

# 注册任务
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -RunLevel Highest `
    -Description "职宠小窝职位爬虫，每天凌晨2点执行"

Write-Host "定时任务创建成功！"
Write-Host "任务名称: $TaskName"
Write-Host "执行时间: 每天 02:00"
Write-Host ""
Write-Host "手动测试命令: python $ScriptPath"
Write-Host "查看任务状态: Get-ScheduledTask -TaskName $TaskName"
