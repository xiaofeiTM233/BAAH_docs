#!/bin/bash
# 功能：配置 Ubuntu 源、Git 代理、UV PyPI 镜像

set -e

# ------------------- 1. 系统 apt 源 -------------------
SOURCES="/etc/apt/sources.list"
if [ -f "$SOURCES" ]; then
    if ! grep -q "mirrors.cernet.edu.cn" "$SOURCES"; then
        echo "未检测到 mirrors.cernet.edu.cn，正在替换 archive.ubuntu.com ..."
        sed -i 's@//.*archive.ubuntu.com@//mirrors.cernet.edu.cn@g' "$SOURCES"
        echo "替换完成。"
    else
        echo "已存在 mirrors.cernet.edu.cn，无需修改。"
    fi
else
    echo "警告：$SOURCES 不存在，跳过。"
fi

# ------------------- 2. Git 代理 -------------------
GIT_CONFIG="/app/BAAH/.git/config"
if [ -f "$GIT_CONFIG" ]; then
    if ! grep -q "v6.gh-proxy.org" "$GIT_CONFIG"; then
        echo "未检测到 v6.gh-proxy.org，将 github.com 替换为 v6.gh-proxy.com ..."
        sed -i 's@github.com@v6.gh-proxy.com@g' "$GIT_CONFIG"
        echo "替换完成。"
    else
        echo "已存在 v6.gh-proxy.org，无需修改。"
    fi
else
    echo "警告：$GIT_CONFIG 不存在，跳过。"
fi

# ------------------- 3. UV PyPI 源 -------------------
UV_MIRROR="https://mirrors.cernet.edu.cn/pypi/web/simple"
UV_CONFIG="/etc/uv/uv.toml"

mkdir -p "$(dirname "$UV_CONFIG")"

if [ -f "$UV_CONFIG" ]; then
    if grep -q "mirrors.cernet.edu.cn" "$UV_CONFIG"; then
        echo "已存在教育网 PyPI 镜像，无需修改。"
    else
        if grep -q "^\[\[.*index\]\]" "$UV_CONFIG"; then
            sed -i "s@^url = .*@url = \"$UV_MIRROR\"@" "$UV_CONFIG"
            echo "已替换 index 的 url 为教育网镜像。"
        else
            cat >> "$UV_CONFIG" << EOF

[[index]]
url = "$UV_MIRROR"
default = true
EOF
            echo "已添加教育网 PyPI 镜像配置。"
        fi
    fi
else
    cat > "$UV_CONFIG" << EOF
[[index]]
url = "$UV_MIRROR"
default = true
EOF
    echo "已创建 /etc/uv/uv.toml 并设置教育网 PyPI 镜像。"
fi

echo "所有任务执行完毕。"