# 常见问题

## 这是原生 ARM64 悟空吗？

官方安装包仍是 AMD64。原始 `tsinvc-linux` 后台由容器内 ARM64 QEMU 执行；厂商 GUI JavaScript 由同版本 ARM64 Electron 加载。Chromium、VNC、桌面和代理均原生运行。

这是项目适配，并非厂商提供的 ARM64 客户端。已验证 Debian 13 ARM64、8GB 内存、16KB 页大小；其他环境需重新验证。

## 为什么不直接运行主分支的 AMD64 容器？

本次 16KB 页大小 ARM64 Linux 环境中，完整 AMD64 容器的 VNC/D-Bus 出现库映射错误，原始 AMD64 Electron 也退出。使用原生桌面，只转译后台可以避开这些问题。

后台还需单独处理页大小引起的 Go Netlink 消息截断，见 [适配过程](arm64.md)。无需修改宿主内核页大小。

## 为什么提示 No Client Available？

Chromium 可能阻止门户访问容器内的客户端服务。在站点信息中，仅为 `newtrust.arp.cn` 开启 **Apps on device** 权限后刷新。还应确认后台进程正常，查看 `daemon-error.log`。

## healthy 为什么不代表内网可用？

健康检查验证桌面与后台进程；认证、隧道和业务授权稍后才可能就绪。先确认客户端出现连接成功状态，再运行 `sudo ./scripts/check.sh <内网URL>`。业务 SSO 的登录状态也要单独验证。

## 重建后配置还在吗？

保留命名卷时，设备身份、客户端状态和 Chromium 档案会保留。不要使用 `docker compose down -v`。登录有效期由服务端决定；旧客户端卷在升级时需要迁移。

## 如何查看日志？

~~~sh
sudo docker compose logs --tail=100
sudo docker compose exec wukong tail -n 100 /var/log/wukong/gui.log
sudo docker compose exec wukong tail -n 100 /var/log/wukong/daemon-error.log
~~~

分享前移除账号、令牌、Cookie 和业务信息。容器使用虚拟网卡，是否满足终端准入要求仍由对应单位决定。
