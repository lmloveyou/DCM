# DCM

DCM stands for Decompression Manager. It is a local Windows tool for selecting multiple ZIP files and extracting them in one action.

## Start

Double-click:

```text
DCM.lnk
```

If the shortcut does not exist yet, right-click `create-dcm-shortcut.ps1` and choose `Run with PowerShell`.

If you want the shortcut on your desktop, right-click `create-desktop-shortcut.ps1` and choose `Run with PowerShell`.

## Use

1. Click `Choose ZIP files`.
2. Select one or more `.zip` files.
3. Choose an output folder.
4. Click `Extract all`.

DCM creates a separate folder for each ZIP file inside the output folder.

## Desktop Icon

The `DCM.lnk` shortcut starts the app directly through PowerShell. It does not use a `.vbs` file anymore.

## First Version

This version supports ZIP files because Windows can extract ZIP files without extra software. RAR and 7Z support can be added later with 7-Zip.
