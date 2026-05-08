# --- KONFIGURATION ---
$IsoName = "chntpw-universal-rescue.iso"
$IsoPath = Join-Path $PSScriptRoot $IsoName

# Sucht den ersten Ordner im aktuellen Verzeichnis, der "ventoy" im Namen hat
$VentoyFolder = Get-ChildItem -Directory -Path $PSScriptRoot -Filter "*ventoy*" | Select-Object -First 1

if (-not $VentoyFolder) {
    Write-Host "!! FEHLER: Kein Ventoy-Ordner im Verzeichnis gefunden!" -ForegroundColor Red
    exit
}

$VentoyExe = Join-Path $VentoyFolder.FullName "Ventoy2Disk.exe"
# ---------------------

Write-Host "=== Ventoy Auto-Installer (Pfad: Iso-Ordner) ===" -ForegroundColor White -BackgroundColor Blue

if (-not (Test-Path $IsoPath)) {
    Write-Host "!! FEHLER: ISO nicht gefunden: $IsoPath" -ForegroundColor Red
    exit
}

# USB-Stick finden
$USBStick = Get-Disk | Where-Object { $_.BusType -eq 'USB' -and $_.OperationalStatus -eq 'Online' } | Select-Object -First 1
if (-not $USBStick) { Write-Host "!! Kein USB-Stick gefunden." -ForegroundColor Red; exit }

$Partition = $USBStick | Get-Partition | Where-Object { $_.DriveLetter } | Select-Object -First 1
$DriveLetter = "$($Partition.DriveLetter):"

Write-Host " Gefunden: $($USBStick.FriendlyName) auf $DriveLetter" -ForegroundColor Green
$Confirm = Read-Host "ACHTUNG: Alle Daten auf $DriveLetter werden geloescht! Fortfahren? (j/n)"
if ($Confirm -ne "j") { exit }

# Ventoy aus Unterordner starten
Write-Host ">> Installiere Ventoy..." -ForegroundColor Cyan
Set-Location $VentoyFolder.FullName
Start-Process -FilePath ".\Ventoy2Disk.exe" -ArgumentList "/I /S /GPT $DriveLetter" -Wait
Set-Location $PSScriptRoot

# ISO kopieren
Write-Host ">> Kopiere ISO..." -ForegroundColor Cyan
Start-Sleep -Seconds 5
Copy-Item -Path $IsoPath -Destination "$DriveLetter\" -Force

Write-Host "=== FERTIG! ===" -ForegroundColor Green
