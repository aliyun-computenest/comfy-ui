# 使用阿里云预装CUDA 12.4和PyTorch的基础镜像
FROM mirrors-ssl.aliyuncs.com/egs-registry.cn-hangzhou.cr.aliyuncs.com/egs/vllm:0.7.2-pytorch2.5.1-cuda12.4-ubuntu22.04

LABEL maintainer="renyun"

# 设置APT镜像源（阿里云源）
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
# 安装系统依赖（基于Ubuntu 22.04）
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg libsm6 libxext6 libgl1 libglib2.0-0 \
    git ninja-build aria2 wget

# 安装Python依赖（复用基础镜像已安装的torch/vllm）
RUN pip install --no-cache-dir \
    opencv-python-headless \
    scikit-learn \
    matplotlib \
    pandas \
    numba \
    xformers \
    "numpy<1.25" \
    SageAttention \
    Cython \
    py-build-cmake \
    aiohttp \
    ffmpeg-python \
    GitPython \
    joblib \
    lark \
    matplotlib \
    mpmath \
    onnx \
    pandas \
    qrcode \
    rich \
    scipy svglib \
    gradio>=5.0.0

# 创建工作目录并克隆仓库
WORKDIR /root
COPY download_custom_nodes_script.sh download_custom_nodes_script.sh
RUN chmod +x download_custom_nodes_script.sh && ./download_custom_nodes_script.sh

# 优化容器配置
EXPOSE 8188
WORKDIR /root/ComfyUI

# 启动命令
CMD ["python3", "main.py", "--listen", "--port", "8188", "--fast"]
# python3 main.py --listen --port 8188 --fast