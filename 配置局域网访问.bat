@echo off
chcp 65001 >nul
echo ========================================
echo   Ollama 局域网访问一键配置
echo ========================================
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

echo [1/6] 设置环境变量...
setx OLLAMA_HOST "0.0.0.0:11434" >nul 2>&1
setx OLLAMA_ORIGINS "*" >nul 2>&1
echo ✓ OLLAMA_HOST = 0.0.0.0:11434
echo ✓ OLLAMA_ORIGINS = * (允许 Cursor/VSCode 等客户端访问)
echo.

echo [2/6] 添加防火墙规则...
netsh advfirewall firewall delete rule name="Ollama Server" >nul 2>&1
netsh advfirewall firewall add rule name="Ollama Server" dir=in action=allow protocol=TCP localport=11434 >nul 2>&1
echo ✓ 防火墙规则添加成功
echo.

echo [3/6] 获取本机 IP 地址...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4" ^| findstr /V "169.254"') do (
    set IP=%%a
    goto :found_ip
)
:found_ip
set IP=%IP:~1%
echo ✓ 本机 IP: %IP%
echo.

echo [4/6] 重启 Ollama 服务...
taskkill /F /IM ollama.exe >nul 2>&1
timeout /t 2 /nobreak >nul
start "" "C:\Users\%USERNAME%\AppData\Local\Programs\Ollama\ollama app.exe"
echo ✓ Ollama 已重启
echo.

echo [5/6] 等待服务启动...
timeout /t 3 /nobreak >nul
echo ✓ 服务已启动
echo.

echo [6/6] 验证配置...
for /f "tokens=*" %%a in ('powershell -Command "[System.Environment]::GetEnvironmentVariable('OLLAMA_ORIGINS', 'User')"') do set CORS_CHECK=%%a
if "%CORS_CHECK%"=="*" (
    echo ✓ CORS 配置正确 - Cursor/VSCode 可以连接
) else (
    echo ⚠ CORS 未配置 - 可能需要手动重启电脑
)
echo.

echo ========================================
echo   ✅ 配置完成！局域网访问已启用
echo ========================================
echo.

REM 获取已安装的模型
echo 📦 已安装的模型：
echo ----------------------------------------
ollama list 2>nul
if %errorlevel% neq 0 (
    echo （暂无已安装模型，请先下载模型）
    echo.
    echo 推荐命令：
    echo   ollama pull qwen3:8b
)
echo.

echo 🌐 局域网访问地址：
echo ----------------------------------------
echo   http://%IP%:11434
echo.

echo 📱 其他设备使用方法：
echo ----------------------------------------
echo 1. 浏览器测试：
echo    打开浏览器访问: http://%IP%:11434
echo    应显示: Ollama is running
echo.
echo 2. 查看可用模型：
echo    http://%IP%:11434/api/tags
echo.
echo 3. 命令行调用（在其他电脑）：
ollama list 2>nul | findstr /V "NAME" | findstr /V "^$" >temp_models.txt
for /f "tokens=1" %%m in (temp_models.txt) do (
    echo    curl http://%IP%:11434/api/generate -d "{\"model\":\"%%m\",\"prompt\":\"你好\"}"
    goto :show_first_model
)
:show_first_model
del temp_models.txt >nul 2>&1
echo.

echo 4. Python 调用示例：
echo    import requests
echo    response = requests.post(
echo        "http://%IP%:11434/api/generate",
echo        json={"model": "qwen3:8b", "prompt": "你好", "stream": False}
echo    )
echo    print(response.json()["response"])
echo.

echo 5. Cursor/VSCode 配置：
echo    Settings → Models → Override OpenAI Base URL
echo    Base URL: http://%IP%:11434/v1 （注意要有 /v1）
echo    API Key: 随便填（如 sk-111111）
ollama list 2>nul | findstr /V "NAME" | findstr /V "^$" >temp_models2.txt
for /f "tokens=1" %%m in (temp_models2.txt) do (
    echo    模型选择: %%m （在聊天界面顶部选择）
    goto :show_cursor_model
)
:show_cursor_model
del temp_models2.txt >nul 2>&1
echo.
echo 6. 其他客户端（ChatBox/OpenCat等）：
echo    API地址: http://%IP%:11434/v1
echo.

echo 💡 提示：
echo ----------------------------------------
echo - 确保所有设备连接同一 WiFi
echo - 如无法访问，检查防火墙设置
echo - 模型在服务器端运行，其他设备只需网络连接
echo.

echo ========================================
echo 配置完成！按任意键退出...
echo ========================================
pause >nul
