# ARM64 Linux 适配过程

## 环境与目标

2026-10-04，在 Debian 13 ARM64、8GB 内存、16KB 内核页大小、Docker 29.8.2 环境完成部署。官方客户端为悟空 2.14.00051.1 AMD64。

保留厂商业务代码，使用 ARM64 原生桌面和代理，只转译 AMD64 后台。日常操作见 [使用说明](usage.md)，构建见 [构建说明](build.md)。

## 原生桌面与转译后台

完整 AMD64 镜像在该 16KB 页大小环境中遇到 VNC/D-Bus 库映射失败，原始 AMD64 Electron 也在 MADV_DONTNEED 返回 EINVAL 后退出。

采用 ARM64 Debian 安装 Chromium、TigerVNC、Openbox 和代理。官方客户端声明 Electron 22.3.2，因此使用同版本 ARM64 Electron 加载原始 resources/app，保留厂商 JavaScript 和资源。tsinvc-linux 通过容器内静态 ARM64 QEMU 显式启动。

构建使用原生工具提取官方安装包及 AMD64 glibc，无需预先导入其他机器的镜像或注册宿主 AMD64 binfmt。

## 16KB 页大小兼容

宿主页大小为 16384，但 QEMU 默认为 AMD64 程序提供 AT_PAGESZ=4096。该后台的 Go NetlinkRIB 据此分配缓冲区；新增 TUN 网卡后，链路消息超过 4KB，被截断并报 netlinkrib: invalid argument，导致隧道无法建立。

兼容库 scripts/auxv-pagesize.c 在 Go 初始化前将初始辅助向量中的 AT_PAGESZ 改为 16384，按 16KB ELF 段对齐构建，仅预加载到后台进程，不修改厂商二进制。

scripts/backend.sh 按宿主页大小启动：16KB 加载兼容库，4KB 直接执行 QEMU，其他页大小退出。无需调整宿主内核。4KB 路径尚未完成同等范围的部署验证。

依据：[QEMU ELF 加载器](https://github.com/qemu/qemu/blob/v10.0.0/linux-user/elfload.c)、[Go NetlinkRIB](https://go.dev/src/syscall/netlink_linux.go)。

## 登录状态与进程管理

将已有悟空容器的 Chromium 档案和 NSS 证书数据库迁入目标 home 卷，保留网站权限和登录状态，不复制设备身份或后台状态。本次迁移后成功恢复认证；具体迁移范围见使用说明。

桌面脚本在 GUI 或 Chromium 退出后清理桌面组，由 Supervisor 重启。健康检查排除僵尸进程，并按 QEMU 命令行识别后台。

## 验证范围

- 已验证原生 GUI、Chromium、VNC、两种代理和 QEMU 后台；容器健康检查通过。
- 已验证悟空认证、隧道建立及内网门户访问；重建容器后保留卷可恢复状态。
- 远端 VNC 返回 RFB 003.008，两种代理访问内网门户均返回 HTTP 200。
- 独立构建镜像已在同一 ARM64 环境通过临时容器启动验证：GUI 出现 appReady，健康检查通过，两种代理访问公开门户均为 HTTP 200。此临时容器未使用现有登录卷，未重新验证账号登录和内网隧道。

这是一种容器适配方案，并非厂商提供的 ARM64 客户端。其他 ARM64 服务器、长期稳定性和不同单位的终端准入策略需分别验证。
