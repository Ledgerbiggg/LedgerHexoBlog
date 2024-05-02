---
title: 青龙面板搭建(京东豆子)
tags:
  - docker
  - 有趣的docker项目
  - 青龙面板
---
## 先安装docker

```shell
sudo apt-get update

sudo apt-get upgrade

sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker your-user
```

## 启动容器

```shell
docker run -dit \
  -v $PWD/ql/data:/ql/data \
  -p 5700:5700 \
  --name qinglong \
  --hostname qinglong \
  --restart unless-stopped \
  whyour/qinglong:latest
```

## 登录

- 点击开始安装——点击跳过——设置账号和密码——点击提交——点击去登录——输入账号密码——点击登录

## 安装依赖

- 安装方法：点击依赖管理——点击新建依赖——依赖类型选择NodeJs——自动拆分选择是——名称把对应的依赖全部复制，然后粘贴过来（如下图）——点击确定即可（另外两个Python3、Linux同理）

![img](https://cdn.nlark.com/yuque/0/2024/png/35553992/1714527473869-65c716eb-657d-4e36-ab17-18ecadf4cdd7.png)

- NodeJs 依赖如下

```shell
request
canvas
cheerio
js-base64
dotenv
magic
tough-cookie
ws@7.4.3
require
requests
date-fns
ts-md5
typescript
json5
axios@v0.27.2
crypto-js
@types/node
png-js
node-telegram-bot-api
fs
jsdom
form-data
jieba
tslib
ds
jsdom -g
prettytable
ql
common
node-jsencrypt
juejin-helper
moment
global-agent
```

- Python3 依赖如下

```shell
bs4
telethon
cacheout
jieba
PyExecJS
ping3
canvas
Crypto
ds
requests
pycryptodome
```

- Linux 依赖如下

```shell
bizCode
bizMsg
lxml
libc-dev
gcc
g++
libffi-dev
python3-dev
```

## 环境变量

key+pin



![img](https://cdn.nlark.com/yuque/0/2024/png/35553992/1714529379470-ad9a583f-148b-4b80-b0e8-7d386ed6d132.png)

## 添加脚本

```shell
https://github.com/shufflewzc/faker2.git
0 19 11 * * ?
```

![img](https://cdn.nlark.com/yuque/0/2024/png/35553992/1714529580902-2b9a20c2-5778-45d2-84ba-558963206710.png)

- 运行

![img](https://cdn.nlark.com/yuque/0/2024/png/35553992/1714529694680-5ef4920a-c2b9-4835-96e3-bd9e878ec004.png)

## 成功

![img](https://cdn.nlark.com/yuque/0/2024/png/35553992/1714529682208-ae55fd4f-90f3-434f-a1ba-54ad700cbddf.png)