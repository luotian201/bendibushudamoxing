@echo off
chcp 65001 >nul
echo ========================================
echo   Git 仓库初始化脚本
echo ========================================
echo.

REM 检查是否已经是 Git 仓库
if exist .git (
    echo [警告] 当前目录已经是 Git 仓库
    echo.
    choice /C YN /M "是否继续（将重新初始化）"
    if errorlevel 2 exit /b 0
    echo.
)

echo [步骤 1/5] 初始化 Git 仓库...
git init
if %errorlevel% neq 0 (
    echo.
    echo [错误] Git 未安装或不在 PATH 中
    echo 请先安装 Git: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)
echo ✓ Git 仓库初始化成功
echo.

echo [步骤 2/5] 添加所有文件...
git add .
echo ✓ 文件添加成功
echo.

echo [步骤 3/5] 创建初始提交...
git commit -m "Initial commit: Ollama 本地大模型部署教程"
echo ✓ 初始提交完成
echo.

echo [步骤 4/5] 设置默认分支为 main...
git branch -M main
echo ✓ 分支设置完成
echo.

echo [步骤 5/5] 添加远程仓库...
echo.
echo 请输入你的 GitHub 仓库地址（例如：https://github.com/用户名/仓库名.git）
echo 如果暂时不添加，直接按回车跳过
echo.
set /p REPO_URL="GitHub 仓库地址: "

if "%REPO_URL%"=="" (
    echo.
    echo [跳过] 未添加远程仓库
    echo.
    echo 稍后可以使用以下命令添加：
    echo   git remote add origin ^<仓库地址^>
    echo   git push -u origin main
) else (
    git remote add origin "%REPO_URL%"
    echo ✓ 远程仓库添加成功
    echo.

    echo 是否现在推送到 GitHub？
    choice /C YN /M "推送到远程仓库"
    if errorlevel 2 (
        echo.
        echo [跳过] 稍后可以使用以下命令推送：
        echo   git push -u origin main
    ) else (
        echo.
        echo 正在推送...
        git push -u origin main
        if %errorlevel% equ 0 (
            echo ✓ 推送成功！
        ) else (
            echo.
            echo [错误] 推送失败
            echo 可能的原因：
            echo 1. 仓库地址错误
            echo 2. 没有配置 Git 凭据
            echo 3. 仓库已存在内容
            echo.
            echo 请手动执行：git push -u origin main
        )
    )
)

echo.
echo ========================================
echo   完成！
echo ========================================
echo.
echo Git 仓库已初始化，文件结构：
git log --oneline -1
echo.
echo 当前分支：
git branch
echo.
pause
