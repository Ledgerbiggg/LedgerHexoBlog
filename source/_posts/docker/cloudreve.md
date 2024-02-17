---
title: cloudreve个人网盘的搭建教程
tags:
  - docker
  - 有趣的docker项目
  - cloudreve
---
### 简介

- Cloudreve 是一个基于 Go 语言开发的开源网盘系统，它类似于百度网盘或者 Dropbox 等云存储服务。用户可以在自己的服务器上搭建 Cloudreve，然后通过网页或者客户端访问来进行文件的上传、下载、管理和分享等操作。Cloudreve 支持多种存储后端，包括本地文件系统、阿里云 OSS、七牛云等，同时也提供了丰富的权限管理功能，可以控制用户对文件的访问权限。该系统还支持文件在线预览、文本编辑、音视频播放等功能，为用户提供了便捷的文件管理和共享解决方案。由于是开源项目，用户可以根据自己的需求进行定制和扩展。

#### 界面

![img](https://img2.imgtp.com/2024/02/17/xl3zt9Y1.png)

### 准备工作

1. 创建必要文件夹和文件

```shell
mkdir -p  /data/cloudreve

cd /data/cloudreve

mkdir {avatar,uploads}

touch /data/cloudreve/conf.ini

touch /data/cloudreve/cloudreve.db
```

1. 编写docker-compose.yml文件

```shell
mkdir /compose/cloudreve
vim docker-compose.yml
version: "3.8"
services:
  cloudreve:
    container_name: cloudreve
    image: cloudreve/cloudreve:latest
    restart: unless-stopped
    ports:
      - "5212:5212"            # 冒号左边的 5212 可以换成主机未被占用的端口
    volumes:
      - temp_data:/data
      - /data/cloudreve/uploads:/cloudreve/uploads        # 冒号左边的这个可以换成你自己服务器的路径
      - /data/cloudreve/conf.ini:/cloudreve/conf.ini      # 冒号左边的这个可以换成你自己服务器的路径
      - /data/cloudreve/cloudreve.db:/cloudreve/cloudreve.db  # 冒号左边的这个可以换成你自己服务器的路径
      - /data/cloudreve/avatar:/cloudreve/avatar
    depends_on:
      - aria2
  aria2:
    container_name: aria2
    image: ddsderek/aria2-pro
    restart: unless-stopped
    environment:
      - RPC_SECRET=your_aria_rpc_token  # 注意修改一下这个密钥
      - RPC_PORT=6800
      - DOWNLOAD_DIR=/data
      - PUID=0
      - PGID=0
      - UMASK_SET=022
      - TZ=Asia/Shanghai
    volumes:
      - /data/aria2/config:/config    # 冒号左边的这个可以换成你自己服务器的路径
      - temp_data:/data
volumes:
  temp_data:
    driver: local
    driver_opts:
      type: none
      device: $PWD/data
      o: bind
```

1. 启动

```shell
docker-compose up -d
```

1. 查看用户名和密码

```shell
docker logs cloudreve
```

![img](https://img2.imgtp.com/2024/02/17/mlhm0TUz.png)

1. 访问ip:5212(使用用户名和密码)

![img](https://img2.imgtp.com/2024/02/17/QvXpNMKR.png)

1. 新增存储空间

![img](https://img2.imgtp.com/2024/02/17/sQhJtlgQ.png)

![img](https://img2.imgtp.com/2024/02/17/OUS8MrlG.png)




