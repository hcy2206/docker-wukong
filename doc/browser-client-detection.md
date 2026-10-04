# Chromium 报 No Client Available 的诊断

日期：2026-10-03。容器内 Chromium，访问 newtrust.arp.cn。

## 已确认的故障

页面 Console 多次报告：

`wss://localhost.tiger-sec.cn/shield/mutualEnds/status`：
`net::ERR_BLOCKED_BY_LOCAL_NETWORK_ACCESS_CHECKS`

站点信息面板显示 `Apps on device — Automatically blocked`。

本地域名在容器内解析为 127.91.2.26，后台监听该地址的 443。curl 在不禁用 TLS 验证的情况下验证证书成功；带官方 Origin 的 WebSocket 请求得到 `101 Switching Protocols` 并收到状态帧。因此当前明确故障是浏览器站点权限阻止，并非网卡枚举、端口未监听或需要重新安装客户端。

未登录时状态帧含 `clientRunning:false`，仅凭该字段不能断言 GUI 未启动。官网将 WebSocket 连接失败映射为“没有客户端”；之前将该字段视作主要原因的初步推测已被浏览器实际错误取代。

## 修复方式

在容器内 Chromium 打开 ARP 页面，点击地址栏左侧站点信息按钮，仅为 `newtrust.arp.cn` 打开 `Apps on device` 权限，刷新页面。该权限允许站点连接容器回环地址服务，浏览器配置随 home 命名卷持久化。

无需全局关闭 Local Network Access 检查，也无需忽略 HTTPS 证书错误。不添加绕过参数或伪造客户端状态。

## 修复验证

仅为 `newtrust.arp.cn` 通过 Chromium 站点信息面板启用权限并刷新后，Console 收到 `authWebSocket onmessage` 状态回复，原来的 Local Network Access 拦截错误消失。

随后从认证门户点击“新一代 ARP”，已成功进入 内网新一代 ARP 系统首页，没有再次出现 No Client Available。验证范围是容器内 Chromium 的认证和首页访问；未操作业务数据，也未验证宿主机代理访问该内网系统。

权限随现有 home 命名卷保存，无需重建镜像。本次未修改网卡或伪造物理设备。本地诊断截图不随源码发布。
