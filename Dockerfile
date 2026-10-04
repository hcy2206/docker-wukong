FROM debian:bookworm-slim AS vendor
ARG CLIENT_DEB=Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb
# Download and extract amd64 files with native tools; no amd64 build execution.
RUN dpkg --add-architecture amd64 \
    && apt-get update \
    && mkdir -p /tmp/amd64 /vendor \
    && cd /tmp/amd64 && apt-get download libc6:amd64 \
    && for package in *.deb; do dpkg-deb -x "$package" /vendor; done \
    && rm -rf /var/lib/apt/lists/* /tmp/amd64
COPY packages/${CLIENT_DEB} /tmp/client.deb
RUN echo '15d7cee09556f15090e8502e7db0633ee3accac56d44b447e9ff6bd96df58bed  /tmp/client.deb' | sha256sum -c - \
    && dpkg-deb -x /tmp/client.deb /vendor && rm /tmp/client.deb \
    && printf '%s\n' "$CLIENT_DEB" > /vendor/usr/lib/tsinclient/resources/extraResource/linux/config.json \
    && chmod +x /vendor/usr/lib/tsinclient/resources/extraResource/linux/tsinvc-linux
FROM debian:trixie-slim AS compat
RUN apt-get update && apt-get install -y --no-install-recommends qemu-user gcc-x86-64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*
COPY scripts/auxv-pagesize.c /tmp/auxv-pagesize.c
RUN x86_64-linux-gnu-gcc -shared -fPIC -nostdlib -O2 \
    -Wl,-z,max-page-size=16384 -Wl,-z,common-page-size=16384 \
    -o /tmp/auxv-pagesize.so /tmp/auxv-pagesize.c
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive DISPLAY=:1 LANG=zh_CN.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates python3 locales dbus dbus-x11 supervisor tini \
    tigervnc-standalone-server tigervnc-tools openbox xterm xauth x11-utils \
    chromium fonts-noto-cjk microsocks tinyproxy curl iproute2 iptables procps \
    libnss3-tools libgtk-3-0 libnotify4 libnss3 libxtst6 xdg-utils libatspi2.0-0 \
    libdrm2 libgbm1 libxcb-dri3-0 libglib2.0-bin libasound2 libsecret-1-0 \
    libxss1 libxkbfile1 libxshmfence1 libappindicator3-1 sudo psmisc net-tools ufw lsb-release \
    && sed -i 's/^# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen && rm -rf /var/lib/apt/lists/*
# Preserve vendor code; supply the amd64 backend with Debian glibc.
# Use the exact Electron version declared in the vendor package for native GUI.
COPY --from=vendor /vendor/usr/lib/tsinclient/ /usr/lib/tsinclient/
COPY --from=vendor /vendor/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/
COPY --from=vendor /vendor/lib64/ /usr/lib64/
COPY --from=compat /usr/bin/qemu-x86_64 /usr/local/bin/qemu-x86_64
COPY --from=compat /usr/share/doc/qemu-user/copyright /usr/share/doc/qemu-user/copyright
COPY --from=vendor /vendor/usr/share/doc/libc6/copyright /usr/share/doc/libc6-amd64/copyright
COPY --from=compat /tmp/auxv-pagesize.so /usr/local/lib/auxv-pagesize.so
COPY packages/electron-v22.3.2-linux-arm64.zip /tmp/electron-arm64.zip
RUN echo 'd9436201a8725d717819088df01512dae5b1b7daf7f94b9a9d1a8f27e0d8e830  /tmp/electron-arm64.zip' | sha256sum -c - \
    && python3 -c 'import zipfile; zipfile.ZipFile("/tmp/electron-arm64.zip").extractall("/opt/tsin-electron")' \
    && chmod +x /opt/tsin-electron/electron /opt/tsin-electron/chrome_crashpad_handler /opt/tsin-electron/chrome-sandbox \
    && mv /opt/tsin-electron/electron /opt/tsin-electron/TSINClient \
    && ln -s /usr/lib/tsinclient/resources/app /opt/tsin-electron/resources/app \
    && ln -s /usr/lib/tsinclient/resources/extraResource /opt/tsin-electron/resources/extraResource \
    && rm /tmp/electron-arm64.zip
RUN test "$(dpkg --print-architecture)" = arm64 \
    && ln -s /usr/lib64 /lib64 \
    && ln -s /opt/tsin-electron/TSINClient /usr/local/bin/TSINClient \
    && rm -f /etc/machine-id /var/lib/dbus/machine-id \
    && ln -s /var/lib/wukong/machine-id /etc/machine-id \
    && ln -s /etc/machine-id /var/lib/dbus/machine-id
COPY config/ /etc/wukong/
COPY scripts/entrypoint.sh scripts/desktop.sh scripts/wukong-browser /usr/local/bin/
COPY scripts/desktop-session.sh scripts/healthcheck.sh scripts/backend.sh /usr/local/bin/
COPY config/wukong-browser.desktop /usr/share/applications/wukong-browser.desktop
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/desktop.sh /usr/local/bin/wukong-browser \
    /usr/local/bin/desktop-session.sh /usr/local/bin/healthcheck.sh /usr/local/bin/backend.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=3 CMD /usr/local/bin/healthcheck.sh
EXPOSE 5901 1080 8888
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
