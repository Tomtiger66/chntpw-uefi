# Chntpw UEFI Resurrection 🛠️

**EN:** A modernized, ultra-lightweight rescue system based on Alpine Linux. Designed to reset Windows passwords on modern hardware (NVMe & UEFI).  
**DE:** Ein modernisiertes, extrem schlankes Rettungssystem auf Basis von Alpine Linux. Optimiert für Windows-Passwort-Resets auf moderner Hardware (NVMe & UEFI).

---

## 📂 Project Structure / Projektstruktur

```text
.
├── built_iso.sh          # Build script / Erstellungs-Skript
├── README.md             # This file / Diese Datei
├── iso_content/          # RootFS source / Quellverzeichnis für das Image
└── Iso/                  # Stable Production Folder / Ordner für stabile Versionen
    ├── chntpw-universal-rescue.iso
    ├── install_ventoy.sh
    ├── install_ventoy_auto.ps1
    └── README.md         # Deployment instructions / Installationsanleitung
```

---

## 🏗️ Build & Safety / Erstellung & Sicherheit

**EN:** To prevent overwriting a working production image, the `built_iso.sh` script saves the new ISO to your **Home directory** (`~/`) by default.  
**DE:** Um das Überschreiben einer funktionierenden Version zu verhindern, speichert das Skript `built_iso.sh` die neue ISO standardmäßig in deinem **Home-Verzeichnis** (`~/`) ab.

1. **Build:** Run `./built_iso.sh`.
2. **Test:** Verify the new ISO (e.g., in a VM).
3. **Release:** Manually move the tested ISO to the `./Iso/` folder to update the production version.

**DE:**
1. **Build:** `./built_iso.sh` ausführen.
2. **Test:** Die neue ISO prüfen (z. B. in einer VM).
3. **Release:** Die geprüfte ISO manuell in den Ordner `./Iso/` verschieben, um die stabile Version zu aktualisieren.

---

## 💿 Deployment & Installation

**EN:** For instructions on how to create the USB boot stick, please refer to the **README.md in the `./Iso` directory**. It contains automated scripts for Ventoy.  
**DE:** Anweisungen zum Erstellen des USB-Boot-Sticks findest du in der **README.md im Verzeichnis `./Iso`**. Dort befinden sich automatisierte Skripte für Ventoy.

---

## 🚀 Key Features / Hauptmerkmale

*   **Modern Hardware:** Full UEFI and NVMe SSD support. / Volle UEFI- und NVMe-Unterstützung.
*   **Enhanced UI:** Uses GRUB `gfxterm` (Unicode) for better readability. / Nutzt GRUB `gfxterm` (Unicode) für bessere Lesbarkeit.
*   **Secure Boot:** Must be **DISABLED**. / Muss **DEAKTIVIERT** sein.
*   **Safe Shutdown:** Use the system menu to avoid kernel panics. / Systemmenü zum Ausschalten nutzen, um Kernel-Panics zu vermeiden.

---

**Credits:** Based on chntpw (Petter Nordahl-Hagen) & Alpine Linux.
