#
# 1. 设置基础镜像
#
# python:3.12-slim-bookworm  是官方提供的 Python 3.12 版本的精简镜像，基于 Debian Bookworm
#
FROM python:3.12-slim-bookworm

#
# 2. 设置构建参数
#
# SOURCE_REF           源码的 Git 提交号、标签或分支
# TORCH_VERSION        PyTorch 主包版本
# TORCHVISION_VERSION  PyTorch 的计算机视觉扩展包版本
# TORCHAUDIO_VERSION   PyTorch 的音频处理扩展包版本
# TORCH_INDEX_URL      PyTorch 下载源，末尾 cu128 表示 CUDA 12.8 构建
#
ARG SOURCE_REF=main
ARG TORCH_VERSION=2.9.1
ARG TORCHVISION_VERSION=0.24.1
ARG TORCHAUDIO_VERSION=2.9.1
ARG TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128

#
# 3. 设置环境变量
#
# PYTHONDONTWRITEBYTECODE=1                   禁止 Python 生成 .pyc 字节码缓存文件，减少容器内的文件写入
# PYTHONUNBUFFERED=1                          让 Python 的标准输出和错误输出及时显示，便于通过 docker compose logs 查看日志
# PIP_NO_CACHE_DIR=1                          禁用 pip 下载缓存，避免缓存包留在镜像中增加体积
# PIP_DISABLE_PIP_VERSION_CHECK=1             禁止 pip 检查自身的新版本，减少额外网络请求和升级提示
# NVIDIA_DRIVER_CAPABILITIES=compute,utility  告诉 NVIDIA 容器工具提供哪些驱动能力：compute 用于 CUDA 计算，utility 用于 nvidia-smi 等管理工具
#
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

#
# 4. 设置工作目录
#
WORKDIR /opt/livetalking

#
# 5. 安装系统依赖
#
# ca-certificates  提供受信任的根证书，用于验证 HTTPS 服务器证书
# git              Git 版本控制工具
# curl             HTTP 请求工具，用于容器健康检查
# ffmpeg           音视频处理工具，可以编码、转码、合并音视频
# libsndfile1      音频文件读写的底层库
# libgomp1         GCC 的 OpenMP 运行库，支持多线程并行计算
# build-essential  编译 dlib 所需的 C/C++ 工具链
# cmake            编译 dlib 所需的构建工具
# libopenblas-dev  dlib 数值计算依赖
# liblapack-dev    dlib 数值计算依赖
# libx11-dev       dlib 图像处理依赖
#
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    ffmpeg \
    libsndfile1 \
    libgomp1 \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    libx11-dev \
  && rm -rf /var/lib/apt/lists/*

#
# 6. 获取仓库源码
#
RUN git init . \
  && git remote add origin https://github.com/lipku/LiveTalking.git \
  && git fetch --depth 1 origin "${SOURCE_REF}" \
  && git checkout --detach FETCH_HEAD \
  && rm -rf .git

#
# 7. 安装应用依赖
#
RUN python -m pip install \
    "torch==${TORCH_VERSION}" \
    "torchvision==${TORCHVISION_VERSION}" \
    "torchaudio==${TORCHAUDIO_VERSION}" \
    --index-url "${TORCH_INDEX_URL}" \
  && python -m pip install -r requirements.txt \
  && python -m pip install "face_recognition==1.3.0" \
  && python -m pip check

#
# 8. 配置日志输出
#
RUN ln -sf /dev/stdout livetalking.log

#
# 9. 配置启动命令
#
ENTRYPOINT ["python", "app.py"]
