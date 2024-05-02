---
title: 树莓派安装docker
tags:
  - 树莓派
  - docker
---
```shell



sudo apt-get update




sudo apt-get install apt-transport-https ca-certificates software-properties-common -y



curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo apt-key add -



echo "deb [arch=armhf] https://download.docker.com/linux/raspbian/ $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list




sudo apt-get update




sudo apt-get install docker-ce docker-ce-cli containerd.io -y




sudo usermod -aG docker ledger



docker version

```