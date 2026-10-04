# 第三方软件与来源

MIT 许可证适用于本仓库原创的 Docker 配置、脚本和文档。ARP 悟空/虎盾客户端及镜像安装的第三方软件仍遵循各自许可，不因本仓库的 MIT 许可而重新授权。

## ARP 悟空/虎盾客户端

- 官方下载页：https://newtrust.arp.cn/client/download
- 使用版本：Linux amd64 2.14.00051.1。
- 安装包名称：`Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb`。
- 安装包由用户通过官方下载脚本获取，仓库和源码发布包均不包含厂商程序或提取后的文件。
- `config/arp-provisioning.txt` 来自官方 UOS 下载链接中公开的 ARP 初始化信息，用于该门户的首次配置；它不是用户密码或登录令牌。其他部署应使用对应单位提供的配置。

## 镜像依赖

Debian、Chromium、TigerVNC、Openbox、supervisor、tini、microsocks、tinyproxy 等由 Debian 软件源安装。各软件的许可和版权信息可在构建后的镜像 `/usr/share/doc/<软件包>/copyright` 中查看。

本项目是独立的容器化配置项目，与客户端厂商及 ARP 服务运营方无隶属关系。

## 项目启发来源

本项目受 [docker-easyconnect](https://github.com/docker-easyconnect/docker-easyconnect) 启发，借鉴其容器运行客户端、VNC 登录和代理服务的设计思路。感谢原项目及其贡献者。docker-easyconnect 的代码与许可仍属于其原项目；本仓库的 MIT 许可不改变原项目许可。
