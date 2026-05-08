#!/bin/bash
# Build-Script für chntpw-UEFI-Resurrection ISO
# Echte Hybrid-ISO: Legacy BIOS + UEFI
# Basiert auf Alpine Mini Root FS + Petters Skripte

set -e

PROJECTDIR="$HOME/Nextcloud/Public/It-Projekte/Git-Projekte/chntpwd"
ISOROOT="$PROJECTDIR/iso_content"
WORKDIR="/tmp/chntpw_build"
INITRD_WORK="$WORKDIR/initrd"
ISO_NAME="$HOME/chntpw-universal-rescue.iso"

echo "================================================"
echo " chntpw UEFI+BIOS Rescue ISO Builder"
echo "================================================"

rm -rf $WORKDIR
mkdir -p $WORKDIR/iso/boot/grub
mkdir -p $INITRD_WORK

# ------------------------------------------------
# SCHRITT 1: initramfs entpacken
# Das Alpine Mini Root FS enthält bereits alle
# grundlegenden Tools (busybox, apk etc.)
# ------------------------------------------------
echo ">> Entpacke initramfs..."
cd $INITRD_WORK
zcat $ISOROOT/boot/initramfs-lts | cpio -idm 2>/dev/null

# ------------------------------------------------
# SCHRITT 2: Alles Überflüssige entfernen
# Das Alpine init-System wird komplett ersetzt
# durch unser eigenes schlankes /init Script
# ------------------------------------------------
echo ">> Bereinige initramfs..."
rm -f $INITRD_WORK/init
rm -rf $INITRD_WORK/etc/init.d
rm -rf $INITRD_WORK/etc/runlevels
rm -rf $INITRD_WORK/etc/conf.d
rm -rf $INITRD_WORK/.modloop
rm -f $INITRD_WORK/sbin/nlplug-findfs
rm -f $INITRD_WORK/usr/sbin/udhcpc 2>/dev/null || true

# ------------------------------------------------
# SCHRITT 3: Unsere Skripte einbauen
# Alle Petter-Skripte plus unsere Anpassungen
# ------------------------------------------------
echo ">> Baue Skripte ein..."
mkdir -p $INITRD_WORK/scripts
mkdir -p $INITRD_WORK/disk
mkdir -p $INITRD_WORK/tmp
mkdir -p $INITRD_WORK/removable

