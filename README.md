# Chntpw UEFI Resurrection

Projekt zur Modernisierung der klassischen chntpw-Boot-ISO für moderne PC-Architekturen.

## Ziel
Erstellung einer leichtgewichtigen (< 50MB) UEFI-bootfähigen ISO, um Windows-Passwörter auf moderner Hardware (z.B. NVMe-SSDs) zurückzusetzen.

## Hintergrund
Das Original-ISO unterstützt kein UEFI und erkennt keine NVMe-Laufwerke. Dieses Projekt extrahiert die bewährte Logik und bettet sie in ein modernes Minimal-Linux (wie Alpine) ein.

## Inhalt
- \`scripts/\`: Die Original-Logik der Boot-CD.
- \`init\`: Das ursprüngliche Start-Script.
