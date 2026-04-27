#!/bin/bash
# Build-Script für chntpw-UEFI-Resurrection ISO
# Basiert auf Alpine Mini Root FS + Petters Skripte

set -e

PROJECTDIR="$HOME/Nextcloud/Public/It-Projekte/Git-Projekte/chntpwd"
ISOROOT="$PROJECTDIR/iso_content"
WORKDIR="/tmp/chntpw_build"
ISO_NAME="$HOME/chntpw-universal-rescue.iso"
KERNEL=$(ls $ISOROOT/boot/vmlinuz-lts 2>/dev/null || ls $ISOROOT/boot/vmlinuz* | head -1)
INITRD=$(ls $ISOROOT/boot/initramfs-lts 2>/dev/null || ls $ISOROOT/boot/initramfs* | head -1)

echo "================================================"
echo " chntpw UEFI Rescue ISO Builder"
echo "================================================"

# Arbeitsverzeichnis vorbereiten
rm -rf $WORKDIR
mkdir -p $WORKDIR/iso

# Kernel und initrd kopieren
mkdir -p $WORKDIR/iso/boot/grub
cp $KERNEL $WORKDIR/iso/boot/vmlinuz
cp $INITRD $WORKDIR/iso/boot/initramfs

# Skripte ins ISO-Root kopieren
mkdir -p $WORKDIR/iso/scripts
cp $ISOROOT/scripts/*.sh $WORKDIR/iso/scripts/
cp $ISOROOT/scripts/stage2 $WORKDIR/iso/scripts/ 2>/dev/null || true
cp $ISOROOT/scripts/banner1 $WORKDIR/iso/scripts/ 2>/dev/null || true
cp $ISOROOT/scripts/caseglob.awk $WORKDIR/iso/scripts/ 2>/dev/null || true
chmod +x $WORKDIR/iso/scripts/*.sh

# GRUB Konfiguration (Legacy + UEFI)
cat > $WORKDIR/iso/boot/grub/grub.cfg << 'EOF'
set default=0
set timeout=5

menuentry "chntpw - Windows Password Reset" {
    linux /boot/vmlinuz quiet
    initrd /boot/initramfs
}
EOF

# ISO bauen (Hybrid: Legacy BIOS + UEFI)
echo "Baue ISO..."
grub-mkrescue -o $ISO_NAME $WORKDIR/iso \
    --modules="linux normal iso9660 biosdisk search" \
    -- -volid "CHNT_RESCUE" -joliet -rock

echo ""
echo "================================================"
echo " FERTIG: $ISO_NAME"
echo " Auf Stick schreiben mit:"
echo " sudo dd if=$ISO_NAME of=/dev/sdX bs=4M status=progress"
echo "================================================"
