---
title: 短信验证码和电话轰炸集一体的程序
tags:
  - project
  - sms
---
[项目地址](https://github.com/Ledgerbiggg/goSMSBoom)

### 项目简介

- 这个是用go语言编写的一个短信验证码和电话轰炸集一体的程序

### 快速使用

- 配置文件如下
- 启动程序 main.exe

```yaml
ENV: win
# 手机号
Phone: xxx
# 短信验证码发送的线程数量
ThreadCount: 3
# 短信验证码发送的执行时机(默认60秒一次)
ExecutionCron: "*/60 * * * * *"
# 会话的凭证(如果打印不是:[成功发送短信给医院,静等电话....],就根据Readme文件的指引去修改这个配置)
SSID : "imlpf4ff545dda0621f63e5d2f43cda1acfc"
# 电话轰炸前的的短信咨询内容
Content: "我的电话号码是xxx,微信也是xxx,我现在有很严重的肾脏疾病,因为一些不良好的饮食习惯和作息习惯,比较严重,已经影响到我的生活,想要求助一下医生,如果可以的话请电话联系我,谢谢"
```



⁉️⁉️(如果是成功发送短信给医院,静等电话   的打印就跳过这一步)如果启动了main.exe程序之后,电脑打印结果不是:[成功发送短信给医院,静等电话....],就根据随便去一个医院的网址,比如这个网址：[上海德济医院](https://ada.baidu.com/site/shneuro.com/xyl?imid=3fb0842c76e3261b0f200158293319dc#back1707914485901)

1. 点开F12
2. 发送一个消息
3. 筛选send
4. 获取ssid修改配置文件

![img](https://img2.imgtp.com/2024/02/14/bm1MN4lV.png)

- 重新启动程序

### linux环境(配置有docker)

- 启动项目(如果电话的ssid不对,可能电话还是会打不了,这个时候要使用上述步骤去修改)

```shell
./rebuild.sh # 构建
./start.sh # 启动
./watch.sh # 查看执行情况
./end.sh # 终止
```


