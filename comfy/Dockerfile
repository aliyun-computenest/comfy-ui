# 使用阿里云预装CUDA 12.4和PyTorch的基础镜像
FROM mirrors-ssl.aliyuncs.com/egs-registry.cn-hangzhou.cr.aliyuncs.com/egs/vllm:0.7.2-pytorch2.5.1-cuda12.4-ubuntu22.04

LABEL maintainer="renyun"

# 设置APT镜像源（阿里云源）
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖（opencv-python-headless 需要这些库）
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

# 配置pip使用阿里云镜像源
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip config set install.trusted-host mirrors.aliyun.com

# 先升级pip和基础工具
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# 第一批：基础科学计算库
RUN pip install --no-cache-dir \
    "numpy<1.25" \
    Cython

# 第二批：编译相关工具
RUN pip install --no-cache-dir \
    py-build-cmake \
    ninja

# 第三批：数据处理和可视化
RUN pip install --no-cache-dir \
    pandas \
    matplotlib \
    scipy \
    scikit-learn \
    joblib

# 第四批：图像处理 - 逐个安装并添加详细日志
RUN pip install --no-cache-dir --verbose opencv-python-headless 2>&1 | tee /tmp/opencv_install.log || \
    (echo "OpenCV installation failed, trying alternative..." && \
     pip install --no-cache-dir opencv-contrib-python-headless)

RUN pip install --no-cache-dir pillow

RUN pip install --no-cache-dir reportlab

RUN pip install --no-cache-dir svglib

RUN pip install --no-cache-dir qrcode[pil]

# 第五批：深度学习相关
RUN pip install --no-cache-dir \
    numba \
    onnx

# 第六批：特殊依赖（可能有编译需求）
RUN pip install --no-cache-dir xformers || \
    echo "xformers installation failed, continuing..."

RUN pip install --no-cache-dir SageAttention || \
    echo "SageAttention installation failed, continuing..."

# 第七批：其他工具库
RUN pip install --no-cache-dir \
    aiohttp \
    ffmpeg-python \
    GitPython \
    lark \
    mpmath \
    rich

# 第八批：Gradio
RUN pip install --no-cache-dir "gradio>=5.0.0"

# 创建工作目录并克隆仓库
WORKDIR /root
COPY download_custom_nodes_script.sh download_custom_nodes_script.sh
RUN date > /tmp/build_time
RUN chmod +x download_custom_nodes_script.sh && ./download_custom_nodes_script.sh

# 优化容器配置
EXPOSE 8188
WORKDIR /root/ComfyUI

# 启动命令
CMD ["python3", "main.py", "--listen", "--port", "8188", "--fast"]
