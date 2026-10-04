# 自行构建

## 环境

- ARM64 Linux 服务器，Docker 与 Docker Compose v2。
- Docker 可提供 `/dev/net/tun` 和 `NET_ADMIN`；宿主页大小支持 4KB 或 16KB。
- Bash、curl、openssl，以及 `sha256sum` 或 `shasum`。
- 构建网络能够访问 Debian 软件源、ARP 官方下载地址和 GitHub Electron Releases。

构建和运行都使用 ARM64 工具。AMD64 glibc 只下载、提取，不执行其安装脚本或二进制；QEMU 位于容器内，无需安装宿主机 qemu-user-binfmt。

## 构建

在仓库根目录执行：

~~~sh
cp .env.example .env
# 编辑 .env，设置 WUKONG_BIND_IP 为服务器实际地址。
./scripts/download-client.sh
./scripts/download-electron.sh
./scripts/setup.sh
sudo docker compose build
sudo docker compose up -d
~~~

也可从以下官方地址手动下载到 `packages/`。下载脚本与 Dockerfile 均核验固定 SHA-256，二进制不纳入版本控制。

| 文件 | SHA-256 |
| --- | --- |
| `Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb` | `15d7cee09556f15090e8502e7db0633ee3accac56d44b447e9ff6bd96df58bed` |
| `electron-v22.3.2-linux-arm64.zip` | `d9436201a8725d717819088df01512dae5b1b7daf7f94b9a9d1a8f27e0d8e830` |

来源：[ARP 安装包](https://portal.arp.cn/software/Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb)、[Electron 22.3.2 ARM64](https://github.com/electron/electron/releases/download/v22.3.2/electron-v22.3.2-linux-arm64.zip)、[Electron 官方校验表](https://github.com/electron/electron/releases/download/v22.3.2/SHASUMS256.txt)。客户端校验值来自实际下载文件；Electron 校验值来自官方校验表。

## 实现

Dockerfile 包含三个阶段：

1. **vendor**：原生工具提取悟空安装包和 Debian Bookworm 的 AMD64 glibc，不运行厂商安装脚本。
2. **compat**：Debian Trixie 提供 ARM64 静态 QEMU，并用交叉编译器构建 AMD64 页大小兼容库。
3. **运行镜像**：Debian Bookworm ARM64，安装原生桌面和代理，使用 Electron ARM64 加载原始厂商 GUI JavaScript，显式启动 QEMU 后台。

运行镜像不包含交叉编译器。16KB 页大小修复原理与验证记录见 [ARM64 适配过程](arm64.md)。

桌面以容器 root 运行，Chromium/Electron 使用 `--no-sandbox`。网络使用 Docker bridge，授予容器 `NET_ADMIN` 和 TUN；局域网代理不带认证，仅向可信网络开放。

升级客户端需同步安装包名、校验值、Electron 版本、镜像标签和卷迁移方式，并重新核对后台依赖及 GUI 原生模块。基础检查见 [CONTRIBUTING.md](../CONTRIBUTING.md)。
