# 悟空 2.14.00051.1 网卡检测分析

分析日期：2026-10-03。对象为官方包内原始、未修改的 `tsinvc-linux`。

## 已确认

二进制保留 Go 符号。使用 macOS objdump 检查：

- `linuxnet.PhysicalInterfaces`（0x86ec40）调用 `bash -c`，执行 `ls -l /sys/class/net/ | grep -v "virtual"`。
- 对剩余行检查 `->`，截取最后一个 `/` 后的接口名，再调用 Go `net.InterfaceByName` 验证接口真实存在。
- 上层 `net.physicalInterfaces`（0x870e60）在没有结果时返回错误；非空时读取接口 MAC 等信息。
- `linuxnet.IsVirtualInterface`（0x86f880）读取 `/sys/class/net/<name>` 的符号链接，检查目标路径是否含 `virtual`。这里只确认该函数实现，未证明所有调用场景。

当前容器中 eth0 为 veth，sysfs 链接为 `../../devices/virtual/net/eth0`。lo 也在 virtual 下。执行客户端的枚举命令只剩 `total 0`，没有可用接口行，与日志一致。

这些函数中未见网卡厂商/OUI/PCI ID 白名单比较。不能据此推断客户端其他模块或服务端没有虚拟机检测、设备准入检查。

## 方案边界

增加 veth、dummy、TAP 或 macvlan，不能提供 PCI/virtio 设备层级。固定 MAC 只用于稳定独立设备身份，不能改变 sysfs 类型。

完整虚拟机可使用 QEMU virtio-net-pci 等设备模型，由 Linux 内核创建真实的虚拟硬件设备树。根据上述函数逻辑，这种设备可能被此枚举函数接受，但尚未实测，更不代表获服务端授权。客户端需直接运行在该虚拟机中；再次放进普通 Docker bridge 容器会重新遇到 veth。

未修改客户端二进制，未伪造 ls/readlink 输出，未挂载假的 sysfs，未复制现有可信终端身份。当前运行容器和网络配置未改动。

参考：https://www.qemu.org/docs/master/system/devices/net.html

反汇编文件仅保留在本地诊断目录，不随源码或镜像发布。上述分析对应指定版本，不能推广到其他版本。
