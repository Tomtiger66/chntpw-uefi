# ISO & Installation Tools 💿

**EN:** This directory contains the final bootable ISO and automated installation scripts for Ventoy.  
**DE:** Dieses Verzeichnis enthält die fertige Boot-ISO und automatisierte Installations-Skripte für Ventoy.

---

## 📂 Folder Structure / Ordnerstruktur

```text
Iso/
├── chntpw-universal-rescue.iso  # The Image / Das Abbild
├── install_ventoy_auto.ps1      # Windows Installer (PowerShell)
├── install_ventoy.sh           # Linux Installer (Bash)
└── ventoy-1.0.xx/              # Extracted Ventoy folder / Entpackter Ventoy-Ordner
```

---

## 🛠 Installation (Ventoy)

**EN:** The scripts are designed to find the Ventoy subfolder automatically. Simply place your extracted Ventoy folder here and run the script for your OS.  
**DE:** Die Skripte finden den Ventoy-Unterordner automatisch. Kopiere einfach deinen entpackten Ventoy-Ordner hierher und starte das passende Skript.

### Windows:
1. **EN:** Run PowerShell as **Administrator**. / **DE:** PowerShell als **Administrator** starten.
2. `Set-ExecutionPolicy Bypass -Scope Process`
3. `.\install_ventoy_auto.ps1`

### Linux:
1. `chmod +x install_ventoy.sh`
2. `./install_ventoy.sh`

---

## 🚀 Compatibility / Kompatibilität

*   **Universal-Hybrid:** Supports **UEFI** & **Legacy BIOS**. / Unterstützt **UEFI** & **Legacy BIOS**.
*   **NVMe Support:** Detects modern SSDs. / Erkennt moderne NVMe-SSDs.
*   **Alternative:** Tested with **Easy2Boot**, **Rufus** & **BalenaEtcher** (Use **DD Mode** / **DD-Modus** nutzen).

---

## ⚠️ Important Notes / Wichtige Hinweise

*   **Secure Boot:** Must be **DISABLED** in BIOS/UEFI. / Muss im BIOS/UEFI **DEAKTIVIERT** werden.
*   **Exit:** Use the system menu for **Shutdown/Reboot** to avoid kernel panics. / Zum Beenden das Systemmenü (**Ausschalten/Neustart**) nutzen, um Kernel-Panics zu vermeiden.

---

**Happy Password Resetting! / Viel Erfolg beim Passwort-Reset!**
