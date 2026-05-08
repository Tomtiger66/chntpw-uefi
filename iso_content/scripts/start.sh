#!/bin/sh
export PATH=/usr/bin:/bin:/usr/sbin:/sbin

mkdir -p /tmp
mkdir -p /disk

echo "Willkommen beim Passwort-Reset!"
echo "Bitte Tastaturlayout wählen:"
echo "1) Deutsch (qwertz)"
echo "2) English (qwerty)"
read -p "Auswahl [1]: " kbd

if [ "$kbd" = "2" ]; then
    loadkeys /usr/share/keymaps/xkb/us.map.gz 2>/dev/null || true
else
    loadkeys /usr/share/keymaps/xkb/de.map.gz 2>/dev/null || true
fi

sh /scripts/main.sh
exec /bin/sh
