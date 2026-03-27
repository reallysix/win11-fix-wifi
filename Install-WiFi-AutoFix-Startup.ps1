#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$TaskName = "WiFi-AutoFix-WlanSvc"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Host "需要管理员权限，正在请求提权..." -ForegroundColor Yellow
        $scriptPath = $PSCommandPath
        $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -TaskName `"$TaskName`""
        Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Verb RunAs | Out-Null
        exit
    }
}

try {
    Ensure-Admin

    $scriptRoot = Split-Path -Parent $PSCommandPath
    $fixScript = Join-Path $scriptRoot "Fix-WiFi-Win11.ps1"
    if (-not (Test-Path $fixScript)) {
        throw "未找到修复脚本：$fixScript"
    }

    Write-Host "[WiFi Fix] 正在创建开机自动修复任务..." -ForegroundColor Cyan

    $actionArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$fixScript`" -NoPause -Silent"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $actionArgs
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $trigger.Delay = "PT20S"
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit (New-TimeSpan -Minutes 5) `
        -MultipleInstances IgnoreNew

    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description "Auto-fix WLAN AutoConfig (WlanSvc) at system startup for Windows 11 Wi-Fi toggle issues." `
        -Force | Out-Null

    $task = Get-ScheduledTask -TaskName $TaskName
    Write-Host ""
    Write-Host "已启用开机自动修复。" -ForegroundColor Green
    Write-Host "任务名: $($task.TaskName)" -ForegroundColor Green
    Write-Host "运行账户: SYSTEM（最高权限）" -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "安装失败：$($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host ""
    Read-Host "按 Enter 键退出"
}
