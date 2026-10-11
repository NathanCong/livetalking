# LiveTalking

本项目使用 Docker 部署 LiveTalking 数字人服务。服务启动后通过 WebRTC 提供数字人会话，并使用 Qwen TTS（阿里云 DashScope）生成语音。

## 服务部署

```bash
#
# 下载代码
#
git clone https://github.com/NathanCong/livetalking.git
cd ./livetalking

#
# 准备模型文件
#
ls -la ./volumes/models
```

## 服务启动

```bash
#
# 设置环境变量
#
export DASHSCOPE_API_KEY='你的阿里云 DashScope API Key'

#
# 启动服务
#
sudo --preserve-env=DASHSCOPE_API_KEY bash ./scripts/start.sh \
  --avatar-id [AVATAR_ID] \
  --avatar-voice-id [AVATAR_VOICE_ID] \
  --batch-size [BATCH_SIZE] \
  --max-session [MAX_SESSION] \
  --listen-port [LISTEN_PORT] \
  --gpu-device-type [GPU_DEVICE_TYPE] \
  --gpu-device-id [GPU_DEVICE_ID]
```

## 服务停止

```bash
sudo bash ./scripts/stop.sh
```

## Tips：启动参数

|参数|参数含义|是否必须|可选值|
|:-:|:-:|:-:|:-:|
|容器内部 `--transport`|前端与服务之间的实时传输协议|固定|`webrtc`；由 Compose 固定配置|
|容器内部 `--model`|数字人视频驱动模型|固定|`musetalk`；由 Compose 固定配置|
|--avatar-id|数字人角色 ID|是|可选：lss（罗素素）、lys（梁医生）、xyzs（小伊助手）|
|容器内部 `--tts`|语音合成服务提供商|固定|`qwentts`，使用阿里云 DashScope Qwen TTS；由 Compose 固定配置|
|--avatar-voice-id|Qwen TTS 音色 ID|是|例如：`zh_female_qingxinnvsheng_uranus_bigtts`、`zh_male_dongfanghaoran_uranus_bigtts`|
|--batch-size|模型单次推理处理的帧数|否|正整数，默认：`8`；值越大吞吐量可能越高，但显存占用也越高|
|--max-session|允许同时建立的最大会话数|否|正整数，默认：`2`；值越大并发能力和显存需求越高|
|--listen-port|Web 服务监听端口|是|正整数，例如：`8010`、`8011`、`8012`|
|--gpu-device-type|用于选择 PyTorch/CUDA 依赖版本的 GPU 类型|是|`v100`、`3090` 或 `5090`|
|--gpu-device-id|容器使用的 NVIDIA GPU 编号|否|非负整数，例如：`0`、`1`、`2`；默认：`0`|

## Tips：使用建议

- 显存不足时，先降低 `--batch-size`，再降低 `--max-session`。
- 需要多个服务实例时，为每个实例使用不同的 `--listen-port` 和 `--gpu-device-id`。
- `--gpu-device-type` 必须与实际 GPU 对应，否则可能安装错误的 PyTorch CUDA 版本。

## Tips：启动示例

```bash
#
# 启动【罗素素】数字人
#
sudo --preserve-env=DASHSCOPE_API_KEY bash ./scripts/start.sh \
  --avatar-id lss \
  --avatar-voice-id zh_female_qingxinnvsheng_uranus_bigtts \
  --listen-port 8011 \
  --gpu-device-type v100 \
  --gpu-device-id 0

#
# 启动【梁医生】数字人
#
sudo --preserve-env=DASHSCOPE_API_KEY bash ./scripts/start.sh \
  --avatar-id lys \
  --avatar-voice-id zh_male_dongfanghaoran_uranus_bigtts \
  --listen-port 8012 \
  --gpu-device-type v100 \
  --gpu-device-id 1

#
# 启动【小伊助手】数字人
#
sudo --preserve-env=DASHSCOPE_API_KEY bash ./scripts/start.sh \
  --avatar-id xyzs \
  --avatar-voice-id zh_female_qingxinnvsheng_uranus_bigtts \
  --listen-port 8013 \
  --gpu-device-type v100 \
  --gpu-device-id 2
```
