#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .secrets
chmod 700 .secrets
if [[ ! -s .secrets/vnc_password ]]; then
    (umask 077; openssl rand -hex 4 > .secrets/vnc_password)
fi
printf 'VNC password saved to .secrets/vnc_password\n'
