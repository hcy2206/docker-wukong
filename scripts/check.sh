#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose config --quiet
docker compose exec -T wukong bash -c '
    test -s /etc/machine-id
    test -c /dev/net/tun
    xdpyinfo >/dev/null
    for process in tsinvc-linux TSINClient chromium microsocks tinyproxy; do
        pgrep -x "$process" >/dev/null || exit 1
    done
    test "$(xdg-mime query default x-scheme-handler/https)" = wukong-browser.desktop
'
curl --fail --silent --show-error --max-time 25 --proxy socks5h://127.0.0.1:1081 https://portal.arp.cn/ -o /dev/null -w 'SOCKS5: HTTP %{http_code}\n'
curl --fail --silent --show-error --max-time 25 --proxy http://127.0.0.1:8889 https://portal.arp.cn/ -o /dev/null -w 'HTTP proxy: HTTP %{http_code}\n'
printf '基础检查通过；登录与内网访问需要另行验证。\n'
