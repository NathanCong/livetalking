# livetalking

LiveTalking 数字人服务

## 服务部署

```bash
#
# 下载代码
#
git clone https://github.com/NathanCong/livetalking.git

#
# 下载模型
#
cd ./livetalking/models
```

## 服务启动

```bash
sudo bash ./livetalking/scripts/start.sh [AVATAR_ID] [REF_FILE] [LISTEN_PORT] [GPU_DEVICE_TYPE] [GPU_DEVICE_ID]
```

## 服务停止

```bash
sudo bash ./livetalking/scripts/stop.sh
```

## 启动参数

|参数|参数含义|是否必须|可选值|
|:-:|:-:|:-:|:-:|
|AVATAR_ID|数字人角色 ID|是||
|REF_FILE|数字人音色 ID|是|例如：zh_male_dongfanghaoran_uranus_bigtts（梁医生）|
|LISTEN_PORT|数字人服务端口|是|例如：8010、8011、8012|
|GPU_DEVICE_TYPE|数字人 GPU 设备类型|是|可选：v100、3090、5090|
|GPU_DEVICE_ID|数字人 GPU 设备 ID|否|例如：0、1、2，默认：0|

## 使用示例

```bash
```
