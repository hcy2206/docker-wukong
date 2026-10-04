# 使用说明

## 桌面与登录

启动后使用任意 VNC 客户端连接 `127.0.0.1:5902`。VNC 密码由 `scripts/setup.sh` 生成，保存在 `.secrets/vnc_password`。

容器内运行悟空/虎盾客户端及 Chromium。在客户端点击“前往登录”，通过官方页面完成登录、MFA 和设备注册。网页认证与业务入口应先在容器内浏览器中操作。

## 代理服务

| 服务 | 宿主机地址 |
| --- | --- |
| VNC | `127.0.0.1:5902` |
| SOCKS5 | `127.0.0.1:1081` |
| HTTP | `127.0.0.1:8889` |

所有映射端口只监听本机回环地址。将应用的代理设置为上述 SOCKS5 或 HTTP 地址即可；项目不会自动修改宿主机系统代理。

将示例地址替换为实际获授权的服务：

```sh
curl --proxy socks5h://127.0.0.1:1081 https://your-internal-service.example/
curl --proxy http://127.0.0.1:8889 https://your-internal-service.example/
```

`socks5h` 让容器解析目标域名。内网可达性取决于客户端登录状态、下发路由及单位准入策略。宿主机代理访问内网业务尚未实测。

## 管理与持久化

```sh
docker compose ps
docker compose logs --tail=100
./scripts/check.sh
docker compose stop
docker compose start
```

检查脚本验证主要进程和代理访问公开门户，不代替登录或内网测试。

`identity`、`home`、`client`、`logs` 命名卷分别保存设备身份、浏览器与用户配置、客户端状态和日志。重建容器时保留命名卷即可沿用配置，服务端仍可能要求重新登录。

`docker compose down -v` 会删除这些卷。升级客户端时需单独规划 `client` 卷迁移，旧卷中的文件会覆盖新镜像的同名路径。

## 配置

端口、hostname、MAC 和卷在 `compose.yaml` 中配置。默认代理面向本机单用户，未设置代理认证。

`config/arp-provisioning.txt` 来自 ARP 官方 UOS 下载链接的公开初始化配置。其他部署需使用其运营方提供的配置。
