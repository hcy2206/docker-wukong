#!/bin/bash
set -euo pipefail
ulimit -c 0
openbox &
wm_pid=$!
/opt/tsin-electron/TSINClient --no-sandbox --disable-gpu --disable-dev-shm-usage >>/var/log/wukong/gui.log 2>&1 &
gui_pid=$!
chromium --no-sandbox --disable-dev-shm-usage --no-first-run https://newtrust.arp.cn/ &
browser_pid=$!
# Called indirectly by the EXIT trap.
# shellcheck disable=SC2317
cleanup() {
    kill "$gui_pid" "$browser_pid" "$wm_pid" 2>/dev/null || true
    wait || true
}
trap cleanup EXIT
trap 'exit 0' INT TERM
# Restart the desktop group if either application terminates; reap exited GUI.
wait -n "$gui_pid" "$browser_pid"
exit 1
