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
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if ($null -eq $task) {
        Write-Host "未发现任务：$TaskName（无需卸载）" -ForegroundColor Yellow
    }
    else {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "已卸载开机自动修复任务：$TaskName" -ForegroundColor Green
    }
}
catch {
    Write-Host ""
    Write-Host "卸载失败：$($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host ""
    Read-Host "按 Enter 键退出"
}
