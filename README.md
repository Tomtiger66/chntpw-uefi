------------------------------
## Chntpw UEFI Resurrection 🛠️
EN: A modernized, ultra-lightweight rescue system based on Alpine Linux. Designed to reset Windows passwords on modern hardware (NVMe & UEFI).
DE: Ein modernisiertes, extrem schlankes Rettungssystem auf Basis von Alpine Linux. Optimiert für Windows-Passwort-Resets auf moderner Hardware (NVMe & UEFI).
------------------------------
## 📂 Project Structure / Projektstruktur

.
├── built_iso.sh          # Build script / Erstellungs-Skript
├── iso_content/          # RootFS source / Quellverzeichnis für das Image
├── Iso/                  # Stable Production Folder / Ordner für stabile Versionen
│   ├── chntpw-universal-rescue.iso
│   ├── install_ventoy.sh
│   └── ...
└── ~/                    # Build Output / Ziel des Build-Skripts (Home-Ordner)

------------------------------
## 🏗️ Build & Safety / Erstellung & Sicherheit
EN: To prevent overwriting a working production image, the built_iso.sh script saves the new ISO to your Home directory by default.
DE: Um das Überschreiben einer funktionierenden Version zu verhindern, speichert das Skript built_iso.sh die neue ISO standardmäßig in deinem Home-Verzeichnis (~/) ab.

   1. Build: Run ./built_iso.sh.
   2. Test: Verify the new ISO (e.g., in a VM).
   3. Release: Manually move the tested ISO to the ./Iso/ folder to update the production version.

DE:

   1. Build: ./built_iso.sh ausführen.
   2. Test: Die neue ISO prüfen (z. B. in einer VM).
   3. Release: Die geprüfte ISO manuell in den Ordner ./Iso/ verschieben, um die stabile Version zu aktualisieren.

------------------------------
## 💿 Deployment & Installation
EN: See ./Iso/README.md for detailed instructions on creating a bootable USB stick using the automated Ventoy scripts.
DE: Siehe ./Iso/README.md für detaillierte Anweisungen zur Erstellung eines Boot-Sticks mit den automatisierten Ventoy-Skripten.
------------------------------
## 🚀 Features & Notes

* Graphics: Uses GRUB gfxterm (Unicode) for modern displays.
* Hardware: Full NVMe & UEFI support.
* Secure Boot: Must be DISABLED (self-signed kernel).
* Shutdown: Always use the system menu to prevent kernel panics.

DE:

* Grafik: Nutze GRUB gfxterm (Unicode) für moderne Monitore.
* Hardware: Volle NVMe- & UEFI-Unterstützung.
* Secure Boot: Muss DEAKTIVIERT sein (selbstsignierter Kernel).
* Beenden: Immer das Systemmenü nutzen, um Kernel-Panics zu vermeiden.

------------------------------
