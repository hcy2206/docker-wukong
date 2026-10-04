#!/bin/bash
set -euo pipefail
for ((i=0; i<60; i++)); do
    if xdpyinfo >/dev/null 2>&1; then
        exec dbus-run-session -- /usr/local/bin/desktop-session.sh
    fi
    sleep 1
done
exit 1
