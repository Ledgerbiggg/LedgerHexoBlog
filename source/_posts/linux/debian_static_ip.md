---
title: debian系统修改静态ip
tags:
  - linux
  - debian
---

### 前言

树莓派(刷了debian)的ip每次开关机都会自动的dhcp获取动态网络,每次使用电脑连接都要使用树莓派执行ip a指令去获取树莓派的ip才可以,这样比较麻烦,如何给他分配一个固定的ip呢??

### 开始

1. 执行ip a指令,发现现在的网卡eth0分配的ip 是192.168.1.9
2. 修改/etc/network/interface

- 原先的是eth0 inet dhcp执行DHCP获取动态ip

```shell
auto lo

iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet manual
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp
```

1. 修改为如下

- 192.168.1.1这个是你设置的eth0网卡的静态ip
- 255.255.255.0 子网掩码
- 192.168.1.1 网关的地址(路由器地址,这个得看你路由器使用的什么模式,比如我家用的是分路由,ip是192.168.10.1,分路由使用的是桥接模式,所以网关还是得写192.168.1.1)
- dns-nameservers是DNS服务器,写网关的ip(网络服务提供商提供的DNS服务器)

```shell
auto lo

iface lo inet loopback

allow-hotplug eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 192.168.1.1

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface default inet dhcp
```

![img](https://img2.imgtp.com/2024/02/13/YbVEV7d1.png)

1. 重启网络服务

```shell
service networking restart
```

1. 重连服务器

![img](https://img2.imgtp.com/2024/02/13/xBU4XDib.png)

1. 查看ip

- 这里看到ip已经改为静态ip了

![img](https://img2.imgtp.com/2024/02/13/rlCirM8Y.png)