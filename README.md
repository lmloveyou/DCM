# DCM

DCM staat voor Decompressie Manager. Dit is een lokale Windows-tool om meerdere ZIP-bestanden tegelijk te kiezen en uit te pakken.

## Starten

Dubbelklik op:

```text
DCM.lnk
```

Als de snelkoppeling nog niet bestaat, klik dan eerst rechts op `create-dcm-shortcut.ps1` en kies `Run with PowerShell`.

Wil je de snelkoppeling op je bureaublad zetten, klik dan rechts op `create-desktop-shortcut.ps1` en kies `Run with PowerShell`.

## Gebruik

1. Klik op `ZIP-bestanden kiezen`.
2. Selecteer een of meerdere `.zip` bestanden.
3. Kies een doelmap.
4. Klik op `Alles decomprimeren`.

DCM maakt per ZIP-bestand een aparte map aan in de doelmap.

## Desktop-icoon

De snelkoppeling `DCM.lnk` start de app direct via PowerShell. Je hoeft geen `.vbs` bestand te openen.

## Eerste versie

Deze versie ondersteunt ZIP-bestanden, omdat Windows dat standaard kan uitpakken zonder extra programma's. RAR en 7Z kunnen later toegevoegd worden met 7-Zip ondersteuning.
