#!/usr/bin/env bash

#
# 让 Bash 在遇到某些错误时停止执行
#
set -euo pipefail

#
# 进入项目根目录
#
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

#
# 初始化参数
#
# AVATAR_ID       : 数字人形象 ID
# AVATAR_VOICE_ID : 数字人语音 ID
# BATCH_SIZE      : 批处理大小
# MAX_SESSION     : 最大会话数
# LISTEN_PORT     : 服务监听端口
# GPU_DEVICE_TYPE : GPU 设备类型（如 v100、a100 等）
# GPU_DEVICE_ID   : GPU 设备 ID
#
AVATAR_ID=""
AVATAR_VOICE_ID=""
BATCH_SIZE="8"
MAX_SESSION="2"
LISTEN_PORT=""
GPU_DEVICE_TYPE=""
GPU_DEVICE_ID="0"

#
# 解析命令行参数
#
while [[ $# -gt 0 ]]; do
  case "$1" in
    --avatar-id) AVATAR_ID="$2"; shift 2 ;;
    --avatar-voice-id) AVATAR_VOICE_ID="$2"; shift 2 ;;
    --batch-size) BATCH_SIZE="$2"; shift 2 ;;
    --max-session) MAX_SESSION="$2"; shift 2 ;;
    --listen-port) LISTEN_PORT="$2"; shift 2 ;;
    --gpu-device-type) GPU_DEVICE_TYPE="$2"; shift 2 ;;
    --gpu-device-id) GPU_DEVICE_ID="$2"; shift 2 ;;
    *) echo "错误：未知参数：$1" >&2; exit 1 ;;
  esac
done

#
# 必填参数校验
#
[[ -n "$AVATAR_ID" ]] || { echo "错误：--avatar-id 参数不能为空！" >&2; exit 1; }
[[ -n "$AVATAR_VOICE_ID" ]] || { echo "错误：--avatar-voice-id 参数不能为空！" >&2; exit 1; }
[[ -n "$LISTEN_PORT" ]] || { echo "错误：--listen-port 参数不能为空！" >&2; exit 1; }
[[ -n "$GPU_DEVICE_TYPE" ]] || { echo "错误：--gpu-device-type 参数不能为空！" >&2; exit 1; }

#
# 参数格式校验
#
[[ "$BATCH_SIZE" =~ ^[1-9][0-9]*$ ]] || { echo "错误：--batch-size 必须是正整数。" >&2; exit 1; }
[[ "$MAX_SESSION" =~ ^[1-9][0-9]*$ ]] || { echo "错误：--max-session 必须是正整数。" >&2; exit 1; }
[[ "$LISTEN_PORT" =~ ^[1-9][0-9]*$ ]] || { echo "错误：--listen-port 必须是正整数。" >&2; exit 1; }
[[ "$GPU_DEVICE_ID" =~ ^[0-9]+$ ]] || { echo "错误：--gpu-device-id 必须是非负整数。" >&2; exit 1; }

#
# 根据 GPU 设备类型设置构建参数
#
BUILD_ARGS=(
  --build-arg TORCH_VERSION=2.9.1
  --build-arg TORCHVISION_VERSION=0.24.1
  --build-arg TORCHAUDIO_VERSION=2.9.1
  --build-arg TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128
)

if [[ "$GPU_DEVICE_TYPE" == "v100" ]]; then
  BUILD_ARGS=(
    --build-arg TORCH_VERSION=2.7.1
    --build-arg TORCHVISION_VERSION=0.22.1
    --build-arg TORCHAUDIO_VERSION=2.7.1
    --build-arg TORCH_INDEX_URL=https://download.pytorch.org/whl/cu118
  )
fi

#
# 设置 DASHSCOPE_API_KEY 环境变量，如果未设置则默认为空字符串
#
DASHSCOPE_API_KEY="${DASHSCOPE_API_KEY:-}"

#
# 创建 .env 文件
#
cat > .env <<EOF
AVATAR_ID=${AVATAR_ID}
AVATAR_VOICE_ID=${AVATAR_VOICE_ID}
BATCH_SIZE=${BATCH_SIZE}
MAX_SESSION=${MAX_SESSION}
LISTEN_PORT=${LISTEN_PORT}
GPU_DEVICE_TYPE=${GPU_DEVICE_TYPE}
GPU_DEVICE_ID=${GPU_DEVICE_ID}
DASHSCOPE_API_KEY=${DASHSCOPE_API_KEY}
EOF

#
# 构建 Docker 镜像并启动服务
#
COMPOSE=(docker compose -f compose.yaml --env-file .env)
"${COMPOSE[@]}" build "${BUILD_ARGS[@]}"
"${COMPOSE[@]}" up -d --no-build
