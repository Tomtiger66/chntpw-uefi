#!/bin/sh

# Enumerate disks
# chntpw boot image support script
# (c) 2004-2013 Petter N Hagen
# NVMe support added 2025

# NVMe Module laden
modprobe nvme 2>/dev/null
modprobe nvme-core 2>/dev/null

mdev -s

>/tmp/removables
>/tmp/ntparts2
>/tmp/remparts

# Hilfsfunktion: Disk-Name aus Partition extrahieren
# Funktioniert fuer sda1->sda UND nvme0n1p1->nvme0n1
get_disk() {
    case $1 in
        *nvme*) echo $(basename $1) | sed 's/p[0-9]*$//' ;;
        *)      echo $(basename $1) | sed 's/[0-9]*$//' ;;
    esac
}

# CCISS (HP/Compaq DL scsi)
ls /dev | grep -q cciss && CCISS='/dev/cciss!c?d?'

# Alle relevanten Disk-Typen sammeln
DEVS="$CCISS"
for dev in /dev/sd? /dev/hd? /dev/nvme?n?; do
    [ -b "$dev" ] && DEVS="$DEVS $dev"
done

# Partitionen finden
fdisk -l $DEVS 2>/dev/null | grep '^Disk' >/tmp/disks
fdisk -l $DEVS 2>/dev/null | grep '^/dev' >/tmp/partitions
fdisk -l $DEVS 2>/dev/null | grep '^/dev' | egrep 'NTFS|FAT|SFS' | sed 's/Win95 //g' >/tmp/ntparts3

# Build disk info (top level)
{ while read a dev b; do
  d=$(get_disk $dev)
  d=`echo $d | sed 's/://g'`
  r=`cat /sys/block/$d/removable 2>/dev/null || echo 0`
  echo -n $a $dev $b >>/tmp/disks2
  if [ ${r}x = "1x" ]; then
     echo -n ", REMOVABLE" >>/tmp/disks2
     echo $d >>/tmp/removables
  fi
  echo >>/tmp/disks2
done } < /tmp/disks

mv /tmp/disks2 /tmp/disks >/dev/null 2>&1

# Build Windows partition info (NTFS, SFS, FAT etc)
{ while read dev b c; do
    d=$(get_disk $dev)
    r=`cat /sys/block/$d/removable 2>/dev/null || echo 0`
    echo -n "$dev $b $c" >>/tmp/ntparts2
    if [ "${b}x" = "*x" ]; then
       echo -n ", BOOT" >>/tmp/ntparts2
    fi
    if [ ${r}x = "1x" ]; then
       echo -n ", REMOVABLE (USB?)" >>/tmp/ntparts2
    fi
    echo >>/tmp/ntparts2
done } < /tmp/ntparts3

# Build removable partition list
{ while read dev b c; do
    d=$(get_disk $dev)
    r=`cat /sys/block/$d/removable 2>/dev/null || echo 0`
    if [ ${r}x = "1x" ]; then
      echo "$dev $b $c" >>/tmp/remparts
    fi
done } < /tmp/partitions

# Pretty print table
cat /tmp/ntparts2 | awk 'BEGIN{n=1;} {
  if ( ($6=="SFS" && $2=="1" && $3=="1") ) {
    prev=$1;
    shft=1;
  } else {
    dev=$1
    if (shft) dev=prev;
    printf("%2d : %20.20s  %6dMB %s%s%s%s%s\n",n++,dev,($2=="*"?$5/1024:$4/1024),$8,$9,$10,$11,$12,$13);
    prev=$1
  }
}' >/tmp/ntparts

# Removables
cat /tmp/remparts | awk 'BEGIN{n=1;} {
  printf("%2d : %20.20s  %6dMB %s%s%s%s%s\n",n++,$1,($2=="*"?$5/1024:$4/1024),$8,$9,$10,$11,$12,$13);
}' >/tmp/remparts2

# Partition mit Windows erraten (Win7+ hat 100MB Boot-Partition zuerst)
cat /tmp/ntparts2 | awk '
    BEGIN{ n=1; part=1; }
    {
        if ($2=="*") {
            size=$5/1024;
            if (size < 105 && size > 95) part=n+1;
        }
        n++;
    }
    END { print part; }
' >/tmp/partdefault
