#!/bin/sh
# Statische Pruefung des Projekts (laeuft ueberall, auch ohne Debian).
# Aufruf: sh check.sh [Datei mit allen Debian-Paketnamen, eine je Zeile]
cd "$(dirname "$0")" || exit 1
R=config/includes.chroot
fail=0

for f in build.sh auto/config auto/build auto/clean config/hooks/normal/*.hook.chroot \
         "$R"/usr/local/sbin/* "$R"/usr/local/bin/* "$R"/etc/xdg/labwc/autostart; do
    if sh -n "$f"; then echo "sh ok    $f"; else fail=1; fi
done

if grep -rlI "$(printf '\r')" . --exclude-dir=.git >/dev/null 2>&1; then
    echo "FEHLER: Dateien mit Windows-Zeilenenden:"
    grep -rlI "$(printf '\r')" . --exclude-dir=.git
    fail=1
else
    echo "LF ok    keine Windows-Zeilenenden"
fi

if [ -n "${1:-}" ]; then
    for p in $(cat config/package-lists/*.list.chroot | grep -v '^#'); do
        grep -qx "$p" "$1" || { echo "FEHLER: Paket fehlt in Debian: $p"; fail=1; }
    done
    echo "Pakete   $(cat config/package-lists/*.list.chroot | grep -vc '^#\|^$') geprueft"
fi

exit $fail
