# 使用阿里云预装CUDA 12.4和PyTorch的基础镜像
FROM compute-nest-registry.cn-hangzhou.cr.aliyuncs.com/computenest/wanx-acs:latest

LABEL maintainer="renyun"

# 设置APT镜像源（阿里云源）
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libgl1 libglib2.0-0 \
    git ninja-build aria2 wget \
    build-essential cmake pkg-config \
    libopencv-dev \
    libfreetype6-dev \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 清除可能存在的旧配置，重新配置pip
RUN rm -f /root/.pip/pip.conf /etc/pip.conf && \
    pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip config set install.trusted-host mirrors.aliyun.com

# 先升级pip和基础工具
RUN pip install --no-cache-dir --upgrade \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    pip setuptools wheel

# 第一批：基础科学计算库
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    numpy \
    Cython

# 第二批：编译相关工具
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    py-build-cmake \
    ninja

# 第三批：数据处理和可视化
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    pandas \
    matplotlib \
    scipy \
    scikit-learn \
    joblib

# 第四批：图像处理
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    opencv-python-headless pillow reportlab

# 第五批：深度学习相关 - 固定兼容版本
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    numba \
    onnx \
    "transformers>=4.40.0,<4.45.0" \
    "peft>=0.10.0,<0.13.0"

# 第六批：特殊依赖
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    xformers || echo "xformers installation failed, continuing..."

RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    SageAttention || echo "SageAttention installation failed, continuing..."

# 第七批：其他工具库
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    aiohttp \
    ffmpeg-python \
    GitPython \
    lark \
    mpmath \
    rich

# 第八批：Gradio
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    "gradio>=5.0.0"

# 修复 comfyui-frontend-package
RUN pip install --no-cache-dir \
    -i https://mirrors.aliyun.com/pypi/simple/ \
    --trusted-host mirrors.aliyun.com \
    --force-reinstall \
    comfyui-frontend-package || \
    mkdir -p /usr/local/lib/python3.12/site-packages/comfyui_workflow_templates/templates

# 设置全局环境变量，确保脚本内的 pip 也能生效
ENV PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
ENV PIP_TRUSTED_HOST=mirrors.aliyun.com

# 创建工作目录并克隆仓库
WORKDIR /root
COPY download_custom_nodes_script.sh download_custom_nodes_script.sh
RUN date > /tmp/build_time
RUN chmod +x download_custom_nodes_script.sh && ./download_custom_nodes_script.sh

# 创建软链接
RUN mkdir -p /workspace/pytorch && \
    ln -s /root/ComfyUI /workspace/pytorch/ComfyUI

EXPOSE 8188
WORKDIR /root/ComfyUI

CMD ["python3", "main.py", "--listen", "--port", "8188", "--fast"]
