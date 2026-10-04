# 使用说明

## 桌面与代理

在 `.env` 设置 `WUKONG_BIND_IP`。默认仅监听本机回环地址；远端访问时改为服务器实际 IPv4 地址，并将以下示例地址同步替换：

| 服务 | 地址 |
| --- | --- |
| VNC | `127.0.0.1:5902` |
| SOCKS5 | `127.0.0.1:1081` |
| HTTP | `127.0.0.1:8889` |

没有设置环境变量时，端口默认只绑定 `127.0.0.1`。局域网代理未设置认证，应只向可信网络开放。

VNC 密码由 `scripts/setup.sh` 生成，保存在 `.secrets/vnc_password`。在容器客户端点击“前往登录”，通过 Chromium 完成认证、MFA 和设备注册。浏览器提示 No Client Available 时，为门户开启 Apps on device 权限。

应用使用上述代理访问获授权的内网服务；`socks5h` 让容器解析目标域名：

~~~sh
curl --proxy socks5h://127.0.0.1:1081 https://your-internal-service.example/
curl --proxy http://127.0.0.1:8889 https://your-internal-service.example/
~~~

悟空登录不等于业务系统登录；业务 SSO 页面仍可能要求输入账号。

## 管理与检查

~~~sh
sudo docker compose ps
sudo docker compose logs --tail=100
sudo ./scripts/check.sh
# 用实际内网 URL 验证两种代理：
sudo ./scripts/check.sh http://your-internal-service.example/
sudo docker compose stop
sudo docker compose start
~~~

检查脚本验证非僵尸进程、浏览器处理器和两种代理；默认请求公开门户。内网检查应在悟空完成登录并建立隧道后执行。容器 healthy 只代表进程检查通过，不证明业务登录成功。

`identity`、`home`、`client`、`logs` 卷分别保存设备身份、浏览器配置、客户端状态和日志。保留卷可在重建时沿用状态，服务端仍可能要求重新认证。`docker compose down -v` 会删除这些数据；升级客户端时，旧 `client` 卷还会覆盖新镜像的同名文件，需另行规划迁移。

本分支沿用主分支的 Compose 项目名和卷名。若服务器已有此前部署，先备份卷；切换源码不会自动切换正在运行的容器，执行 `up` 时才会更新服务。

## 可选：迁移容器内 Chromium 状态

只迁移自己已有的悟空容器状态。停止源、目标容器中的 Chromium 后，备份目标 `home` 卷，将源 `/root/.config/chromium` 和 `/root/.pki` 导入目标 `home` 卷，保留目录结构和权限；不复制 Singleton 锁、缓存、`machine-id` 或 `client` 卷。

Chromium 目录包含 Cookies、Local State 和站点权限。`.pki/nssdb` 是 NSS 证书数据库：`cert9.db` 保存证书，`key4.db` 保存密钥数据库，`pkcs11.txt` 保存模块配置，它不是 Cookie 文件。是否含私钥取决于源数据。

完整档案包含敏感登录状态，不应提交或公开。迁移后仍可能需要重新登录；本次从 Mac 悟空容器迁移后已成功恢复认证。
