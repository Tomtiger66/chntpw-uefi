#!/bin/bash

# --- KONFIGURATION ---
ISO_NAME="chntpw-universal-rescue.iso"
ISO_PATH="$(dirname "$0")/$ISO_NAME"

# Findet den Ventoy-Ordner im aktuellen Verzeichnis
VENTOY_DIR=$(find . -maxdepth 1 -type d -name "*ventoy*" | head -n 1)

if [ -z "$VENTOY_DIR" ]; then
    echo "!! FEHLER: Kein Ventoy-Ordner in $(pwd) gefunden."
    exit 1
fi
# ---------------------

echo "=== Ventoy Linux Auto-Installer (Pfad: Iso-Ordner) ==="

if [ ! -f "$ISO_PATH" ]; then
    echo "!! FEHLER: ISO nicht gefunden unter $ISO_PATH"
    exit 1
fi

# USB-Stick finden
USB_DEV=$(lsblk -dno NAME,TRAN | grep 'usb' | awk '{print "/dev/"$1}' | head -n 1)
if [ -z "$USB_DEV" ]; then echo "!! Kein USB-Stick gefunden."; exit 1; fi

echo "Gefunden: $USB_DEV"
read -p "ACHTUNG: Daten auf $USB_DEV loeschen? (y/n): " confirm
if [ "$confirm" != "y" ]; then exit 0; fi

# Ventoy aus Unterordner ausführen
echo ">> Installiere Ventoy..."
cd "$VENTOY_DIR"
sudo bash Ventoy2Disk.sh -i -g -s "$USB_DEV"
cd ..

# ISO kopieren
echo ">> Kopiere ISO..."
PART_NAME=$(lsblk -no NAME "$USB_DEV" | sed -n '2p')
MOUNT_POINT="/mnt/ventoy_tmp"
sudo mkdir -p "$MOUNT_POINT"
sudo mount "/dev/$PART_NAME" "$MOUNT_POINT"
sudo cp "$ISO_PATH" "$MOUNT_POINT/"
sudo umount "$MOUNT_POINT"
echo "=== FERTIG! ==="
