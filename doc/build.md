# 自行构建

## 环境

- Docker 与 Docker Compose v2。
- Docker 后端可运行 Linux amd64 容器，并提供 TUN 与 NET_ADMIN。
- Bash、curl、openssl，以及 `sha256sum` 或 `shasum`。

Linux 可直接使用 Bash；Windows 可在 WSL 中运行脚本并连接 Docker Desktop；macOS 可使用 Bash 和支持 Linux 容器的 Docker 后端。ARM 主机需要后端提供 amd64 转译。这些条件不保证单位准入策略接受当前终端。

## 构建

在仓库根目录执行：

```sh
./scripts/download-client.sh
./scripts/setup.sh
docker compose build
docker compose up -d
```

安装包下载至 `packages/`，不纳入版本控制。下载脚本和 Dockerfile 均校验 SHA-256；可自行从同一官方地址下载并放入该目录。

- 客户端：`Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb`
- 官方下载页：https://newtrust.arp.cn/client/download
- SHA-256：`15d7cee09556f15090e8502e7db0633ee3accac56d44b447e9ff6bd96df58bed`

该校验值来自实际下载的官方文件，不是厂商另行发布的签名。

## 实现

镜像基于 Debian，安装 Chromium、TigerVNC、Openbox 和代理服务。提取厂商安装包并初始化路径，通过 supervisord 启动 `tsinvc-linux run <config>`、GUI 和各服务。

桌面使用容器 root，Chromium/Electron 以 `--no-sandbox` 运行，仅用于受信任的单位门户。Docker 网络使用 bridge，容器增加 NET_ADMIN 和 TUN。

升级版本需同步修改安装包名、下载地址、校验值、镜像标签及持久化卷迁移方式。基础验证见 [CONTRIBUTING.md](../CONTRIBUTING.md)。
