#!/bin/sh
# Baut das Sigma-OS-ISO. Auf Debian 13 (oder in einem debian:trixie-Container) als root ausfuehren:
#   apt-get install -y live-build
#   sh build.sh
set -eu
cd "$(dirname "$0")"

if [ "$(id -u)" -ne 0 ]; then
    echo "Bitte als root ausfuehren (sudo sh build.sh)." >&2
    exit 1
fi
if ! command -v lb >/dev/null 2>&1; then
    echo "live-build fehlt: apt-get install -y live-build" >&2
    exit 1
fi

# Dateirechte gehen unter Windows/Git verloren - hier wiederherstellen.
chmod +x auto/config auto/build auto/clean
chmod +x config/hooks/normal/*.hook.chroot
chmod +x config/includes.chroot/usr/local/sbin/* config/includes.chroot/usr/local/bin/*

lb clean
lb config
lb build

sha256sum sigma-os-*.iso > SHA256SUMS
ls -lh sigma-os-*.iso
