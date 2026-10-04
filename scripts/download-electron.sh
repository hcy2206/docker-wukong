#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
name='electron-v22.3.2-linux-arm64.zip'
mkdir -p packages
curl --fail --location --retry 2 "https://github.com/electron/electron/releases/download/v22.3.2/$name" -o "packages/$name.part"
checksum='d9436201a8725d717819088df01512dae5b1b7daf7f94b9a9d1a8f27e0d8e830'
if command -v sha256sum >/dev/null 2>&1; then
    printf '%s  %s\n' "$checksum" "packages/$name.part" | sha256sum -c -
elif command -v shasum >/dev/null 2>&1; then
    printf '%s  %s\n' "$checksum" "packages/$name.part" | shasum -a 256 -c -
else
    echo 'Install sha256sum or shasum to verify the Electron archive.' >&2
    exit 1
fi
mv "packages/$name.part" "packages/$name"
