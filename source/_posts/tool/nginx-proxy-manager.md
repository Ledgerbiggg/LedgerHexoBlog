---
title: nginx-proxy-manager的搭建与使用
tags:
  - tool
  - sms
  - docker
---
### 简介

Nginx Proxy Manager（NPM）是一个基于 Nginx 和 Docker 的开源项目，旨在提供简单易用的 Web 界面来管理多个反向代理实例。它使用户能够通过直观的界面轻松地设置和管理多个域名和子域名的反向代理规则。

以下是 Nginx Proxy Manager 的一些主要特点和功能：

1.  **直观的 Web 管理界面**：Nginx Proxy Manager 提供了一个直观易用的 Web 界面，使用户可以轻松地添加、编辑和删除反向代理规则，而无需深入了解 Nginx 配置文件的语法。
2.  **多域名和子域名支持**：用户可以轻松地为多个域名和子域名设置反向代理规则，以便将请求代理到不同的后端服务。
3.  **HTTP 和 HTTPS 支持**：Nginx Proxy Manager 支持配置 HTTP 和 HTTPS 的反向代理规则，并且可以自动为配置的域名生成 Let's Encrypt 免费 SSL 证书，以实现 HTTPS 加密通信。
4.  **基于 Docker 的部署**：Nginx Proxy Manager 基于 Docker 部署，使其易于安装和使用，并且能够有效地隔离各个代理实例。
5.  **访问控制和认证**：Nginx Proxy Manager 提供了对反向代理访问进行控制的功能，包括 IP 访问控制、基本身份验证和 IP 黑白名单等。
6.  **日志和监控**：Nginx Proxy Manager 提供了实时的访问日志和监控功能，用户可以方便地查看代理流量和性能情况。



总的来说，Nginx Proxy Manager 是一个功能强大且易于使用的工具，可以帮助用户轻松地设置和管理多个域名和子域名的反向代理规则，以实现灵活的 Web 服务配置和管理。

### 启动

- docker命令

```shell
docker run -d \
  --name nginx-proxy-manager \
  -p 80:80 \
  -p 81:81 \
  -p 443:443 \
  -v /data/nginx-proxy-manager/data:/data \
  -v /data/nginx-proxy-manager/letsencrypt:/etc/letsencrypt \
  jc21/nginx-proxy-manager:latest
```

- 访问:81
- 使用默认的账户和密码(admin和changeme)

![img](https://img2.imgtp.com/2024/02/17/4wq1C6Hm.png)

- 添加代理

![img](https://img2.imgtp.com/2024/02/17/P8NJDEh5.png)

- 访问域名























































































































