# 常见问题

## 为什么提示 No Client Available？

新版 Chromium 可能阻止网页访问容器内的客户端服务。点击地址栏左侧站点信息，仅为 `newtrust.arp.cn` 开启 **Apps on device** 权限后刷新。

已确认的故障与验证记录见 [浏览器客户端检测](browser-client-detection.md)。

## 是否依赖 macOS 或 OrbStack？

项目使用 Docker、Linux 容器和通用 Bash 脚本，不依赖 macOS 专有命令或 OrbStack 专有接口。宿主机需要满足 [构建环境要求](build.md#环境)。

目前实测环境是 Apple Silicon + OrbStack：容器内登录、内网 ARP 首页、公开门户代理访问和身份持久化已验证。Linux、Windows 和其他后端尚未实测。

## ARM 主机能否运行？

当前官方客户端是 amd64，Compose 指定 `linux/amd64`。ARM 主机需要 Docker 后端支持 amd64 转译，本项目没有原生 ARM 客户端镜像。

## 是否需要物理网卡？

客户端的一部分检测会排除容器 veth，但本次实测仍可访问内网 ARP 首页。其他单位策略可能要求受支持的终端环境。分析见 [网卡检测](nic-detection.md)。项目不伪造硬件或绕过认证。

## 重启后配置还在吗？

在保留 Docker 命名卷时，身份、客户端状态和浏览器配置会保留。不要执行 `docker compose down -v`；登录有效期仍由服务端决定。

## 如何查看日志？

```sh
docker compose logs --tail=100
docker compose exec wukong tail -n 100 /var/log/wukong/gui.log
docker compose exec wukong tail -n 100 /var/log/wukong/daemon.log
```

分享日志前请移除账号、令牌、内部地址及业务信息。
