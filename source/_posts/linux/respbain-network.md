---
title: 树莓派内网穿透
tags:
  - 树莓派
  - 内网穿透
---
## 1. 链接

https://www.zerotier.com

## 2. Command (指令):

安装zerotier

```shell
curl -s https://install.zerotier.com | sudo bash
sudo zerotier-cli join 41d49af6c2384b1b
```

## 3. 开机自启动

```shell
# 开机后睡个30秒再啓动zerotier
sudo nano /lib/systemd/system/zerotier-one.service
# 写入这个
[Service]
ExecStartPre=/bin/sleep 30
# 执行命令
sudo systemctl daemon-reload
sudo systemctl disable zerotier-one
sudo systemctl enable zerotier-one
```

## 4. 查看状态

```shell
sudo zerotier-cli info
sudo zerotier-cli leave 41d49af6c2384b1b
sudo zerotier-cli join 41d49af6c2384b1b
```

