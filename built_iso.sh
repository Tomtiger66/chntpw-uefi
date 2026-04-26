#!/bin/bash
# Build-Script für die chntpw-UEFI-Resurrection ISO (Final Precision Version)

WORKDIR="$HOME/chntpw_build"
ISO_NAME="chntpw-universal-rescue.iso"

# 1. Vorbereiten
rm -rf $WORKDIR
mkdir -p $WORKDIR/iso_content $WORKDIR/initrd_mod
cd $WORKDIR

# 2. Alpine ISO herunterladen (DEIN LINK!)
echo "Lade Alpine Linux Basis herunter..."
wget -O alpine.iso "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-standard-3.23.4-x86_64.iso" || { echo "Download fehlgeschlagen!"; exit 1; }

# 3. ISO entpacken
echo "Extrahiere ISO-Inhalt..."
xorriso -osirrox on -indev alpine.iso -extract / $WORKDIR/iso_content
chmod -R +w $WORKDIR/iso_content

# 4. Operation am offenen Herzen (initrd)
echo "Integriere Dateien in das System-Skelett..."
cd $WORKDIR/initrd_mod
zcat $WORKDIR/iso_content/boot/initramfs-lts | cpio -idm
# Wir nutzen /usr/local, das bleibt beim Systemwechsel erhalten
mkdir -p usr/local/bin usr/local/scripts lib/keymaps

# Kopieren an den sicheren Ort
cp ~/Dokumente/Chntpasswd/initrd_content/bin/chntpw ./usr/local/bin/chntpw
cp -r ~/Dokumente/Chntpasswd/initrd_content/scripts/* ./usr/local/scripts/
chmod +x ./usr/local/bin/chntpw ./usr/local/scripts/*.sh
# Autostart über die 'init' erzwingen (da inittab nicht da ist)
# Wir hängen den Startbefehl direkt in die 'init' Datei,
# aber wir nutzen den vollen Pfad zu deinem neuen Ort.
sed -i '2i sh /usr/local/scripts/start.sh' init

# KEYMAPS INTEGRIEREN (Damit loadkeys de/us funktioniert)
echo "Hole Tastatur-Layouts aus den Paketen..."
KBD_APK=$(find $WORKDIR/iso_content/apks/ -name "kbd-keymaps*.apk")
if [ -n "$KBD_APK" ]; then
    # Wir entpacken nur de und us Layouts direkt in unsere neue initrd-Struktur
    tar -xf "$KBD_APK" -C $WORKDIR/initrd_mod usr/share/keymaps/i386/qwertz/de.map.gz 2>/dev/null
    tar -xf "$KBD_APK" -C $WORKDIR/initrd_mod usr/share/keymaps/i386/qwerty/us.map.gz 2>/dev/null
    # Wir schieben sie an einen Ort, den loadkeys leicht findet
    mv usr/share/keymaps/i386/qwertz/de.map.gz ./lib/keymaps/ 2>/dev/null
    mv usr/share/keymaps/i386/qwerty/us.map.gz ./lib/keymaps/ 2>/dev/null
fi

# Wir legen das Script NICHT in die init, sondern in das Profil
# Sobald das System fertig ist und dich als root einloggt, startet es
# mkdir -p etc/profile.d
# echo "sh /scripts/start.sh" > etc/profile.d/chntpw.sh
# chmod +x etc/profile.d/chntpw.sh

# Wir stellen sicher, dass Alpine sich automatisch als root einloggt
# (Sonst müsste dein Schwiegervater erst 'root' tippen)
# wird rausgenommen, da keine inittab vorhanden| sed -i 's|getty 38400 tty1|getty -a root 38400 tty1|' etc/inittab

# 5. Alles wieder zusammenpacken
echo "Versiegele die modifizierte initrd..."
find . | cpio -H newc -o | gzip -9n > $WORKDIR/iso_content/boot/initramfs-lts

# 6. Finale Hybrid-ISO bauen
echo "Baue finale Hybrid-ISO..."
cd $WORKDIR
xorrisofs -o ~/$ISO_NAME \
    -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin \
    -c boot/syslinux/boot.cat -b boot/syslinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
    -isohybrid-gpt-basdat \
    -volid "CHNT_UEFI" -joliet -rock $WORKDIR/iso_content

echo "-----------------------------------------------------"
echo "FERTIG! Teste die ISO jetzt am Matebook oder Acer."
