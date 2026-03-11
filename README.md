# Ollama 本地大模型部署教程

**一站式部署指南：从零开始在 Windows 上部署本地大模型，支持局域网共享访问**

![Ollama](https://img.shields.io/badge/Ollama-Latest-blue)
![Windows](https://img.shields.io/badge/Windows-10%2F11-green)
![NVIDIA](https://img.shields.io/badge/NVIDIA-GPU-76B900?logo=nvidia)

## 📋 目录

- [系统要求](#系统要求)
- [快速开始](#快速开始)
- [服务器端配置](#服务器端配置)
- [客户端使用](#客户端使用)
- [常见问题](#常见问题)
- [进阶配置](#进阶配置)

---

## 🖥️ 系统要求

### 服务器端（运行模型的电脑）
- **操作系统**: Windows 10/11
- **GPU**: NVIDIA 显卡（推荐 6GB+ 显存）
- **内存**: 16GB+ RAM
- **硬盘**: 20GB+ 可用空间
- **网络**: 局域网连接

### 客户端（访问模型的设备）
- 任何能访问局域网的设备（电脑、手机、平板）
- 浏览器或支持 OpenAI API 的应用

---

## 🚀 快速开始

### 第一步：安装 Ollama

1. **下载 Ollama**
   - 访问 [Ollama 官网](https://ollama.com)
   - 下载 Windows 版本
   - 双击安装程序完成安装

2. **验证安装**
   ```bash
   ollama --version
   ```

### 第二步：下载模型

在 Ollama GUI 界面中：
- 选择想要的模型（如 `qwen3:8b`）
- 发送一条消息
- 自动开始下载

或使用命令行：
```bash
# 推荐模型（中文优秀）
ollama pull qwen3:8b

# 轻量级模型（速度快）
ollama pull gemma3:4b

# 代码专用模型
ollama pull deepseek-coder-v2:16b
```

### 第三步：测试模型

```bash
ollama run qwen3:8b "你好，介绍一下你自己"
```

---

## 🌐 服务器端配置（局域网共享）

### 自动配置（推荐）

**运行配置脚本**：
1. 以**管理员身份**运行 `配置局域网访问.bat`
2. 重启 Ollama（右键托盘图标 → Quit → 重新打开）

### 手动配置

#### 1. 设置环境变量
```powershell
# 以管理员身份运行 PowerShell
[System.Environment]::SetEnvironmentVariable('OLLAMA_HOST', '0.0.0.0:11434', 'User')
```

#### 2. 添加防火墙规则
```batch
# 以管理员身份运行
netsh advfirewall firewall add rule name="Ollama Server" dir=in action=allow protocol=TCP localport=11434
```

#### 3. 获取本机 IP
```bash
ipconfig
```
记下 `IPv4 地址`（例如：`10.0.0.184`）

#### 4. 重启 Ollama
- 右键系统托盘的 Ollama 图标
- 选择 **Quit Ollama**
- 重新打开 Ollama

### 验证配置

**在服务器电脑上测试**：
```bash
curl http://你的IP:11434
# 应该返回: Ollama is running
```

**在其他设备上测试**（浏览器访问）：
```
http://你的IP:11434
```

---

## 💻 客户端使用

### 方式 1：浏览器访问

**测试连接**：
```
http://服务器IP:11434
```

**查看模型列表**：
```
http://服务器IP:11434/api/tags
```

### 方式 2：命令行调用

```bash
# 设置环境变量指向服务器
export OLLAMA_HOST=http://服务器IP:11434

# 或 Windows PowerShell
$env:OLLAMA_HOST="http://服务器IP:11434"

# 使用模型
ollama run qwen3:8b "你好"
```

### 方式 3：Python 调用

```python
import requests

# API 地址
OLLAMA_URL = "http://服务器IP:11434"

# 发送请求
response = requests.post(
    f"{OLLAMA_URL}/api/generate",
    json={
        "model": "qwen3:8b",
        "prompt": "用 Python 写一个快速排序",
        "stream": False
    }
)

print(response.json()["response"])
```

### 方式 4：集成到开发工具

#### **VSCode + Continue**
1. 安装 Continue 插件
2. 配置 API：
   ```json
   {
     "models": [{
       "title": "本地 Qwen3",
       "provider": "ollama",
       "model": "qwen3:8b",
       "apiBase": "http://服务器IP:11434"
     }]
   }
   ```

#### **Cursor**
- 设置 → Models → Custom OpenAI API
- Base URL: `http://服务器IP:11434/v1`
- Model: `qwen3:8b`

---

## ❓ 常见问题

### 1. 手机/其他设备无法访问？

**检查清单**：
- ✅ 确认设备和服务器在同一 WiFi
- ✅ 使用正确的 IP 地址（不是 `localhost`）
- ✅ 防火墙规则已添加
- ✅ Ollama 已重启

**快速测试**：
```bash
# 在服务器上运行
netstat -ano | findstr "11434"
# 应该看到 0.0.0.0:11434 LISTENING
```

### 2. 模型下载很慢或卡在 99%？

**解决方案**：
- 等待 1-2 分钟（可能在验证文件）
- 检查网络连接
- 重启 Ollama 后重试
- 先下载小模型（如 `gemma3:4b`）测试

### 3. 显存不够怎么办？

**RTX 2060 6GB 推荐模型**：
| 模型 | 参数量 | 显存占用 | 推荐程度 |
|------|--------|----------|----------|
| qwen3:8b | 8B | ~5GB | ⭐⭐⭐⭐⭐ |
| gemma3:4b | 4B | ~2.5GB | ⭐⭐⭐⭐ |
| qwen3:3b | 3B | ~2GB | ⭐⭐⭐ |

### 4. 如何删除模型？

```bash
# 查看已安装模型
ollama list

# 删除模型
ollama rm qwen3:8b
```

### 5. 如何查看模型是否在运行？

```bash
ollama ps
```

---

## 🔧 进阶配置

### 模型管理

```bash
# 列出所有模型
ollama list

# 查看运行中的模型
ollama ps

# 停止模型
ollama stop qwen3:8b

# 删除模型
ollama rm gemma3:4b
```

### 性能优化

**设置并发请求数**（修改环境变量）：
```bash
OLLAMA_NUM_PARALLEL=4
OLLAMA_MAX_LOADED_MODELS=2
```

**上下文长度限制**：
```bash
# 请求时指定
ollama run qwen3:8b --ctx-size 8192
```

### API 密钥保护（可选）

```bash
# 设置 API 密钥
$env:OLLAMA_API_KEY="your-secret-key"

# 客户端调用时需要带上密钥
curl -H "Authorization: Bearer your-secret-key" http://服务器IP:11434
```

---

## 📊 推荐模型对比

| 模型 | 参数量 | 中文能力 | 代码能力 | 推理能力 | 显存需求 |
|------|--------|----------|----------|----------|----------|
| qwen3:8b | 8B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ~5GB |
| deepseek-r1:7b | 7B | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ~4.5GB |
| glm4:9b | 9B | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ~5.5GB |
| gemma3:4b | 4B | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ~2.5GB |

---

## 🎯 使用场景

### 场景 1：个人 AI 助手
- **设备**: 手机/平板
- **用途**: 日常问答、写作辅助
- **推荐模型**: `qwen3:8b`

### 场景 2：编程助手
- **设备**: 开发电脑
- **用途**: 代码生成、调试
- **推荐模型**: `deepseek-coder-v2:16b`

### 场景 3：多设备共享
- **服务器**: 一台高性能台式机
- **客户端**: 办公电脑、笔记本、手机
- **优势**: 集中管理，节省资源

---

## 📝 许可证

本教程基于实践经验整理，遵循 MIT 许可证。

---

## 🙏 致谢

- [Ollama](https://ollama.com) - 提供优秀的本地大模型运行平台
- [Qwen](https://github.com/QwenLM/Qwen) - 阿里通义千问团队
- [DeepSeek](https://github.com/deepseek-ai) - DeepSeek 团队

---

## 📞 支持

如有问题，欢迎提 Issue 或 PR！

**常用命令速查**：
```bash
ollama --version          # 查看版本
ollama list              # 列出模型
ollama pull <模型>       # 下载模型
ollama run <模型>        # 运行模型
ollama ps                # 查看运行中的模型
ollama stop <模型>       # 停止模型
ollama rm <模型>         # 删除模型
```

---

**最后更新**: 2026-03-11
