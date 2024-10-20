---
title: 树莓派摄像头
tags:
  - linux
  - raspberry
  - camera
  - raspberrypi
---

要在树莓派上开启摄像头功能，你可以按照以下步骤进行操作：
步骤一：连接摄像头
首先，确保将摄像头正确连接到树莓派的摄像头接口。这个接口是位于树莓派板子上，通常是一个带有排针的插槽。
步骤二：启用摄像头模块
1.  在树莓派上打开终端或 SSH 连接到树莓派。
2.  运行以下命令来启用摄像头模块：
    sudo raspi-config
3.  在配置菜单中，使用键盘的箭头键导航到 "Interfacing Options"（接口选项），然后按回车键。
4.  在接口选项中，选择 "Camera"（摄像头），然后按回车键。
5.  选择 "Yes"（是）以启用摄像头，然后按回车键。
6.  退出 raspi-config，然后重新启动树莓派：
    sudo reboot
    步骤三：测试摄像头
1.  树莓派重启后，打开终端或 SSH 连接到树莓派。
2.  使用以下命令来拍摄照片：
    raspistill -o image.jpg

这将在当前目录下拍摄照片并保存为 image.jpg。
3.  如果你想录制视频，可以使用以下命令：
    raspivid -o video.h264

这将录制视频并保存为 video.h264。 
