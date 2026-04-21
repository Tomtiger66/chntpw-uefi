#!/bin/sh

# Modernisiertes findwin.sh für NVMe-SSDs und UEFI (2024)
# Sucht Windows-Partitionen auf klassischen (sda) und modernen (nvme) Platten

WINPATH='./*/system32/config'

# Temporäre Dateien leeren/erstellen
>/tmp/partitions
>/tmp/disks
>/tmp/pflist
>/tmp/pflistprint

# Verzeichnis für den Mount-Punkt sicherstellen
mkdir -p /disk

echo "Scanne Festplatten nach Partitionen..."

# Findet sda1, sdb2 sowie nvme0n1p3 etc.
# Filtert Loop-Devices, RAM-Disks und CD-ROMs aus.
tail -n +3 /proc/partitions | awk ' BEGIN { n=1; }
  $4 !~ /^(loop|ram|sr|fd|nbd)/ && $4 ~ /[0-9]$/ {
    # Partitionen > 10MB anzeigen: Nr, Device, Blocks, GB, MB
    if ($3 > 10000) printf("%d %s %i %i %i\n",n++,$4,$3,$3/1024/1024,$3/1024);
  }
' >/tmp/partitions

if [ ! -s /tmp/partitions ]; then
    echo "KEINE Partitionen gefunden! Hardware-Treiber Problem?"
    exit 1
fi

echo "n  Gerät    Größe (MB) === GEFUNDENE PARTITIONEN:"
cat /tmp/partitions | awk '{printf "%s  %-10s %s MB\n", $1, $2, $5}'
echo

# Jede Partition testen
n=1
while read num dev size gb mb; do
  prt="/dev/"${dev}
  echo -n "Prüfe $prt ($mb MB) ... "

  # Versuch zu mounten (NTFS oder FAT)
  # Wir nutzen hier 'mount', da moderne Systeme ntfs-3g automatisch einbinden
  if mount -o ro,noatime $prt /disk 2>/dev/null; then
    # Erfolg
    :
  else
    echo "kein erkanntes Dateisystem."
    continue
  fi

  # In der Partition nach dem Windows-Registry-Pfad suchen
  # Wir nutzen case-insensitive Suche für 'system32/config'
  curpath=$(find /disk -maxdepth 3 -ipath "$WINPATH" 2>/dev/null | head -n 1 | sed 's|/disk/||')

  if [ -n "$curpath" ]; then
    echo "GEFUNDEN!"
    echo "Windows-Systempfad: $curpath"

    # In Liste für das Hauptprogramm (main.sh) speichern
    echo "$prt 1 0 $curpath" >>/tmp/pflist
    printf "%2d %-12s %10dMB %s\n" $((n++)) $dev $mb "$curpath" >>/tmp/pflistprint
  else
    echo "kein Windows."
  fi

  umount /disk
done </tmp/partitions

echo
echo "Scan abgeschlossen."
