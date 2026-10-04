# 参与开发

提交修改前，请运行：

```sh
for script in scripts/*.sh; do bash -n "$script"; done
sh -n scripts/wukong-browser
docker compose config --quiet
```

Compose 校验需要先执行 `./scripts/setup.sh` 创建本机 VNC 密码。具备客户端安装包和 Docker 环境时，再执行 `docker compose build`、`docker compose up -d` 与 `./scripts/check.sh`。

涉及登录和客户端联动的修改，请说明客户端版本、CPU 架构、Docker 后端及实际验证范围。进程健康或公开门户返回 HTTP 200，均不能代替内网业务访问验证。

提交 Issue、日志或截图前，移除账号信息、内部地址、密码、令牌、Cookie 和业务数据。不要提交 `.secrets/`、`inspection/` 或厂商安装包。

升级客户端时，需要同步官方下载地址、脚本与 Dockerfile 中的校验值、Compose 镜像标签和文档，并说明持久化 client 卷的迁移方式。