cp $ISOROOT/scripts/*.sh $INITRD_WORK/scripts/
cp $ISOROOT/scripts/stage2 $INITRD_WORK/scripts/ 2>/dev/null || true
cp $ISOROOT/scripts/banner1 $INITRD_WORK/scripts/ 2>/dev/null || true
cp $ISOROOT/scripts/caseglob.awk $INITRD_WORK/scripts/ 2>/dev/null || true
chmod +x $INITRD_WORK/scripts/*.sh

# ------------------------------------------------
# SCHRITT 3b: Kernel-Module kopieren
# Nur die wirklich benötigten Module werden
# ins initramfs kopiert um es klein zu halten
# ------------------------------------------------
echo ">> Kopiere Kernel-Module..."
KVER=$(ls $ISOROOT/lib/modules/)

# NTFS3 - moderner Kernel-integrierter NTFS Treiber
# Schnell und stabil für Windows 7/8/10/11
mkdir -p $INITRD_WORK/lib/modules/$KVER/kernel/fs/ntfs3
cp $ISOROOT/lib/modules/$KVER/kernel/fs/ntfs3/ntfs3.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/fs/ntfs3/ 2>/dev/null || true

# FAT/VFAT - für FAT32 Partitionen
# Wird für EFI-Partitionen und USB-Sticks benötigt
mkdir -p $INITRD_WORK/lib/modules/$KVER/kernel/fs/fat
cp $ISOROOT/lib/modules/$KVER/kernel/fs/fat/*.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/fs/fat/ 2>/dev/null || true

# AHCI/SATA - für SATA Festplatten und SSDs
# Benötigt für alle nicht-NVMe Festplatten
mkdir -p $INITRD_WORK/lib/modules/$KVER/kernel/drivers/ata
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/ata/ahci.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/ata/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/ata/libahci.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/ata/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/ata/libata.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/ata/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/ata/ata_piix.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/ata/ 2>/dev/null || true

# USB Controller Module (xHCI für USB 3.0)
# Ohne diese Module werden USB-Geräte nicht erkannt!
mkdir -p $INITRD_WORK/lib/modules/$KVER/kernel/drivers/usb/host
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/usb/host/xhci-hcd.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/usb/host/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/usb/host/xhci-pci.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/usb/host/ 2>/dev/null || true

# HID Module für USB-Tastaturen, Mäuse und
# USB-Funk-Empfänger (z.B. Maxxter, Logitech etc.)
# hid.ko         = HID Framework (Basis für alle HID-Geräte)
# hid-generic.ko = Generische USB HID Geräte (die meisten Empfänger)
# usbhid.ko      = USB HID Treiber
# hid-logitech-dj    = Logitech Unifying Empfänger
# hid-logitech-hidpp = Logitech HID++ Protokoll
mkdir -p $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid
mkdir -p $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid/usbhid
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/hid/hid.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/hid/hid-generic.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/hid/hid-logitech-dj.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/hid/hid-logitech-hidpp.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/kernel/drivers/hid/usbhid/usbhid.ko.gz \
   $INITRD_WORK/lib/modules/$KVER/kernel/drivers/hid/usbhid/ 2>/dev/null || true

# modules.dep und modules.alias für modprobe
# modprobe braucht diese Dateien um Module zu finden
cp $ISOROOT/lib/modules/$KVER/modules.dep \
   $INITRD_WORK/lib/modules/$KVER/ 2>/dev/null || true
cp $ISOROOT/lib/modules/$KVER/modules.alias \
   $INITRD_WORK/lib/modules/$KVER/ 2>/dev/null || true

# ------------------------------------------------
# SCHRITT 3c: Tastatur-Support kopieren
# loadkeys lädt das Tastaturlayout
# de.map.gz = Deutsche QWERTZ Tastatur
# us.map.gz = Englische QWERTY Tastatur
# ------------------------------------------------
echo ">> Kopiere Tastatur-Tools..."
mkdir -p $INITRD_WORK/usr/bin
cp $ISOROOT/usr/bin/loadkeys $INITRD_WORK/usr/bin/ 2>/dev/null || true
mkdir -p $INITRD_WORK/usr/share/keymaps/xkb
cp $ISOROOT/usr/share/keymaps/xkb/de.map.gz \
   $INITRD_WORK/usr/share/keymaps/xkb/ 2>/dev/null || true
cp $ISOROOT/usr/share/keymaps/xkb/us.map.gz \
   $INITRD_WORK/usr/share/keymaps/xkb/ 2>/dev/null || true

# ------------------------------------------------
# SCHRITT 3d: chntpw und Tools kopieren
# chntpw  = Das Herzstück - ändert Windows Registry
# cpnt    = Wird von write.sh zum Schreiben benötigt
# ntfsfix = Prüft und repariert NTFS Partitionen
# libntfs = Bibliothek für NTFS-Operationen
# ------------------------------------------------
echo ">> Kopiere chntpw und Tools..."
cp $ISOROOT/usr/bin/chntpw $INITRD_WORK/usr/bin/ 2>/dev/null || true
cp $ISOROOT/usr/bin/cpnt $INITRD_WORK/usr/bin/ 2>/dev/null || true
cp $ISOROOT/usr/bin/ntfsfix $INITRD_WORK/usr/bin/ 2>/dev/null || true
mkdir -p $INITRD_WORK/usr/lib
cp $ISOROOT/usr/lib/libntfs-3g.so* $INITRD_WORK/usr/lib/ 2>/dev/null || true

# ------------------------------------------------
# SCHRITT 4: Unser eigenes /init einsetzen
# Das Alpine /init wird durch unser schlankes
# Script ersetzt das nur das Nötigste tut
# ------------------------------------------------
echo ">> Erstelle /init..."
cat > $INITRD_WORK/init << 'INITEOF'
#!/bin/sh

# Busybox installieren damit alle Befehle verfügbar sind
# Busybox ist eine einzelne Binary die viele Linux-Tools
# enthält (ls, cat, mount, etc.) - sehr platzsparend
/bin/busybox --install -s /bin
/bin/busybox --install -s /sbin
/bin/busybox --install -s /usr/bin
/bin/busybox --install -s /usr/sbin

# Grundlegende Dateisysteme mounten
# Diese sind für den Kernel-Betrieb zwingend nötig
mount -t proc proc /proc        # Prozess-Informationen
mount -t sysfs sys /sys         # Hardware-Informationen
mount -t devtmpfs dev /dev      # Geräte-Dateien
mount -t devpts devpts /dev/pts 2>/dev/null  # Terminal-Geräte

# PATH setzen damit alle Befehle gefunden werden
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Wichtige Verzeichnisse anlegen
mkdir -p /tmp /disk /removable

# Kernelmeldungen reduzieren sobald Boot abgeschlossen
# 3 = nur Fehler werden angezeigt (war 7 = alles)
echo 3 > /proc/sys/kernel/printk

# USB Controller laden (zuerst! damit USB-Geräte erkannt werden)
# xhci = USB 3.0 Controller (auch für USB 2.0 Geräte an USB 3.0 Ports)
modprobe xhci_hcd 2>/dev/null
modprobe xhci_pci 2>/dev/null

# NVMe Module laden
# Für moderne M.2 SSDs und NVMe Festplatten
modprobe nvme 2>/dev/null
modprobe nvme-core 2>/dev/null

# SATA/ATA für ältere Festplatten und SSDs
modprobe ahci 2>/dev/null
modprobe libahci 2>/dev/null
modprobe libata 2>/dev/null
modprobe ata_piix 2>/dev/null
modprobe sd_mod 2>/dev/null

# USB HID Module laden
# Reihenfolge wichtig: erst Framework dann Treiber!
# hid         = HID Framework (Basis für alle HID-Geräte)
# hid_generic = Generische HID Geräte
# usbhid      = USB Tastatur/Maus Treiber
# hid_logitech_dj    = Logitech Unifying Empfänger
# hid_logitech_hidpp = Logitech HID++ Protokoll
modprobe usb_storage 2>/dev/null
modprobe hid 2>/dev/null
modprobe hid_generic 2>/dev/null
modprobe usbhid 2>/dev/null
modprobe hid_logitech_dj 2>/dev/null
modprobe hid_logitech_hidpp 2>/dev/null

# NTFS Treiber laden
modprobe ntfs3 2>/dev/null
modprobe ntfs 2>/dev/null

# Warten damit alle Geräte sich initialisieren können
# Besonders USB-Funk-Empfänger brauchen etwas Zeit
sleep 3
mdev -s

# Unser Startskript aufrufen
exec /scripts/start.sh

# Falls start.sh fehlschlägt: Shell öffnen
# PID 1 darf nie enden sonst gibt es Kernel Panic!
exec /bin/sh
INITEOF
chmod +x $INITRD_WORK/init

# ------------------------------------------------
# SCHRITT 5: initramfs neu zusammenpacken
# ------------------------------------------------
echo ">> Packe initramfs neu zusammen..."
cd $INITRD_WORK
find . | cpio -H newc -o 2>/dev/null | gzip -9 > $WORKDIR/iso/boot/initramfs
echo ">> initramfs Größe: $(du -sh $WORKDIR/iso/boot/initramfs | cut -f1)"

# ------------------------------------------------
# SCHRITT 6: Kernel kopieren
# ------------------------------------------------
echo ">> Kopiere Kernel..."
cp $ISOROOT/boot/vmlinuz-lts $WORKDIR/iso/boot/vmlinuz
echo ">> Kernel Größe: $(du -sh $WORKDIR/iso/boot/vmlinuz | cut -f1)"

# ------------------------------------------------
# SCHRITT 7: GRUB Konfiguration erstellen
# Mit Grafikmodus für bessere Lesbarkeit auf
# modernen Monitoren mit hoher Auflösung.
# Fallback auf Textmodus wenn Font nicht gefunden.
# ------------------------------------------------
echo ">> Erstelle GRUB Konfiguration..."

# GRUB Font kopieren für gfxterm
# unicode.pf2 enthält alle Zeichen für die
# grafische Darstellung des GRUB-Menüs
mkdir -p $WORKDIR/iso/boot/grub/fonts
cp /usr/share/grub/unicode.pf2 \
   $WORKDIR/iso/boot/grub/fonts/ 2>/dev/null || true

cat > $WORKDIR/iso/boot/grub/grub.cfg << 'EOF'
set prefix=/boot/grub
set default=0
set timeout=10

# Grafik-Modus für bessere Lesbarkeit
# auf modernen Monitoren mit hoher Auflösung
# Fallback auf Textmodus wenn Font nicht vorhanden
insmod all_video
insmod gfxterm
insmod vbe
insmod vga
if loadfont /boot/grub/fonts/unicode.pf2 ; then
    set gfxmode=1024x768,800x600,auto
    terminal_output gfxterm
fi

menuentry "chntpw - Windows Passwort Reset (DE Tastatur)" {
    linux /boot/vmlinuz quiet
    initrd /boot/initramfs
}

menuentry "chntpw - Windows Password Reset (EN Keyboard)" {
    linux /boot/vmlinuz quiet
    initrd /boot/initramfs
}

menuentry "Shell only (debug)" {
    linux /boot/vmlinuz init=/bin/sh
    initrd /boot/initramfs
}

menuentry "Neustart / Reboot" {
    reboot
}

menuentry "Ausschalten / Shutdown" {
    halt
}
EOF

# ------------------------------------------------
# SCHRITT 8a: GRUB Legacy-BIOS Image erstellen
# ------------------------------------------------
echo ">> Erstelle GRUB Legacy-BIOS Image..."
grub-mkimage \
    --format=i386-pc \
    --output=$WORKDIR/core.img \
    --prefix=/boot/grub \
    linux iso9660 biosdisk

cat /usr/lib/grub/i386-pc/cdboot.img $WORKDIR/core.img \
    > $WORKDIR/bios.img
cp $WORKDIR/bios.img $WORKDIR/iso/boot/grub/bios.img

mkdir -p $WORKDIR/iso/boot/grub/i386-pc
cp /usr/lib/grub/i386-pc/*.mod \
   $WORKDIR/iso/boot/grub/i386-pc/ 2>/dev/null || true

# ------------------------------------------------
# SCHRITT 8b: GRUB UEFI Image erstellen
# ------------------------------------------------
echo ">> Erstelle GRUB UEFI Image..."
grub-mkimage \
    --format=x86_64-efi \
    --output=$WORKDIR/bootx64.efi \
    --prefix=/boot/grub \
    linux iso9660 search

mkdir -p $WORKDIR/efi/EFI/BOOT
cp $WORKDIR/bootx64.efi $WORKDIR/efi/EFI/BOOT/BOOTX64.EFI
dd if=/dev/zero of=$WORKDIR/efi.img bs=1M count=4 2>/dev/null
mkfs.fat -F12 $WORKDIR/efi.img >/dev/null
mkdir -p $WORKDIR/efi_mount
sudo mount $WORKDIR/efi.img $WORKDIR/efi_mount
sudo cp -r $WORKDIR/efi/EFI $WORKDIR/efi_mount/
sudo umount $WORKDIR/efi_mount
cp $WORKDIR/efi.img $WORKDIR/iso/boot/grub/efi.img

mkdir -p $WORKDIR/iso/EFI/BOOT
cp $WORKDIR/bootx64.efi $WORKDIR/iso/EFI/BOOT/BOOTX64.EFI

echo ">> Kopiere GRUB UEFI Module..."
mkdir -p $WORKDIR/iso/boot/grub/x86_64-efi
cp /usr/lib/grub/x86_64-efi/*.mod \
   $WORKDIR/iso/boot/grub/x86_64-efi/ 2>/dev/null || true

# ------------------------------------------------
# SCHRITT 8c: Finale Hybrid-ISO
# ------------------------------------------------
echo ">> Baue finale Hybrid-ISO (BIOS + UEFI)..."
xorriso -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "CHNT_RESCUE" \
    -eltorito-boot boot/grub/bios.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -append_partition 2 0xef $WORKDIR/efi.img \
    -o $ISO_NAME \
    -graft-points \
    $WORKDIR/iso \
    /boot/grub/bios.img=$WORKDIR/bios.img \
    /boot/grub/efi.img=$WORKDIR/efi.img

echo ""
echo "================================================"
echo " FERTIG: $ISO_NAME"
echo " Größe: $(du -sh $ISO_NAME | cut -f1)"
echo ""
echo " Prüfe ISO-Struktur:"
fdisk -l $ISO_NAME | grep -E "Typ|Type|Boot|EFI"
echo ""
echo " Auf Stick schreiben mit:"
echo " sudo dd if=$ISO_NAME of=/dev/sdX bs=4M status=progress"
echo "================================================"
