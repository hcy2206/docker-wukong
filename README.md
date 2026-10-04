# docker-wukong

让 ARP 悟空/虎盾的零信任Linux 客户端运行在 Docker 中，提供 VNC 桌面、SOCKS5 和 HTTP 代理，供宿主机连接使用。

本项目受 [docker-easyconnect](https://github.com/docker-easyconnect/docker-easyconnect) 启发，借鉴其“在容器内运行客户端，通过 VNC 登录并向宿主机提供代理”的思路独立实现。感谢该项目及其贡献者。

本项目使用 ARP 官方 Linux 客户端安装包，客户端版权归原权利人所有。本项目不是 ARP 或客户端厂商的官方项目。

详细用法见 [doc/usage.md](doc/usage.md)，常见问题见 [doc/faq.md](doc/faq.md)，自行构建见 [doc/build.md](doc/build.md)。欢迎提交 Issue 和 PR。

## 简明使用步骤

需要 Docker Compose v2，以及可运行 `linux/amd64` 容器的环境。Docker 后端须支持 `/dev/net/tun` 和 `NET_ADMIN`。可在 Linux 或提供 Linux 容器的 Docker Desktop、OrbStack 等环境使用；非 amd64 主机需要相应的转译支持。

1. 获取本仓库，在 Bash 终端中进入仓库目录并执行：

   ```sh
   ./scripts/download-client.sh
   ./scripts/setup.sh
   docker compose up -d --build
   ```

2. 使用 VNC 客户端连接 `127.0.0.1:5902`，密码通过 `cat .secrets/vnc_password` 查看。
3. 在容器桌面中打开悟空客户端，通过内置浏览器完成登录。
4. 登录后，使用 `127.0.0.1:1081` 的 SOCKS5 代理或 `127.0.0.1:8889` 的 HTTP 代理访问获授权的服务。

若网页提示 **No Client Available**，在容器浏览器的站点信息中为 `newtrust.arp.cn` 开启 **Apps on device** 权限，然后刷新。

配置及登录状态保存在 Docker 命名卷中。日常停止使用 `docker compose stop`，不要使用会删除数据的 `docker compose down -v`。

## 构建与兼容性

当前客户端版本为 **2.14.00051.1 / amd64**，从官方地址下载并校验。目前提供源码构建方式。

已在 Apple Silicon + OrbStack 环境验证容器内登录和内网 ARP 首页访问；其他环境尚待验证。更多限制见 [常见问题](doc/faq.md)。

## 版权及许可证

本仓库原创脚本、配置和文档采用 [MIT License](LICENSE)。第三方客户端及镜像依赖遵循各自许可，见 [第三方说明](THIRD_PARTY_NOTICES.md)。
