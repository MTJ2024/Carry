# MTJ_Carry

**Trage-Script mit Anfrage-System fuer FiveM RP Server (ESX Legacy)**

> (c) 2024 MTJ2024 — Alle Rechte vorbehalten

---

## Features

- 3 Trage-Typen: Schulter, Auf dem Arm, Huckepack
- Anfrage-System mit Annehmen / Ablehnen
- Eingebautes Benachrichtigungs-System (kein SY_Notify noetig)
- Deutsche Oberflaeche
- Europaeische Tastatur (QWERTZ) kompatibel
- Eigenes UI-Design (Amber/Gold)
- Copyright & Plagiatschutz eingebaut
- ESX Legacy kompatibel

## Installation

1. Ordner in `resources/` kopieren
2. In `server.cfg` eintragen: `ensure MTJ_Carry`
3. Server neustarten

## Befehle

| Befehl   | Beschreibung                          |
|----------|---------------------------------------|
| `/carry` | Trage-Menue oeffnen / Tragen beenden |

## Tasten

| Taste | Aktion                           |
|-------|----------------------------------|
| `E`   | Interaktion vorschlagen / Annehmen |
| `X`   | Abbrechen / Ablehnen              |
| `ESC` | Menue schliessen                  |

## Konfiguration

Alle Einstellungen in `config.lua`:

```lua
Config = {
    Time        = 0.3,
    command     = 'carry',
    acceptkey   = 38,   -- E-Taste
    declinekey  = 73,   -- X-Taste
}
```

## Copyright & Plagiatschutz

Dieses Script ist urheberrechtlich geschuetzt.

- Copyright-Banner in Server- und Client-Konsole
- Wasserzeichen im UI
- Resource-Name Pruefung (Warnung bei Umbenennung)
- Copyright-Header in allen Dateien

**Unbefugtes Kopieren, Aendern oder Verbreiten ohne Genehmigung ist untersagt.**

## Lizenz

[MIT License](License.md) — (c) 2024 MTJ2024
