------------------------------
## ISO & Installation Tools 💿
EN: This directory contains the final bootable ISO and automated installation scripts for Ventoy.
DE: Dieses Verzeichnis enthält die fertige Boot-ISO und automatisierte Installations-Skripte für Ventoy.
------------------------------
## 📂 Folder Structure / Ordnerstruktur

Iso/
├── chntpw-universal-rescue.iso  # The Image / Das Abbild
├── install_ventoy_auto.ps1      # Windows Installer (PowerShell)
├── install_ventoy.sh           # Linux Installer (Bash)
└── ventoy-1.0.xx/              # Extracted Ventoy folder / Entpackter Ventoy-Ordner

------------------------------
## 🛠 Installation (Ventoy)
EN: The scripts are designed to find the Ventoy subfolder automatically. Simply place your extracted Ventoy folder here and run the script for your OS.
DE: Die Skripte finden den Ventoy-Unterordner automatisch. Kopiere einfach deinen entpackten Ventoy-Ordner hierher und starte das passende Skript.
## Windows:

   1. EN: Run PowerShell as Administrator. / DE: PowerShell als Administrator starten.
   2. Set-ExecutionPolicy Bypass -Scope Process
   3. .\install_ventoy_auto.ps1

## Linux:

   1. chmod +x install_ventoy.sh
   2. ./install_ventoy.sh

------------------------------
## 🚀 Compatibility / Kompatibilität

* Universal-Hybrid: Supports UEFI & Legacy BIOS. / Unterstützt UEFI & Legacy BIOS.
* NVMe Support: Detects modern SSDs. / Erkennt moderne NVMe-SSDs.
* Alternative: Tested with Easy2Boot, Rufus & BalenaEtcher (Use DD Mode / DD-Modus nutzen).

------------------------------
## ⚠️ Important Notes / Wichtige Hinweise

* Secure Boot: Must be DISABLED in BIOS/UEFI. / Muss im BIOS/UEFI DEAKTIVIERT werden.
* Exit: Use the system menu for Shutdown/Reboot to avoid kernel panics. / Zum Beenden das Systemmenü (Ausschalten/Neustart) nutzen, um Kernel-Panics zu vermeiden.

------------------------------
Happy Password Resetting! / Viel Erfolg beim Passwort-Reset!
------------------------------
## Was ich angepasst habe:

   1. Struktur-Box: Zeigt jetzt genau, dass der Ventoy-Ordner ein Unterordner von Iso ist.
   2. PowerShell-Befehl: Den Syntaxfehler .\(\...\) korrigiert und den ExecutionPolicy-Hinweis für Windows-User direkt lesbar gemacht.
   3. Kompaktheit: Informationen, die für den Endanwender wichtig sind (wie NVMe-Support), sind jetzt in beiden Sprachen kurz und knackig drin.

Passt das so zu deinem Workflow, oder soll ich noch einen speziellen Hinweis für CachyOS/Arch-User (z.B. Abhängigkeiten für das Bash-Skript) einfügen?

