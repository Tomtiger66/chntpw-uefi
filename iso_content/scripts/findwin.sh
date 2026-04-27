#!/bin/sh

# Go through partitions and find windows on each
# (c) 2013-2014 Petter N Hagen
# NVMe support added 2025

WINPATH='./*/system32/config'

>/tmp/partitions
>/tmp/disks
>/tmp/pflist
>/tmp/pflistprint

# NVMe Module laden falls noch nicht geschehen
modprobe nvme 2>/dev/null
modprobe nvme-core 2>/dev/null
mdev -s 2>/dev/null

# Alle Partitionen aus /proc/partitions lesen
# Schliesst sr? fd? aus, nimmt alle die mit Zahl enden
# NVMe: nvme0n1p1 endet mit Zahl - wird korrekt erkannt
# NVMe Disks selbst: nvme0n1 endet NICHT mit p+Zahl als letztes - wird ausgeschlossen

tail -n +3 /proc/partitions | awk 'BEGIN { n=1; }
  !/(sr|fd)[0-9]$/ && /[0-9]$/ {
    # NVMe Disk selbst (nvme0n1) ausschliessen, nur Partitionen (nvme0n1p1)
    if ($4 ~ /^nvme/ && $4 !~ /p[0-9]+$/) next;
    if ($3 > 10000) printf("%d %s %i %i %i\n", n++, $4, $3, $3/1024/1024, $3/1024);
  }
' >/tmp/partitions

echo "n device bytes   GB  MB === DISK PARTITIONS:"
echo
cat /tmp/partitions
echo

# Jede Partition versuchen zu mounten und Windows suchen
n=1
while read num dev size gb mb; do
    prt="/dev/${dev}"
    echo -n "$mb MB partition $dev "

    # Erst ntfs3 (Kernel-Treiber) versuchen, dann vfat
    if mount -t ntfs3 ${prt} /disk -o ro,noatime 2>/dev/null; then
        ntfs=1
        vfat=0
        echo -n "is NTFS."
    elif mount -t vfat ${prt} /disk -o ro,noatime 2>/dev/null; then
        ntfs=0
        vfat=1
        echo -n "is FAT."
    else
        echo " failed to mount"
        continue
    fi

    # Windows-Registry suchen
    cd /disk
    find . -maxdepth 3 -ipath "$WINPATH" | sed 's/\.\///' >/tmp/fpath
    if [ -s /tmp/fpath ]; then
        echo -n " Found windows on: "
        cat /tmp/fpath
        echo /dev/${dev} $ntfs $vfat `cat /tmp/fpath` >>/tmp/pflist
        printf "%2d %-8s %10dMB %s\n" $((n++)) $dev $mb `cat /tmp/fpath` >>/tmp/pflistprint
    else
        echo " No windows there"
    fi
    cd /
    umount /disk 2>/dev/null

done </tmp/partitions

echo
