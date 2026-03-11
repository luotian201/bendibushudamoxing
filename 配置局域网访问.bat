@echo off
chcp 65001 >nul
echo ========================================
echo   Ollama 局域网访问配置脚本
echo ========================================
echo.
echo 本脚本将配置 Ollama 以支持局域网访问
echo.
pause
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本！
    echo.
    echo 操作步骤：
    echo 1. 右键点击此文件
    echo 2. 选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo [步骤 1/4] 设置环境变量...
setx OLLAMA_HOST "0.0.0.0:11434" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 环境变量设置成功
) else (
    echo ✗ 环境变量设置失败
)
echo.

echo [步骤 2/4] 添加防火墙规则...
netsh advfirewall firewall delete rule name="Ollama Server" >nul 2>&1
netsh advfirewall firewall add rule name="Ollama Server" dir=in action=allow protocol=TCP localport=11434 >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 防火墙规则添加成功
) else (
    echo ✗ 防火墙规则添加失败
)
echo.

echo [步骤 3/4] 获取本机 IP 地址...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4" ^| findstr /V "169.254"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP:~1%
echo ✓ 本机 IP: %IP%
echo.

echo [步骤 4/4] 配置完成提示...
echo ========================================
echo   配置完成！
echo ========================================
echo.
echo 重要提示：
echo 1. 请重启 Ollama（右键托盘图标 → Quit → 重新打开）
echo 2. 其他设备访问地址: http://%IP%:11434
echo.
echo 测试方法：
echo - 在其他设备浏览器输入: http://%IP%:11434
echo - 应该看到: Ollama is running
echo.
echo 客户端调用示例：
echo   curl http://%IP%:11434/api/tags
echo   ollama run qwen3:8b --url http://%IP%:11434
echo.
pause
