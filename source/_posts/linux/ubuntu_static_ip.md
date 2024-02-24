---
title: ubuntu系统修改静态ip
tags:
  - linux
  - ubuntu
---

### 前言

* 之前讲了debian如何获取静态ip,现在讲ubuntu如何获取静态ip

### 开始
1. 查看ip

```shell
ip a
```

![img](https://img2.imgtp.com/2024/02/21/AKBHAcDm.png)

1. 修改配置文件(注意权限问题)

- 一个是wifi的一个是网线

```yaml
cd /etc/netplan
```

![img](https://img2.imgtp.com/2024/02/21/MxZ5f5In.png)

- 网线分配静态ip的配置(00-installer-config-wifi.yaml)

```yaml
network:
  version: 2
  ethernets:
    enp2s0: # 网卡名称
      dhcp4: no # 取消分配静态ip
      addresses: [192.168.1.101/24] # 你的静态IP地址和子网掩码
      nameservers:
        addresses: [192.168.1.1, 8.8.8.8, 8.8.4.4] # DNS服务器地址
```

- wifi 分配静态ip的配置(00-installer-config.yaml)

```yaml
# 00-installer-config-wifi.yaml
network:
  version: 2
  wifis:
    wlp3s0: # 无线网卡名称
      dhcp4: no # 取消分配静态ip
      addresses: [192.168.1.100/24] # 你的静态IP地址和子网掩码
      routes: # 设置成为默认路由
        - to: 0.0.0.0/0
          via: 192.168.1.1
      nameservers:
        addresses: [192.168.1.1, 8.8.8.8, 8.8.4.4] # DNS服务器地址
      access-points:
        "WiFi名字":
          password: "WiFi密码" # 你的WiFi密码
```

1. 重启网络

```shell
sudo netplan generate # 没有报错则ok
sudo netplan apply # 此时应用静态ip修改，IP地址发生改变
```

1. 查看ip

```shell
ip a
```
