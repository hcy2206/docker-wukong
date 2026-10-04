#!/bin/bash
set -euo pipefail
ulimit -c 0
backend=/usr/lib/tsinclient/resources/extraResource/linux/tsinvc-linux
config=/usr/lib/tsinclient/resources/extraResource/linux/linuxClient.json
case "$(getconf PAGESIZE)" in
    16384)
        exec /usr/local/bin/qemu-x86_64 -E LD_PRELOAD=/usr/local/lib/auxv-pagesize.so "$backend" run "$config"
        ;;
    4096)
        exec /usr/local/bin/qemu-x86_64 "$backend" run "$config"
        ;;
    *)
        echo 'Unsupported host page size for the ARM64 backend compatibility wrapper' >&2
        exit 1
        ;;
esac
