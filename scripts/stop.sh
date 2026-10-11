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
# 停止服务并移除 Docker 镜像
#
docker compose -f compose.yaml --env-file .env down --rmi all
