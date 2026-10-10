# livetalking

LiveTalking 数字人服务

本项目为 [lipku/LiveTalking](https://github.com/lipku/LiveTalking) 提供 Docker 部署配置。
默认采用 Wav2Lip + EdgeTTS + WebRTC，适用于 Linux x86_64 服务器和 NVIDIA 显卡。

## 运行环境

- Docker Engine 和 Docker Compose V2。
- NVIDIA 显卡及支持 CUDA 12.8 的驱动；上游推荐 Wav2Lip 使用 RTX 3060 或更高配置。
- 安装并配置 [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)，使 Docker 可以使用 GPU。
- 构建时需要访问 GitHub、Debian 软件源、PyPI 和 PyTorch 下载站；运行时 EdgeTTS 需要联网。
- 按上游 WebRTC 要求，为客户端放行 TCP 8010 和 UDP 1–65535；如果修改 HTTP_PORT，则放行对应 TCP 端口。主机网络不负责配置防火墙或云安全组。

当前配置使用 `network_mode: host`，服务直接监听宿主机端口，不需要添加 `ports`。服务器在 NAT 后面时，仍可能需要额外配置 STUN/TURN 或网络转发。

## 准备模型和数字人素材

从上游提供的 [夸克网盘](https://pan.quark.cn/s/83a750323ef0) 或 [Google Drive](https://drive.google.com/drive/folders/1FOC_MD6wdogyyX_7V1d4NDIO7P9NlSAJ?usp=sharing) 下载：

1. `wav2lip256.pth`：放入本项目 `models/` 目录，并重命名为 `wav2lip.pth`。
2. `wav2lip256_avatar1.tar.gz`：解压到 `data/avatars/`，保留整个数字人目录。

在 Linux 服务器上先创建目录：

```bash
mkdir -p models data/avatars data/record
```

最终目录结构应类似：

```text
livetalking/
├── Dockerfile
├── compose.yaml
├── models/
│   └── wav2lip.pth
└── data/
    ├── avatars/
    │   └── wav2lip256_avatar1/
    │       ├── coords.pkl
    │       ├── face_imgs/
    │       └── full_imgs/
    └── record/
```

模型和素材不包含在镜像里，缺少这些文件时服务无法启动。`models/` 为只读挂载，`data/` 可写并保存数字人素材和录制结果。

## 构建和启动

```bash
docker compose config --quiet
docker compose up -d --build
docker compose logs -f livetalking
```

首次构建需要下载 PyTorch、CUDA 运行库和其他依赖，耗时和镜像体积都较大。
浏览器访问 `http://服务器IP:8010/index.html`，点击“开始连接”，再提交文本。
直接文本播报无需大模型密钥；选择聊天模式时，需要配置 `DASHSCOPE_API_KEY`。

```bash
# 查看服务状态
docker compose ps

# 确认容器中的 PyTorch 可以使用 GPU
docker compose exec livetalking python -c "import torch; print(torch.__version__, torch.version.cuda); print('CUDA available:', torch.cuda.is_available())"

# 停止并移除容器，宿主机模型和数据仍保留
docker compose down
```

健康检查只检查 HTTP 页面，数字人播放和声音仍需在浏览器中实际验证。

## 可选配置

可在本项目根目录创建 `.env`，Compose 会自动读取；所有变量都有默认值，可以直接使用默认配置启动：

```dotenv
GPU_DEVICE_ID=0
HTTP_PORT=8010
AVATAR_ID=wav2lip256_avatar1
TTS_VOICE=zh-CN-YunxiaNeural
BATCH_SIZE=16
MAX_SESSION=5
# 仅聊天模式需要；不要将实际密钥提交到 Git。
DASHSCOPE_API_KEY=
```

修改 `.env` 后运行 `docker compose up -d`。修改 `AVATAR_ID` 时，需准备对应的数字人素材目录。

镜像使用 Python 3.12 和 PyTorch 2.9.1 / torchvision 0.24.1 / torchaudio 2.9.1（CUDA 12.8），与当前上游安装文档一致。
Dockerfile 从上游拉取源码，默认固定提交 `eaa2b91559a5c2ed6127e17728efd52b7c407a0d`；本地目录不需要放上游 Python 源码。
要更新源码，在 `.env` 设置 `LIVETALKING_REF=目标提交号或版本标签`，再运行 `docker compose up -d --build`。
上游部分 Python 依赖未锁定版本，因此重新构建时这些依赖仍可能变化。
