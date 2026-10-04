#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
url="${1:-https://portal.arp.cn/}"
docker compose config --quiet
docker compose exec -T wukong /usr/local/bin/healthcheck.sh
docker compose exec -T wukong bash -c 'test "$(xdg-mime query default x-scheme-handler/https)" = wukong-browser.desktop'
socks_address=$(docker compose port wukong 1080)
http_address=$(docker compose port wukong 8888)
# A wildcard listener must be reached through a concrete local address.
socks_address=${socks_address/0.0.0.0:/127.0.0.1:}
http_address=${http_address/0.0.0.0:/127.0.0.1:}
curl --fail --silent --show-error --max-time 25 --proxy "socks5h://$socks_address" "$url" -o /dev/null -w 'SOCKS5: HTTP %{http_code}\n'
curl --fail --silent --show-error --max-time 25 --proxy "http://$http_address" "$url" -o /dev/null -w 'HTTP proxy: HTTP %{http_code}\n'
printf '进程和指定 URL 的代理检查通过；业务登录状态需另行确认。\n'
