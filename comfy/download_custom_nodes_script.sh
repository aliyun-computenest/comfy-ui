#!/bin/bash

set -euo pipefail

# 设置 pip 超时和重试
export PIP_DEFAULT_TIMEOUT=300
export PIP_RETRIES=5

function clone_and_install () {
    local original_dir=$(pwd)
    local url="$1"
    local repo_name=$(basename "$url" .git)

    # 克隆阶段（添加重试机制）
    echo "🔻 开始克隆: $repo_name"
    local clone_success=false
    for attempt in 1 2 3; do
        if git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$url"; then
            clone_success=true
            break
        else
            echo "⚠️ 克隆失败 (尝试 $attempt/3): $url" >&2
            if [ $attempt -lt 3 ]; then
                echo "等待 5 秒后重试..."
                sleep 5
            fi
        fi
    done

    if [ "$clone_success" = false ]; then
        echo "❌ 克隆最终失败: $url" >&2
        return 1
    fi

    # 安装依赖阶段（添加重试和更详细的错误处理）
    echo "📂 进入目录: $repo_name"
    cd "$repo_name" || return 2
    if [[ -f requirements.txt ]]; then
        echo "🔧 安装依赖: $repo_name"
        local install_success=false
        for attempt in 1 2 3; do
            if pip install --no-cache-dir --timeout 300 -r requirements.txt > /dev/null 2>&1; then
                install_success=true
                break
            else
                echo "⚠️ 依赖安装失败 (尝试 $attempt/3): $repo_name" >&2
                if [ $attempt -lt 3 ]; then
                    echo "等待 5 秒后重试..."
                    sleep 5
                fi
            fi
        done

        if [ "$install_success" = false ]; then
            echo "⚠️ 依赖安装最终失败，但继续执行: $repo_name" >&2
        fi
    else
        echo "ⓘ 未找到 requirements.txt"
    fi

    # 返回原目录
    echo "↩️ 返回上级目录"
    cd "$original_dir"

    # 返回完整路径
    echo "$(pwd)/$repo_name"
    echo "✅ 完成处理: $repo_name"
    echo "----------------------------------"
}

function clone () {
    set +e
    local url="$1"
    local repo_name=$(basename "$url" .git)

    for attempt in 1 2 3; do
        if git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$url"; then
            echo "✅ 克隆成功: $repo_name"
            set -e
            return 0
        else
            echo "⚠️ 克隆失败 (尝试 $attempt/3): $repo_name" >&2
            if [ $attempt -lt 3 ]; then
                echo "等待 5 秒后重试..."
                sleep 5
            fi
        fi
    done

    echo "❌ 克隆最终失败: $repo_name" >&2
    set -e
    return 1
}


cd /root
clone https://github.com/comfyanonymous/ComfyUI.git || exit 1
cd /root/ComfyUI

# 修复版本不存在的问题：将固定版本改为兼容版本
sed -i 's/comfyui-workflow-templates==0.7.66/comfyui-workflow-templates>=0.7.65,<0.8.0/g' requirements.txt

# 安装 ComfyUI 主要依赖（添加重试机制）
echo "🔧 安装 ComfyUI 主要依赖..."
for attempt in 1 2 3; do
    if pip install --no-cache-dir --timeout 300 -r requirements.txt; then
        echo "✅ ComfyUI 依赖安装成功"
        break
    else
        echo "⚠️ ComfyUI 依赖安装失败 (尝试 $attempt/3)" >&2
        if [ $attempt -eq 3 ]; then
            echo "❌ ComfyUI 依赖安装最终失败" >&2
            exit 1
        else
            echo "等待 10 秒后重试..."
            sleep 10
        fi
    fi
done
cd /root/ComfyUI/custom_nodes
clone_and_install https://github.com/ltdrdata/ComfyUI-Manager.git
clone_and_install https://github.com/kijai/ComfyUI-WanVideoWrapper.git
clone_and_install https://github.com/crystian/ComfyUI-Crystools.git
clone_and_install https://github.com/crystian/ComfyUI-Crystools-save.git
clone_and_install https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git
clone_and_install https://github.com/ltdrdata/ComfyUI-Impact-Pack.git
clone_and_install https://github.com/welltop-cn/ComfyUI-TeaCache.git
clone_and_install https://github.com/sh570655308/ComfyUI-TopazVideoAI.git
# General
clone_and_install https://github.com/cubiq/ComfyUI_InstantID.git
clone_and_install https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git
clone_and_install https://github.com/bash-j/mikey_nodes.git
clone_and_install https://github.com/kijai/ComfyUI-GIMM-VFI.git
clone_and_install https://github.com/liusida/ComfyUI-Login.git
clone_and_install https://github.com/city96/ComfyUI-GGUF.git
clone_and_install https://github.com/jakechai/ComfyUI-JakeUpgrade.git
clone_and_install https://github.com/Jonseed/ComfyUI-Detail-Daemon.git
clone_and_install https://github.com/cubiq/ComfyUI_IPAdapter_plus.git
clone_and_install https://github.com/spinagon/ComfyUI-seamless-tiling.git
clone_and_install https://github.com/visualbruno/ComfyUI-Hunyuan3d-2-1.git
rm -rf /root/ComfyUI/login


