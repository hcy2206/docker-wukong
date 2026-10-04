#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
name='Wukong-v2.14.00051.1_ubuntu-kylinos_amd64.deb'
mkdir -p packages
curl --fail --location --retry 2 "https://portal.arp.cn/software/$name" -o "packages/$name.part"
checksum='15d7cee09556f15090e8502e7db0633ee3accac56d44b447e9ff6bd96df58bed'
if command -v sha256sum >/dev/null 2>&1; then
    printf '%s  %s\n' "$checksum" "packages/$name.part" | sha256sum -c -
elif command -v shasum >/dev/null 2>&1; then
    printf '%s  %s\n' "$checksum" "packages/$name.part" | shasum -a 256 -c -
else
    echo 'Install sha256sum or shasum to verify the client installer.' >&2
    exit 1
fi
mv "packages/$name.part" "packages/$name"
