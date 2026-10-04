FROM debian:bookworm-slim
ARG CLIENT_DEB=Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb
ENV DEBIAN_FRONTEND=noninteractive DISPLAY=:1 LANG=zh_CN.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates locales dbus dbus-x11 supervisor tini \
    tigervnc-standalone-server tigervnc-tools openbox xterm xauth x11-utils \
    chromium fonts-noto-cjk microsocks tinyproxy curl iproute2 iptables procps \
    libnss3-tools libgtk-3-0 libnotify4 libnss3 libxtst6 xdg-utils libatspi2.0-0 \
    libdrm2 libgbm1 libxcb-dri3-0 libglib2.0-bin libasound2 libsecret-1-0 \
    libxss1 libxkbfile1 libxshmfence1 libappindicator3-1 sudo psmisc net-tools ufw lsb-release \
    && sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen && rm -rf /var/lib/apt/lists/*
COPY packages/${CLIENT_DEB} /tmp/client.deb
# Extract only: vendor postinst starts systemd and guesses the installer filename.
# Reproduce its relevant setup explicitly; launch the documented foreground daemon.
RUN test "$(dpkg --print-architecture)" = amd64 \
    && echo '15d7cee09556f15090e8502e7db0633ee3accac56d44b447e9ff6bd96df58bed  /tmp/client.deb' | sha256sum -c - \
    && dpkg-deb -x /tmp/client.deb / && rm /tmp/client.deb \
    && printf '%s\n' "$CLIENT_DEB" > /usr/lib/tsinclient/resources/extraResource/linux/config.json \
    && chmod +x /usr/lib/tsinclient/resources/extraResource/linux/tsinvc-linux \
    && ln -s /usr/lib/tsinclient/TSINClient /usr/local/bin/TSINClient \
    && rm -f /etc/machine-id /var/lib/dbus/machine-id \
    && ln -s /var/lib/wukong/machine-id /etc/machine-id \
    && ln -s /etc/machine-id /var/lib/dbus/machine-id
COPY config/ /etc/wukong/
COPY scripts/entrypoint.sh scripts/desktop.sh scripts/wukong-browser /usr/local/bin/
COPY config/wukong-browser.desktop /usr/share/applications/wukong-browser.desktop
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/desktop.sh /usr/local/bin/wukong-browser
EXPOSE 5901 1080 8888
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
