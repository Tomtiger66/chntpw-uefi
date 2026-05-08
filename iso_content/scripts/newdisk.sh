#!/bin/sh

# Select disk partition to process
# works on results probed by findwin.sh
# part of password reset bootimage
# (c) 2013-2014 Petter N Hagen
# NVMe + ntfs3 support, robuste dirty-Erkennung und
# mehrstufige Mount-Strategie 2025

RW="rw"

line () {
 echo "========================================================="
}

# Sicherheitshalber /disk aushängen falls noch eingehängt
umount /disk >/dev/null 2>&1

# Windows-Installationen suchen
/scripts/findwin.sh

line
echo
echo "--- Possible windows installations found:"
echo
cat /tmp/pflistprint

e="x"

while [ $e"x" != "qx" ];
do
  echo ""
  echo "Please select partition by number or"
  echo " q = quit.  o = go to old disk select system"
  echo " d = automatically start disk drivers"
  echo " m = manually select disk drivers to load"
  echo " f = fetch additional drivers from floppy / usb"
  echo " a = show all partitions found (fdisk)"
  echo " l = show propbable Windows partitions only"

  echo -n "Select: [1] "
  read e
  [ $e"x" = "x" ] && e="1"
  case $e in
      "o")
          # Altes Disk-Auswahl-System starten
          exit 8
          ;;
      "f")
          # Zusätzliche Treiber von Floppy/USB holen
          /scripts/fetchdrv.sh "== Additional driver fetch. Swap floppy/usb if needed"
          echo
          echo "Now try 'd' or 'm' to try to start the new drivers"
          echo
          sleep 1
          ;;
      "a")
          # Alle Partitionen anzeigen
          echo
          echo "All partitions:"
          fdisk -l
          ;;
      "l")
          # Nur Windows-Partitionen anzeigen
          /scripts/findwin.sh
          echo "Candidate Windows partitions found:"
          cat /tmp/pflistprint
          ;;
      "d")
          # Disk-Treiber automatisch laden und neu suchen
          /scripts/autoscsi.sh
          /scripts/findwin.sh
          echo "Candidate Windows partitions found:"
          cat /tmp/pflistprint
          ;;
      "m")
          # Disk-Treiber manuell auswählen und neu suchen
          /scripts/scsi.sh
          /scripts/findwin.sh
          echo "Candidate Windows partitions found:"
          cat /tmp/pflistprint
          ;;
      [0-9]*)
          # Zahl eingegeben - Partition auswählen
          [ `cat /tmp/pflist | wc -l` -ge $e ] && {
          echo
          echo "Selected $e"
          echo

          # Partitionsdaten aus der Liste lesen
          # Format: /dev/XXX ntfs_flag vfat_flag pfad
          n=1
          while read a b c d; do
                  if [ $((n++)) -eq $e ]; then
                          prt=${a}   # Gerätepfad z.B. /dev/nvme0n1p3
                          ntfs=${b}  # 1 wenn NTFS
                          vfat=${c}  # 1 wenn VFAT
                          path=${d}  # Pfad zur Registry
                          continue
                  fi
          done </tmp/pflist

          # Pfade für spätere Verwendung speichern
          echo $path >/tmp/regpath
          echo $prt >/tmp/disk

          echo -n "Mounting from $prt, with filesystem type "

          # Dateisystemtyp bestimmen
          if [ $ntfs -eq 1 ]; then
                  echo -n "NTFS"
                  fs="ntfs"
          elif [ $vfat -eq 1 ]; then
                  echo -n "VFAT"
                  fs="vfat"
          else
                  echo -n "unknown??"
          fi
          echo

          if [ $fs = "ntfs" ]; then
             echo "So, let's really check if it is NTFS?"
             echo

             # -----------------------------------------------
             # SCHRITT 1: ntfsfix im Dry-Run Modus
             # ntfsfix -n prüft die Partition ohne Änderungen.
             # Es erkennt Hibernation zuverlässig, aber nicht
             # immer den dirty-Zustand. Deshalb folgt danach
             # noch ein praktischer ro-Mount Test.
             # -----------------------------------------------
             echo "Running ntfsfix check..."
             ntfsfix_out=$(ntfsfix -n $prt 2>&1)
             echo "$ntfsfix_out"
             echo
             flags=""
             nrt=999  # Standard: alles OK
             used_legacy_ntfs=0  # Merker ob Legacy-Treiber benutzt wurde

             if echo "$ntfsfix_out" | grep -qi "hibern"; then
                # -----------------------------------------------
                # HIBERNATED: Windows wurde in den Ruhezustand
                # versetzt (Hibernate/Suspend to Disk).
                # Das ist gefährlich weil Windows die Partition
                # noch als "in Verwendung" betrachtet und beim
                # nächsten Start aus dem Ruhezustand fortsetzen
                # will. Änderungen könnten verloren gehen oder
                # Windows könnte beim nächsten Start Probleme
                # haben.
                #
                # SICHERSTE Lösung: Windows starten, warten bis
                # es vollständig geladen ist, dann über
                # Start -> Herunterfahren (NICHT Neustart!)
                # sauber beenden.
                # -----------------------------------------------
                echo
                line
                echo " ** The system is HIBERNATED!"
                echo " ** Windows wurde in den Ruhezustand versetzt."
                echo " ** SICHERSTE Loesung: Windows starten und ueber"
                echo " ** Start -> Herunterfahren (NICHT Neustart!) beenden."
                line
                echo
                echo "If that is not possible, you can force changes,"
                echo "but the hibernated session will be lost!"
                echo "Windows will do a disk check on next boot - that is normal."
                echo
                read -p "Do you wish to force it? (y/n) [n] " yn
                if [ "$yn" = "y" ]; then
                   flags="remove_hiberfile"
                   nrt=999
                   echo
                   echo "Your wish is my command, *poof* goes the hibernation"
                else
                   echo "No changes made to the disk"
                   exit 1
                fi
             fi

             # -----------------------------------------------
             # SCHRITT 2: Read-Only Mount als echter Test
             # ntfsfix erkennt nicht alle dirty-Zustände.
             # Der zuverlässigste Test ist ein ro-Mount:
             # - Klappt ro: Partition ist lesbar, rw wird klappen
             # - Schlägt ro fehl: Partition ist dirty
             # -----------------------------------------------
             if [ $nrt -eq 999 ]; then
                echo "Testing partition with read-only mount..."
                if mount -t ntfs3 -o ro,noatime $prt /disk 2>/dev/null; then
                   # ro hat geklappt - Partition ist sauber
                   umount /disk 2>/dev/null
                   echo "Yes, read-write seems OK."
                   nrt=999
                else
                   # -----------------------------------------------
                   # DIRTY: ro-Mount fehlgeschlagen!
                   # Das ist der zuverlässigste Beweis dass die
                   # Partition dirty ist. Das passiert wenn:
                   # - Der Rechner einfach ausgeschaltet wurde
                   # - Stromausfall während Windows lief
                   # - Windows Schnellstart (Fast Boot) aktiv ist
                   #   (Einstellungen -> System -> Netzbetrieb ->
                   #    Schnellstart deaktivieren empfohlen!)
                   #
                   # SICHERSTE Lösung: Windows starten und über
                   # Start -> Herunterfahren (NICHT Neustart!)
                   # sauber beenden.
                   # -----------------------------------------------
                   echo
                   line
                   echo " ** DIRTY - nicht sauber heruntergefahren!"
                   echo " ** Dies passiert oft wenn Windows einfach"
                   echo " ** abgewuergt wurde oder der Strom ausgefallen ist."
                   echo " ** Auch Windows Schnellstart kann das verursachen."
                   echo " ** SICHERSTE Loesung: Windows starten und ueber"
                   echo " ** Start -> Herunterfahren (NICHT Neustart!) beenden."
                   line
                   echo
                   echo "ntfsfix can try to repair the dirty flag."
                   echo "There is a small risk of losing recently changed files."
                   echo "Windows will do a disk check on next boot - that is normal."
                   echo
                   read -p "Repair with ntfsfix and force mount? (y/n) [n] " yn
                   if [ "$yn" = "y" ]; then
                      echo
                      echo "Repairing dirty flag with ntfsfix..."
                      ntfsfix $prt
                      echo "Done. Proceeding with mount..."
                      nrt=999
                   else
                      echo "No changes made to the disk"
                      exit 1
                   fi
                fi
             fi

             # -----------------------------------------------
             # SCHRITT 3: Mehrstufige Mount-Strategie
             #
             # Stufe 1: ntfs3 (moderner Kernel-Treiber)
             #   - Schnell und stabil
             #   - Kann bei sehr beschädigten Partitionen
             #     versagen
             #
             # Stufe 2: ntfsfix + nochmal ntfs3
             #   - ntfsfix repariert das dirty-Flag
             #   - Danach erneuter ntfs3 Versuch
             #
             # Stufe 3: alter ntfs Treiber
             #   - Toleranter gegenüber Beschädigungen
             #   - Langsamerer aber robusterer Treiber
             #   - WICHTIG: Danach Windows Festplattenprüfung
             #     empfohlen!
             #
             # Stufe 4: Windows Reparatur nötig
             #   - Partition zu beschädigt für Linux-Treiber
             #   - Ausführliche Anleitung wird angezeigt
             # -----------------------------------------------
             if [ $nrt -eq 999 ]; then
                echo "Mounting it. This may take up to a few minutes:"
                umount /disk 2>/dev/null

                # --- Stufe 1: ntfs3 versuchen ---
                # ntfs3 ist der moderne, in den Kernel
                # integrierte NTFS-Treiber (seit Linux 5.15)
                echo "Trying ntfs3 driver (Stufe 1)..."
                if [ -n "$flags" ]; then
                    mount -t ntfs3 -o $RW,noatime,$flags $prt /disk 2>/dev/null
                else
                    mount -t ntfs3 -o $RW,noatime $prt /disk 2>/dev/null
                fi
                MOUNT_RC=$?

                if [ $MOUNT_RC -ne 0 ]; then
                   # --- Stufe 2: ntfsfix + nochmal ntfs3 ---
                   # ntfsfix repariert das dirty-Flag direkt
                   # auf der Partition. Danach versuchen wir
                   # nochmal mit ntfs3 zu mounten.
                   echo
                   echo "ntfs3 failed - trying ntfsfix repair (Stufe 2)..."
                   ntfsfix $prt 2>/dev/null
                   echo "ntfsfix done, retrying ntfs3..."

                   if [ -n "$flags" ]; then
                       mount -t ntfs3 -o $RW,noatime,$flags $prt /disk 2>/dev/null
                   else
                       mount -t ntfs3 -o $RW,noatime $prt /disk 2>/dev/null
                   fi
                   MOUNT_RC=$?
                fi

                if [ $MOUNT_RC -ne 0 ]; then
                   # --- Stufe 3: alter ntfs Treiber ---
                   # Der alte ntfs Treiber ist toleranter
                   # gegenüber Beschädigungen als ntfs3.
                   # Er funktioniert auch wenn ntfs3 versagt,
                   # aber die Partition sollte danach unter
                   # Windows überprüft werden!
                   echo
                   echo "Trying legacy ntfs driver (Stufe 3)..."
                   if [ -n "$flags" ]; then
                       mount -t ntfs -o $RW,noatime,$flags $prt /disk 2>/dev/null
                   else
                       mount -t ntfs -o $RW,noatime $prt /disk 2>/dev/null
                   fi
                   MOUNT_RC=$?
                   [ $MOUNT_RC -eq 0 ] && used_legacy_ntfs=1
                fi

                if [ $MOUNT_RC -ne 0 ]; then
                   # --- Stufe 4: Windows Reparatur nötig ---
                   # Alle Mount-Versuche sind fehlgeschlagen.
                   # Die Partition ist zu beschädigt für die
                   # Linux-Treiber. Windows muss die Partition
                   # selbst reparieren.
                   echo
                   line
                   echo " ** PARTITION NICHT ZUGAENGLICH!"
                   echo " ** Die Partition ist so beschaedigt dass"
                   echo " ** nur Windows selbst sie reparieren kann."
                   line
                   echo
                   echo "So reparieren Sie Windows:"
                   echo
                   echo "METHODE 1: Windows automatische Reparatur"
                   echo "  1. PC normal starten"
                   echo "  2. Windows startet automatisch die Reparatur"
                   echo "  3. Warten bis fertig - kann 10-30 Minuten dauern"
                   echo "  4. Windows sauber herunterfahren:"
                   echo "     Start -> Herunterfahren (NICHT Neustart!)"
                   echo "  5. Dann diesen Stick erneut verwenden"
                   echo
                   echo "METHODE 2: Windows Wiederherstellungskonsole"
                   echo "  (Falls Windows nicht startet)"
                   echo "  1. Windows Installations-USB einstecken"
                   echo "     (kann von microsoft.com heruntergeladen werden)"
                   echo "  2. Vom USB booten (F12 beim Start druecken)"
                   echo "  3. Sprache auswaehlen -> Weiter"
                   echo "  4. 'Computer reparieren' auswaehlen (unten links)"
                   echo "  5. 'Problembehandlung' auswaehlen"
                   echo "  6. 'Erweiterte Optionen' auswaehlen"
                   echo "  7. 'Eingabeaufforderung' auswaehlen"
                   echo "  8. Folgende Befehle eingeben:"
                   echo "     chkdsk C: /f /r"
                   echo "     (C: durch den richtigen Laufwerksbuchstaben ersetzen)"
                   echo "     Wenn gefragt: J eingeben und Enter"
                   echo "  9. Nach Abschluss: exit eingeben"
                   echo " 10. 'PC ausschalten' auswaehlen"
                   echo " 11. Windows Stick entfernen"
                   echo " 12. Dann diesen Stick erneut verwenden"
                   echo
                   line
                   read -p "Press return/enter to continue.." yn
                   exit 1
                fi

                # -----------------------------------------------
                # Mount erfolgreich!
                # Falls der Legacy-Treiber verwendet wurde,
                # Hinweis anzeigen dass die Partition unter
                # Windows überprüft werden sollte.
                # -----------------------------------------------
                echo
                echo "Success!"
                echo "ntfs" >/tmp/fs

                if [ $used_legacy_ntfs -eq 1 ]; then
                   echo
                   line
                   echo " ** HINWEIS: Partition wurde mit Legacy-Treiber gemountet!"
                   echo " ** Die Partition war beschaedigt (dirty)."
                   echo " ** Das Passwort-Reset funktioniert trotzdem."
                   echo " ** ABER: Bitte nach dem Reset unter Windows die"
                   echo " ** Festplatte pruefen lassen!"
                   echo " ** So geht es:"
                   echo " ** 1. Windows starten"
                   echo " ** 2. Eingabeaufforderung als Administrator oeffnen"
                   echo " **    (Rechtsklick auf Start -> Terminal (Admin))"
                   echo " ** 3. Eingeben: chkdsk C: /f"
                   echo " **    (C: durch den richtigen Buchstaben ersetzen)"
                   echo " ** 4. Neustart bestaetigen und warten"
                   line
                   echo
                   read -p "Verstanden, weiter mit Passwort-Reset? [Enter] " dummy
                fi

                exit 0
             fi
          fi # ntfs check

          # -----------------------------------------------
          # VFAT: Die Partition wurde als FAT erkannt
          # (FAT16, FAT32, VFAT). Das ist typisch für
          # EFI-Systempartitionen oder ältere Windows-
          # Installationen. Windows selbst läuft immer
          # auf NTFS - eine FAT-Partition enthält
          # normalerweise nur den Bootloader.
          # -----------------------------------------------
          if [ $fs = "vfat" ]; then
            echo
            echo "Trying to mount FAT / VFAT / FAT32 etc"
            echo
            mount -t vfat -o $RW,noatime $prt /disk && {
                echo "vfat" >/tmp/fs
                echo
                echo "Success"
                exit 0
            }
            echo "ERROR: Mount failed! Try select again or another?"
          fi
    }
   ;;
  esac
done

exit 1
