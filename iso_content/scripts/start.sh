#!/bin/sh
# Systempfade setzen, damit cat, ls, mkdir etc. gefunden werden
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# Wichtige Verzeichnisse für die Scripte anlegen
mkdir -p /tmp
mkdir -p /disk

echo "Willkommen beim Passwort-Reset!"
echo "Bitte Tastaturlayout wählen:"
echo "1) Deutsch (qwertz)"
echo "2) English /usr/local/scripts/(qwerty)"
read -p "Auswahl [1]: " kbd
if [ "$kbd" = "2" ]; then
  loadkeys /lib/keymaps/us.map.gz
else
  loadkeys /lib/keymaps/de.map.gz
fi
sh /usr/local/scripts/main.sh

