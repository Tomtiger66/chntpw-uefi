# chntpw UEFI Rescue ISO

Dieses Projekt erstellt ein minimales Rescue-System auf Basis von Alpine Linux zum Zurücksetzen von Windows-Passwörtern.

## 💿 ISO-Download & Speicherort
Die bootfähige Datei und die Installations-Tools befinden sich im Ordner:
`./Iso/`

---

## 🛠 Installation auf USB-Stick (Ventoy)

Um den Stick automatisch vorzubereiten, nutze die Skripte direkt im `Iso`-Ordner. Diese suchen automatisch nach dem entpackten Ventoy-Verzeichnis.

### Struktur im `Iso`-Ordner:
```text
Iso/
├── chntpw-universal-rescue.iso
├── install_ventoy_auto.ps1   (für Windows)
├── install_ventoy.sh        (für Linux)
└── ventoy-1.0.xx/           (entpackter Ventoy-Ordner)
```

### Installation unter Windows:
1. Öffne eine **PowerShell als Administrator**.
2. Navigiere in den `Iso`-Ordner deines Projekts.
3. Starte das Skript:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
   .\(\install_ventoy_auto.\)ps1
   ```
   *Das Skript findet den Ventoy-Unterordner, bereitet den Stick vor und kopiert die ISO.*

### Installation unter Linux:
1. Öffne ein Terminal im `Iso`-Ordner.
2. Mache das Skript ausführbar und starte es:
   ```bash
   chmod +x install_ventoy.sh
   ./install_ventoy.sh
   ```

---

## 🚀 Boot-Kompatibilität & Tests

*   **Universal-Hybrid:** Unterstützt **UEFI** und **Legacy BIOS**.
*   **Ventoy:** Erfolgreich getestet.
*   **Easy2Boot (E2B):** Erfolgreich getestet. Die ISO kann problemlos über das E2B-Menü gestartet werden.
*   **Rufus / BalenaEtcher:** Falls kein Ventoy genutzt wird, bitte im **DD-Modus** schreiben.

---

## ⚠️ Wichtige Hinweise
*   **Secure Boot:** Muss im BIOS/UEFI deaktiviert werden, da der Kernel nicht Microsoft-signiert ist.
*   **Beenden:** Nutze nach der Arbeit das Menü im System zum **Ausschalten** oder **Neustarten**, um Kernel-Panics zu vermeiden.

---

**Viel Erfolg beim Passwort-Reset!**
