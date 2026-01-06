#!/bin/bash

set -euo pipefail

function clone_and_install () {
    local original_dir=$(pwd)
    local url="$1"
    local repo_name=$(basename "$url" .git)

    # 克隆阶段
    echo "🔻 开始克隆: $repo_name"
    if ! git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$url"; then
        echo "❌ 克隆失败: $url" >&2
        return 1
    fi

    # 安装依赖阶段
    echo "📂 进入目录: $repo_name"
    cd "$repo_name" || return 2
    if [[ -f requirements.txt ]]; then
        echo "🔧 安装依赖: $repo_name"
        pip install -r requirements.txt > /dev/null
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
      set +e ;
      git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$1";
      set -e ;
}


cd /root
clone https://github.com/comfyanonymous/ComfyUI.git
cd /root/ComfyUI
# 修复版本不存在的问题：将固定版本改为兼容版本
sed -i 's/comfyui-workflow-templates==0.7.66/comfyui-workflow-templates>=0.7.65,<0.8.0/g' requirements.txt
pip install -r requirements.txt
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


