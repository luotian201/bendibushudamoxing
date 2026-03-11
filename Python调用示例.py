"""
Ollama Python 调用示例
"""

import requests
import json

# ===== 配置 =====
OLLAMA_SERVER = "http://10.0.0.184:11434"  # 修改为你的服务器 IP
MODEL_NAME = "qwen3:8b"


# ===== 示例 1：简单问答 =====
def simple_chat(prompt):
    """简单的问答请求"""
    url = f"{OLLAMA_SERVER}/api/generate"

    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": False  # 不使用流式输出
    }

    response = requests.post(url, json=payload)

    if response.status_code == 200:
        result = response.json()
        return result["response"]
    else:
        return f"错误: {response.status_code}"


# ===== 示例 2：流式输出 =====
def streaming_chat(prompt):
    """流式输出（适合长文本）"""
    url = f"{OLLAMA_SERVER}/api/generate"

    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": True
    }

    response = requests.post(url, json=payload, stream=True)

    print("AI: ", end="", flush=True)
    for line in response.iter_lines():
        if line:
            data = json.loads(line)
            if "response" in data:
                print(data["response"], end="", flush=True)
    print()  # 换行


# ===== 示例 3：对话历史 =====
def chat_with_history(messages):
    """带上下文的对话"""
    url = f"{OLLAMA_SERVER}/api/chat"

    payload = {
        "model": MODEL_NAME,
        "messages": messages,
        "stream": False
    }

    response = requests.post(url, json=payload)

    if response.status_code == 200:
        result = response.json()
        return result["message"]["content"]
    else:
        return f"错误: {response.status_code}"


# ===== 示例 4：检查服务器状态 =====
def check_server():
    """检查 Ollama 服务器是否在线"""
    try:
        response = requests.get(OLLAMA_SERVER, timeout=5)
        if response.status_code == 200:
            print(f"✓ 服务器在线: {OLLAMA_SERVER}")
            return True
        else:
            print(f"✗ 服务器响应异常: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"✗ 无法连接到服务器: {e}")
        return False


# ===== 示例 5：获取模型列表 =====
def list_models():
    """获取可用模型列表"""
    url = f"{OLLAMA_SERVER}/api/tags"

    try:
        response = requests.get(url)
        if response.status_code == 200:
            models = response.json()["models"]
            print("可用模型:")
            for model in models:
                print(f"  - {model['name']} ({model['size'] / 1e9:.1f} GB)")
        else:
            print(f"错误: {response.status_code}")
    except Exception as e:
        print(f"获取模型列表失败: {e}")


# ===== 主程序 =====
if __name__ == "__main__":
    print("=" * 50)
    print("Ollama Python 调用示例")
    print("=" * 50)
    print()

    # 检查服务器
    print("1. 检查服务器状态...")
    if not check_server():
        print("\n请确保:")
        print("  1. Ollama 服务器正在运行")
        print("  2. 已配置局域网访问")
        print(f"  3. OLLAMA_SERVER 设置正确: {OLLAMA_SERVER}")
        exit(1)
    print()

    # 获取模型列表
    print("2. 获取模型列表...")
    list_models()
    print()

    # 简单问答
    print("3. 简单问答测试...")
    response = simple_chat("用一句话介绍你自己")
    print(f"AI: {response}")
    print()

    # 流式输出
    print("4. 流式输出测试...")
    streaming_chat("写一首关于春天的短诗")
    print()

    # 对话历史
    print("5. 带历史的对话测试...")
    conversation = [
        {"role": "user", "content": "你好！我叫小明"},
        {"role": "assistant", "content": "你好小明！很高兴认识你。"},
        {"role": "user", "content": "我刚才说我叫什么？"}
    ]
    response = chat_with_history(conversation)
    print(f"AI: {response}")
    print()

    print("=" * 50)
    print("测试完成！")
    print("=" * 50)
