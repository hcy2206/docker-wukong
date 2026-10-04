#!/bin/bash
set -euo pipefail
test -s /etc/machine-id
test -c /dev/net/tun
xdpyinfo -display :1 >/dev/null 2>&1
for process in Xtigervnc TSINClient chromium microsocks tinyproxy; do
    ps -eo stat=,comm= | awk -v target="$process" '
        $2 == target && $1 !~ /^[ZX]/ { alive = 1 }
        END { exit !alive }
    '
done
# Explicit QEMU execution changes the comm field; verify the live backend args.
ps -eo stat=,args= | awk '
    $2 == "/usr/local/bin/qemu-x86_64" && $1 !~ /^[ZX]/ &&
    index($0, "/usr/lib/tsinclient/resources/extraResource/linux/tsinvc-linux run ") { alive = 1 }
    END { exit !alive }
'
