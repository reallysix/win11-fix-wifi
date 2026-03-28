# Windows 11 Wi-Fi 修复工具（支持开机自动修复）

这个工具用于修复以下常见问题：

- Windows 11 重启后 Wi-Fi 开关消失
- 需要手动进入 `service.msc` 启动 `WLAN AutoConfig` 才恢复

## 文件说明

- `Fix-WiFi-Win11.bat`：双击运行入口（推荐）
- `Fix-WiFi-Win11.ps1`：实际修复脚本
- `Install-WiFi-AutoFix-Startup.bat`：一键安装“开机自动修复”
- `Install-WiFi-AutoFix-Startup.ps1`：安装计划任务脚本
- `Remove-WiFi-AutoFix-Startup.bat`：一键卸载“开机自动修复”
- `Remove-WiFi-AutoFix-Startup.ps1`：卸载计划任务脚本

## 使用方法（手动一键修复）

1. 确保本目录下脚本文件完整（`.bat` 与对应 `.ps1` 在同一目录）。
2. 双击运行 `Fix-WiFi-Win11.bat`。
3. 出现 UAC 提示时，点击“是”。
4. 等待显示“修复完成”。

## 使用方法（开机自动修复）

1. 双击运行 `Install-WiFi-AutoFix-Startup.bat`。
2. 出现 UAC 提示时，点击“是”。
3. 安装完成后，系统每次开机都会自动静默执行修复。

默认任务信息：

- 任务名：`WiFi-AutoFix-WlanSvc`
- 触发时机：系统启动（延迟约 20 秒）
- 权限：`SYSTEM` + 最高权限

如需关闭自动修复：

1. 双击运行 `Remove-WiFi-AutoFix-Startup.bat`
2. 按提示完成卸载

## 脚本做了什么

- 自动提权为管理员
- 核实 `WLAN AutoConfig`（服务名通常是 `WlanSvc`）
- 将启动类型设置为 `Automatic`
- 如果服务未运行则立即启动

## 备注

- 如果服务成功运行但 Wi-Fi 图标没有立刻出现，可先重启一次资源管理器或电脑。
- 如果仍失败，通常与网卡驱动异常或系统组件损坏有关，需要进一步诊断。
