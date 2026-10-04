#!/bin/bash
set -euo pipefail
for ((i=0; i<60; i++)); do
    if xdpyinfo >/dev/null 2>&1; then
        exec dbus-run-session -- bash -c '
            openbox &
            /usr/lib/tsinclient/TSINClient --no-sandbox >>/var/log/wukong/gui.log 2>&1 &
            exec chromium --no-sandbox --disable-dev-shm-usage --no-first-run https://newtrust.arp.cn/
        '
    fi
    sleep 1
done
exit 1
