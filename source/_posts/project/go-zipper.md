---
title: 解压缩的小程序
tags:
  - project
  - go
  - go-zipper
---

[项目地址](https://github.com/Ledgerbiggg/go-zip)
### 项目简介

- 这个是用go语言编写的一个文件解压缩的小程序

### 快速使用

- 配置文件如下(修改配置,是否启用需要根据实际情况修改)
- 启动程序 main.exe

```yaml
zip:
  # 是否启用
  enable: true
  # 解压成为的压缩包名称
  name: log.zip
  # 压缩的源目录(不建议修改),压缩包会放在程序的根目录下
  dir: src

unzip:
  # 是否启用
  enable: false
  # 需要被解压的压缩包名称
  name: log.zip
  # 解压到该目录下(不建议修改),压缩包请放置程序的根目录下
  dir: dest

tarGz:
  # 是否启用
  enable: true
  # 解压成为的压缩包名称
  name: log.tar.gz
  # 压缩的源目录(不建议修改),压缩包会放在程序的根目录下
  dir: src

untarGz:
  # 是否启用
  enable: false
  # 解压成为的压缩包名称
  name: log.tar.gz
  # 压缩的源目录(不建议修改),压缩包会放在程序的根目录下
  dir: dest
```
- 修改好配置文件之后,将需要压缩的文件放入src目录
  ![](https://img2.imgtp.com/2024/02/24/e4F5YaHD.png)
- 启动程序(双击goZipper.exe)
  ![](https://img2.imgtp.com/2024/02/24/xdKFfKUw.png)
- 可以看到被压缩的文件已经在根目录下面了
  ![](https://img2.imgtp.com/2024/02/24/f7cwY9JR.png)

* 解压缩同理









































