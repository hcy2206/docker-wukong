# 构建依赖

此目录仅在本地存放构建所需的二进制，仓库不分发厂商程序或 Electron 安装包。

~~~sh
./scripts/download-client.sh
./scripts/download-electron.sh
~~~

脚本从官方地址下载固定版本并校验 SHA-256。当前文件：

- `Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb`
- `electron-v22.3.2-linux-arm64.zip`

离线环境可在其他机器下载并校验后复制到本目录，再使用可访问 Debian 软件源的构建环境。具体校验值见 [构建说明](../doc/build.md)。
