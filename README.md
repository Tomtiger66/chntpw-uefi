# cChntpw UEFI Resurrection

This project creates a minimal, high-performance rescue system based on Alpine Linux. It is optimized to quickly reset Windows passwords (SAM database) or unlock user accounts.

## 💿 ISO Download & Location
After the build process (or after downloading), you will find the bootable file in the directory:
`./Iso/chntpw-universal-rescue.iso`

---

## 🛠 Installation on USB Flash Drive

### Method A: Ventoy (Recommended)
The ISO is fully compatible with **Ventoy**. Automation scripts are provided for easy setup:

#### On Windows:
1. Extract [Ventoy for Windows](https://github.com).
2. Copy `install_ventoy_auto.ps1` into the Ventoy folder.
3. Right-click the script -> *Run with PowerShell* (Administrator).
   *The script automatically finds the ISO in the `../Iso/` directory, installs Ventoy on the USB drive, and copies the ISO.*

#### On Linux (e.g., CachyOS):
1. Extract the Ventoy Linux archive.
2. Copy `install_ventoy.sh` into the Ventoy folder.
3. Run it in the terminal: `chmod +x install_ventoy.sh && ./install_ventoy.sh`.

---

## 🚀 Boot Compatibility

The image is built as a **Universal Hybrid ISO** and supports:

*   **UEFI & Legacy BIOS:** Boots on both old and modern systems.
*   **Easy2Boot (E2B):** Successfully tested. The ISO can be mounted directly via the E2B menu.
*   **Rufus / BalenaEtcher:** If you are not using Ventoy, please write the ISO in **DD Mode**.
*   **Direct Writing:** On Linux via `sudo dd if=./Iso/chntpw-universal-rescue.iso of=/dev/sdX status=progress`.

---

## ⚠️ Important Notes
*   **Secure Boot:** Since the kernel is self-signed, **Secure Boot** must be disabled in the BIOS/UEFI settings if the drive does not appear in the boot menu.
*   **Safe Shutdown:** After finishing your work, use the system menu to **Shutdown** or **Reboot**. Please use these options to avoid a kernel panic during exit.

---

## ⚖️ License & Credits
*   **chntpw:** Based on the work of Petter Nordahl-Hagen.
*   **OS:** Alpine Linux (Mini Root FS).
*   **Scripts:** Custom build scripts for automated initramfs integration.



# Chntpw UEFI Resurrection

Projekt zur Modernisierung der klassischen chntpw-Boot-ISO für moderne PC-Architekturen.

## Ziel
Erstellung einer leichtgewichtigen (< 50MB) UEFI-bootfähigen ISO, um Windows-Passwörter auf moderner Hardware (z.B. NVMe-SSDs) zurückzusetzen.

## Hintergrund
Das Original-ISO unterstützt kein UEFI und erkennt keine NVMe-Laufwerke. Dieses Projekt extrahiert die bewährte Logik und bettet sie in ein modernes Minimal-Linux (wie Alpine) ein.

## Inhalt
- \`scripts/\`: Die Original-Logik der Boot-CD.
- \`init\`: Das ursprüngliche Start-Script.
- \`Iso\`: Dieser Ordner enthält die fertige ISO-Datei einschließlich Scripte zu Erstellung eines bootfähigen Sticks unter Window und Linux.
