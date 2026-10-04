# 发布到 GitHub

建议仓库名：`docker-wukong`。

建议描述：`Run the ARP Wukong Linux client in Docker with VNC, SOCKS5 and HTTP proxies, inspired by docker-easyconnect.`

## 发布前检查

源码仓库应包含 Dockerfile、Compose、scripts、config、doc 和项目文档。`.gitignore` 已排除本机密码、下载的安装包、调试文件、截图及构建日志。

```sh
git status --short
git ls-files
```

`config/arp-provisioning.txt` 是官方链接公开的 ARP 初始化配置，不包含个人账号密码；它仅适用于对应 ARP 部署。

## 创建与推送

在 GitHub 上创建一个空仓库，名称使用 `docker-wukong`。不要在网页上额外初始化 README、LICENSE 或 .gitignore，以免与本地文件产生冲突。

本地已初始化 Git 并暂存源码后，在仓库根目录执行：

```sh
git commit -m "Initial Docker setup for ARP Wukong"
git remote add origin https://github.com/YOUR_USERNAME/docker-wukong.git
git push -u origin main
```

将 `YOUR_USERNAME` 替换为你的 GitHub 用户名。若 Git 提示未设置提交身份，请先在此仓库设置自己的 `user.name` 与 `user.email`；可以使用 GitHub 提供的 noreply 邮箱。

若使用下载的源码 ZIP，在解压后先执行：

```sh
git init -b main
git add .
```

推送后检查 Actions 中的 `Validate source`。该工作流不下载厂商客户端，也不发布 Docker 镜像。

## 后续发布

如需创建 Release，建议说明使用的客户端版本、Docker 后端和实际验证范围。发布源码即可；厂商安装包、登录状态或含业务信息的截图不应作为 Release 附件。
