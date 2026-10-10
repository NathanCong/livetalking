# 获取上游源码；可通过构建参数切换到其他提交或版本标签。
FROM python:3.12-slim-bookworm AS source

ARG LIVETALKING_REF=eaa2b91559a5c2ed6127e17728efd52b7c407a0d

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates git \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /source

RUN git init . \
  && git remote add origin https://github.com/lipku/LiveTalking.git \
  && git fetch --depth 1 origin "${LIVETALKING_REF}" \
  && git checkout --detach FETCH_HEAD \
  && rm -rf .git

# CUDA 运行库由 PyTorch 的 cu128 wheel 及其依赖提供，宿主机提供 NVIDIA 驱动。
FROM python:3.12-slim-bookworm AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

WORKDIR /opt/livetalking

# FFmpeg 用于音视频处理与录制；libsndfile、libgomp 用于音频和数值计算。
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    libsndfile1 \
    libgomp1 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=source /source/requirements.txt ./requirements.txt

RUN python -m pip install \
    torch==2.9.1 \
    torchvision==0.24.1 \
    torchaudio==2.9.1 \
    --index-url https://download.pytorch.org/whl/cu128 \
  && python -m pip install -r requirements.txt \
  && python -m pip check

COPY --from=source /source/ ./

# 将上游写入文件的日志转到标准输出，使 docker compose logs 能看到服务日志。
RUN mkdir -p models data/avatars data/record \
  && ln -sf /dev/stdout livetalking.log

EXPOSE 8010/tcp

ENTRYPOINT ["python", "app.py"]
CMD ["--transport", "webrtc", "--model", "wav2lip", "--avatar_id", "wav2lip256_avatar1", "--tts", "edgetts", "--REF_FILE", "zh-CN-YunxiaNeural", "--listenport", "8010"]
