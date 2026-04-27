#!/bin/sh
# Systempfade setzen, damit cat, ls, mkdir etc. gefunden werden
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Wichtige Verzeichnisse für die Scripte anlegen
mkdir -p /tmp
mkdir -p /disk

echo "Willkommen beim Passwort-Reset!"
echo "Bitte Tastaturlayout wählen:"
echo "1) Deutsch (qwertz)"
echo "2) English (qwerty)"
read -p "Auswahl [1]: " kbd
if [ "$kbd" = "2" ]; then
  loadkeys /usr/share/keymaps/i386/qwerty/us.map.gz
else
  loadkeys /usr/share/keymaps/i386/qwertz/de.map.gz
fi
sh /scripts/main.sh

