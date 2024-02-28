---
title: nginx+docker制作文件下载服务器
tags:
  - nginx
  - docker
---

### 简介

- nginx作为常用的反向代理的工具,也经常用这个来实现一些其他的功能,比如文件的下载工具,本文章就要介绍一下如何使用nginx作为文件下载的服务器使用

### 启动

1. linux系统,有docker的环境
2. 创建目录和配置文件

```shell
mkdir /data/nginx/download
touch /data/nginx/nginx.conf 
```

1. 编写配置文件

```nginx
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        root   /usr/share/nginx/html;
        autoindex on;
        charset utf-8;

        location / {
            try_files $uri $uri/ =404;
        }

        error_page 404 /404.html;
        location = /40x.html {
            root /usr/share/nginx/html;
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }
    }
}
```

1. 启动nginx服务

```shell
docker run -d -p 12126:80 --name nginx \
-v /data/nginx/download:/usr/share/nginx/html \
-v /data/nginx/nginx.conf:/etc/nginx/nginx.conf \
nginx
```

1. 访问端口,就可以下载目录的文件啦

![img](https://img2.imgtp.com/2024/02/28/wK6G3zE7.png)




