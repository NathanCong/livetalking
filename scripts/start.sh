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
# 获取启动参数
#
# AVATAR_ID        数字人角色 ID
# REF_FILE         数字人音色 ID
# LISTEN_PORT      数字人服务端口
# GPU_DEVICE_TYPE  数字人 GPU 设备类型（v100 / 3090 / 5090）
# GPU_DEVICE_ID    数字人 GPU 设备 ID（0 / 1 / ...）
#
export AVATAR_ID="$1"
export REF_FILE="$2"
export LISTEN_PORT="$3"
export GPU_DEVICE_TYPE="${4,,}"
export GPU_DEVICE_ID="$5"

#
# 启动参数校验
#
if [[ -z "$AVATAR_ID" ]]; then
  echo "错误：数字人角色 ID 参数不能为空！"
  exit 1
fi

if [[ -z "$REF_FILE" ]]; then
  echo "错误：数字人音色 ID 参数不能为空！"
  exit 1
fi

if [[ -z "$LISTEN_PORT" ]]; then
  echo "错误：数字人服务端口参数不能为空！"
  exit 1
fi

if [[ -z "$GPU_DEVICE_TYPE" ]]; then
  echo "错误：数字人 GPU 设备类型参数不能为空！"
  exit 1
fi

if [[ -z "$GPU_DEVICE_ID" ]]; then
  GPU_DEVICE_ID=0
fi

#
# 设置 Docker 构建参数
#
BUILD_ARGS=()

if [[ "$GPU_DEVICE_TYPE" == v100 ]]; then
  BUILD_ARGS=(
    --build-arg TORCH_VERSION=2.7.1
    --build-arg TORCHVISION_VERSION=0.22.1
    --build-arg TORCHAUDIO_VERSION=2.7.1
    --build-arg TORCH_INDEX_URL=https://download.pytorch.org/whl/cu118
  )
fi

if [[ "$GPU_DEVICE_TYPE" == 3090 ]]; then
  BUILD_ARGS=(
    --build-arg TORCH_VERSION=2.9.1
    --build-arg TORCHVISION_VERSION=0.24.1
    --build-arg TORCHAUDIO_VERSION=2.9.1
    --build-arg TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128
  )
fi

if [[ "$GPU_DEVICE_TYPE" == 5090 ]]; then
  BUILD_ARGS=(
    --build-arg TORCH_VERSION=2.9.1
    --build-arg TORCHVISION_VERSION=0.24.1
    --build-arg TORCHAUDIO_VERSION=2.9.1
    --build-arg TORCH_INDEX_URL=https://download.pytorch.org/whl/cu128
  )
fi

#
# 创建 Docker 环境变量
#
DOUBAO_APPID=3357549641
DOUBAO_TOKEN=7wSj2mnvz6aFibl2jDOdREFYf_NnW2wX

printf 'AVATAR_ID=%s\nREF_FILE=%s\nLISTEN_PORT=%s\nGPU_DEVICE_TYPE=%s\nGPU_DEVICE_ID=%s\nDOUBAO_APPID=%s\nDOUBAO_TOKEN=%s\n' \
  "$AVATAR_ID" "$REF_FILE" "$LISTEN_PORT" "$GPU_DEVICE_TYPE" "$GPU_DEVICE_ID" "$DOUBAO_APPID" "$DOUBAO_TOKEN" > ".env"

#
# 构建 Docker 镜像并启动服务
#
docker compose -f compose.yaml --env-file .env up -d
