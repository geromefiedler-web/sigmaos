# Sigma OS 0.1

Schnelle, schlanke Linux-Distribution auf Basis von Debian 13 „trixie" (amd64).
Dieses Verzeichnis ist ein vollständiges live-build-Projekt: daraus entsteht ein
bootfähiges Live-ISO mit Installer.

**Stand:** Projekt statisch geprüft (Shell-Syntax, Paketnamen gegen den
Debian-13-Index, XML/TOML). Das ISO wurde noch **nicht** gebaut und gebootet.

## Bauen

Der Bau braucht Linux (Debian 13), root-Rechte, Internet und ca. 15 GB freien Platz.

### Weg A: GitHub Actions (kein Linux nötig)

1. Dieses Verzeichnis in ein GitHub-Repository hochladen.
2. Im Repository: **Actions → „Sigma OS ISO bauen" → Run workflow**.
3. Nach ca. 30–45 Minuten das Artefakt `sigma-os-iso` herunterladen.

### Weg B: Debian 13 (echt, VM oder WSL)

```sh
sudo apt-get install -y live-build
sudo sh build.sh
```

Ergebnis: `sigma-os-0.1-amd64.hybrid.iso` und `SHA256SUMS`.

### Weg C: Docker

```sh
docker run --rm --privileged -v "$PWD":/src -w /src debian:trixie \
  sh -c "apt-get update && apt-get install -y --no-install-recommends live-build ca-certificates && sh build.sh"
```

## Testen

```sh
qemu-system-x86_64 -enable-kvm -m 2048 -smp 2 -cdrom sigma-os-0.1-amd64.hybrid.iso
```

Im Live-System: Benutzer `sigma`, Passwort `live`. Danach im Terminal `sigma-bench`
ausführen und die Werte mit den Zielen unten vergleichen.

## Architektur

| Schicht | Wahl | Grund |
|---|---|---|
| Basis | Debian 13, minbase, ohne Recommends | Stabilität, Sicherheitsupdates direkt von Debian |
| Kernel | Debian 6.12 mit `preempt=full` | signiert (Secure Boot), geringe UI-Latenz |
| Init | systemd, reduziert | volle Paketkompatibilität, paralleler Boot |
| Speicher | zram (zstd), earlyoom, THP=madvise | flüssig ab 2 GB RAM |
| Sitzung | labwc (Wayland) + lxqt-panel | sehr leicht, kein Tearing |
| Login | greetd + tuigreet | wenige MB, startet sofort |
| Netzwerk | NetworkManager + iwd + dnsmasq-Cache | schnelles WLAN, lokaler DNS-Cache |
| Audio | PipeWire + WirePlumber | Standard, geringe Latenz |
| Apps | Firefox ESR, pcmanfm-qt, qterminal, featherpad, mpv | leicht, eine Toolkit-Familie (Qt) |
| Installer | Calamares | grafisch, Qt |

Abweichung vom ursprünglichen Plan: Debian 13 enthält kein `lxqt-wayland-session`.
Deshalb startet labwc direkt und lädt die LXQt-Komponenten selbst
(`/etc/xdg/labwc/autostart`). Das spart zusätzlich RAM.

## Ziele und Messung

| Ziel | Messung |
|---|---|
| Boot unter 8 s (SSD, ohne Firmware) | `systemd-analyze` |
| Leerlauf unter 400 MB RAM | `free -m`, 60 s nach Login, Spalte „used" |
| Installation unter 4 GB | `df -h /` |
| I/O | `fio --name=t --rw=randread --bs=4k --size=1G --direct=1 --runtime=30` |
| CPU | `sysbench cpu run` |

Vergleichswert: dieselben Befehle auf einem Standard-Debian-13 mit LXQt auf derselben Hardware.

## Tuning-Dateien

Alle liegen unter `config/includes.chroot/` und lassen sich einzeln löschen.

| Datei | Wirkung | Risiko |
|---|---|---|
| `etc/sysctl.d/90-sigma.conf` | zram-optimiertes Swapping, BBR, kleinere Schreibpuffer | gering |
| `etc/systemd/zram-generator.conf` | komprimierter Swap im RAM | kein Ruhezustand auf Platte |
| `etc/udev/rules.d/60-sigma-io.rules` | I/O-Scheduler je Gerätetyp | gering |
| `etc/default/grub.d/sigma.cfg` | verstecktes Boot-Menü, `preempt=full` | Menü nur mit Shift/Esc |
| `etc/tmpfiles.d/sigma-thp.conf` | Hugepages nur auf Anforderung | gering |
| `etc/default/earlyoom` | beendet Browser-Tabs vor dem Einfrieren | Tab-Inhalt geht verloren |
| `etc/systemd/journald.conf.d/sigma.conf` | Journal höchstens 50 MB | kürzere Log-Historie |
| `etc/NetworkManager/conf.d/sigma.conf` | iwd + DNS-Cache | iwd bei exotischem WLAN weniger erprobt |
| `usr/local/sbin/sigma-hostonly-initramfs` | kleines initramfs (manuell, nach Installation) | Platte nicht mehr in fremdem PC bootbar |

Sicherheits-Mitigations (Spectre/Meltdown) bleiben eingeschaltet.

## Bewusst nicht enthalten

Bluetooth, Drucken (CUPS), Office, Plymouth-Splash, Flatpak/Snap, proprietäre
NVIDIA-Treiber, X11-Desktop. Alles lässt sich mit `apt install` nachrüsten.

## Bekannte offene Punkte

- Calamares zeigt noch Debian-Branding und holt GRUB beim Installieren aus dem Netz
  (Internetverbindung nötig). Der Installer ist ungetestet.
- Das Boot-Menü des ISO ist das Standardmenü von live-build.
- Tastenkürzel: Super+Enter Terminal, Super+Leertaste Programmsuche, Super+E Dateien,
  Super+B Browser, Super+L Sperren, Druck Bildschirmfoto.

## Roadmap

- **0.1** – ISO baut, bootet in QEMU und auf echter Hardware, Messwerte dokumentiert.
- **0.2** – eigenes Calamares-Branding, Offline-Installation, eigenes APT-Repo mit
  `sigma-tuning`/`sigma-desktop`-Paketen, GRUB-Thema.
- **0.3** – optionaler XanMod-Kernel, Btrfs-Snapshots, NVIDIA-Variante.
