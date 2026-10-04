#!/bin/bash
set -euo pipefail
mkdir -p /var/lib/wukong /run/dbus /root/.vnc /var/log/wukong
if [[ ! -s /var/lib/wukong/machine-id ]]; then
    dbus-uuidgen > /var/lib/wukong/machine-id
fi
if [[ ! -s /run/secrets/vnc_password ]]; then
    echo 'Missing VNC password: run ./scripts/setup.sh first.' >&2
    exit 1
fi
# Official ARP UOS download filename carries the public enrollment configuration.
# The newer Kylin package has no @-encoded configuration of its own.
client_config=/usr/lib/tsinclient/resources/extraResource/linux/config.json
if ! grep -q '@' "$client_config"; then
    cp /etc/wukong/arp-provisioning.txt "$client_config"
fi
xdg-mime default wukong-browser.desktop x-scheme-handler/http x-scheme-handler/https text/html
export BROWSER=/usr/local/bin/wukong-browser
umask 077
vncpasswd -f < /run/secrets/vnc_password > /root/.vnc/passwd
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 /run/dbus/pid
exec supervisord -n -c /etc/wukong/supervisord.conf
