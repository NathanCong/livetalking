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
|AVATAR_ID|数字人角色 ID|是|可选：lss（罗素素）、lys（梁医生）、xyzs（小伊助手）|
|REF_FILE|数字人音色 ID|是|例如：zh_female_qingxinnvsheng_uranus_bigtts（罗素素音色）、zh_male_dongfanghaoran_uranus_bigtts（梁医生音色）|
|LISTEN_PORT|数字人服务端口|是|例如：8010、8011、8012|
|GPU_DEVICE_TYPE|数字人 GPU 设备类型|是|可选：v100、3090、5090|
|GPU_DEVICE_ID|数字人 GPU 设备 ID|否|例如：0、1、2，默认：0|

## 使用示例

```bash
#
# 启动【罗素素】数字人
#
sudo bash ./livetalking/scripts/start.sh lss zh_female_qingxinnvsheng_uranus_bigtts 8011 v100 0

#
# 启动【梁医生】数字人
#
sudo bash ./livetalking/scripts/start.sh lys zh_male_dongfanghaoran_uranus_bigtts 8012 v100 1

#
# 启动【小伊助手】数字人
#
sudo bash ./livetalking/scripts/start.sh xyzs zh_female_qingxinnvsheng_uranus_bigtts 8013 v100 2
```
