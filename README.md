# docker-wukong · ARM64 Linux

让官方 AMD64 悟空/虎盾零信任客户端运行在 ARM64 Linux 服务器的 Docker 容器中，提供 VNC 桌面、SOCKS5 和 HTTP 代理。

本分支 `arm64` 面向 ARM64 Linux 服务器；[main](https://github.com/hcy2206/docker-wukong/tree/main) 保留完整 AMD64 容器方案。目录和操作方式与主分支一致。

本项目受 [docker-easyconnect](https://github.com/docker-easyconnect/docker-easyconnect) 启发，使用 ARP 官方客户端安装包，客户端版权归原权利人所有。本项目不是厂商的官方项目。

详细用法见 [doc/usage.md](doc/usage.md)，常见问题见 [doc/faq.md](doc/faq.md)，自行构建见 [doc/build.md](doc/build.md)，适配过程见 [doc/arm64.md](doc/arm64.md)。

## 简明使用步骤

需要 ARM64 Linux 服务器、Docker Compose v2，以及 `/dev/net/tun` 和 `NET_ADMIN`。已在 Debian 13 ARM64、8GB 内存、16KB 内核页大小的环境验证。

1. 获取本分支并在 Bash 终端中进入目录：

   ~~~sh
   git clone --branch arm64 https://github.com/hcy2206/docker-wukong.git
   cd docker-wukong
   cp .env.example .env
   ~~~

   修改 `.env` 的 `WUKONG_BIND_IP` 为服务器实际 IPv4 地址；默认 `127.0.0.1` 仅供本机访问。

2. 下载并校验依赖，创建 VNC 密码，然后构建启动：

   ~~~sh
   ./scripts/download-client.sh
   ./scripts/download-electron.sh
   ./scripts/setup.sh
   sudo docker compose up -d --build
   ~~~

3. 连接 `服务器IP:5902` 的 VNC 桌面，密码通过 `cat .secrets/vnc_password` 查看。在容器内 Chromium 完成悟空登录。
4. 使用 `服务器IP:1081` 的 SOCKS5 代理或 `服务器IP:8889` 的 HTTP 代理访问获授权的服务。

若网页提示 **No Client Available**，在 Chromium 的站点信息中为 `newtrust.arp.cn` 开启 **Apps on device** 权限后刷新。

配置和登录状态保存在 Docker 命名卷中。日常停止使用 `sudo docker compose stop`；`docker compose down -v` 会删除身份和登录状态。

## 构建与兼容性

当前官方客户端为 **2.14.00051.1 / AMD64**。仅 `tsinvc-linux` 后台通过容器内 ARM64 QEMU 转译；Electron 22.3.2、Chromium、VNC、桌面和代理均为 ARM64 原生程序。构建从官方安装包和 Debian 软件源提取 AMD64 文件，无需预先导入 Mac 镜像，也无需宿主机注册 AMD64 binfmt。

已在上述 ARM64 Linux 环境验证悟空登录、内网 ARP 首页、局域网两种代理和 VNC。其他设备、单位准入策略和长期稳定性未验证；业务系统自身仍可能要求另行登录。

## 版权及许可证

本仓库原创脚本、配置和文档采用 [MIT License](LICENSE)。第三方依赖遵循各自许可，见 [第三方说明](THIRD_PARTY_NOTICES.md)。
