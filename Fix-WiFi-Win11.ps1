#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$NoPause,
    [switch]$Silent
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    if (-not $Silent) {
        Write-Host "[WiFi Fix] $Message" -ForegroundColor Cyan
    }
}

function Ensure-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        if (-not $Silent) {
            Write-Host "需要管理员权限，正在请求提权..." -ForegroundColor Yellow
        }
        $scriptPath = $PSCommandPath
        $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        if ($NoPause) { $argList += " -NoPause" }
        if ($Silent) { $argList += " -Silent" }
        Start-Process -FilePath "powershell.exe" -ArgumentList $argList -Verb RunAs | Out-Null
        exit
    }
}

function Resolve-WlanService {
    $service = Get-Service -Name "WlanSvc" -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        return $service
    }

    $candidate = Get-Service | Where-Object { $_.DisplayName -like "*WLAN AutoConfig*" } | Select-Object -First 1
    return $candidate
}

try {
    Ensure-Admin

    Write-Step "正在检查 WLAN 服务..."
    $service = Resolve-WlanService

    if ($null -eq $service) {
        throw "未找到 WLAN AutoConfig 服务（WlanSvc）。请确认系统版本或网卡驱动是否异常。"
    }

    Write-Step "服务名: $($service.Name) / 显示名: $($service.DisplayName)"
    Write-Step "设置启动类型为 Automatic..."
    Set-Service -Name $service.Name -StartupType Automatic

    $service.Refresh()
    if ($service.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running) {
        Write-Step "正在启动服务..."
        Start-Service -Name $service.Name
    }

    $service.Refresh()
    Write-Step "当前状态: $($service.Status)"

    if ($service.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running) {
        if (-not $Silent) {
            Write-Host ""
            Write-Host "修复完成：Wi-Fi 服务已恢复并设置为开机自动启动。" -ForegroundColor Green
            Write-Host "如果右下角图标仍未立即出现，建议重启一次资源管理器或重启电脑验证。" -ForegroundColor Green
        }
    }
    else {
        throw "服务没有成功运行，当前状态：$($service.Status)"
    }
}
catch {
    if (-not $Silent) {
        Write-Host ""
        Write-Host "修复失败：$($_.Exception.Message)" -ForegroundColor Red
        Write-Host "建议：检查网卡驱动、系统服务权限，或把错误信息发给我继续排查。" -ForegroundColor Yellow
    }
    exit 1
}
finally {
    if (-not $NoPause -and -not $Silent) {
        Write-Host ""
        Read-Host "按 Enter 键退出"
    }
}
