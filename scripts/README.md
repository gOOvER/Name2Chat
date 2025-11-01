# Development Scripts

Diese Skripte unterstützen die lokale Entwicklung des Name2Chat Addons.

## Version aktualisieren

### Linux/macOS:
```bash
./scripts/update-version.sh 3.5.6
```

### Windows:
```cmd
scripts\update-version.bat 3.5.6
```

## Automatische Versionierung

Das Addon nutzt automatische Versionierung basierend auf Git-Tags:

1. **Lokale Entwicklung:** Version wird manuell mit Skripten gesetzt
2. **GitHub Releases:** Version wird automatisch aus Git-Tags extrahiert

### Release-Workflow:

1. **Tag erstellen:**
   ```bash
   git tag v3.5.6
   git push origin v3.5.6
   ```

2. **GitHub Actions Pipeline:**
   - Erkennt automatisch die Version aus dem Tag
   - Ersetzt `@project-version@` in der TOC-Datei
   - Erstellt Release mit BigWigs Packager
   - Lädt auf CurseForge, WoWInterface und Wago hoch

### TOC Version Placeholder:

Die `Name2Chat.toc` Datei enthält:
```
## Version: @project-version@
```

Dieser Placeholder wird ersetzt durch:
- **Lokale Entwicklung:** Manuell mit Skripten
- **Automatische Releases:** GitHub Actions mit Git-Tag-Version

## Vorteile:

- ✅ **Single Source of Truth:** Version kommt vom Git-Tag
- ✅ **Keine manuellen Updates:** Automatisch in Release-Pipeline
- ✅ **Konsistenz:** Gleiche Version in Tag, TOC und Release
- ✅ **Entwicklerfreundlich:** Lokale Skripte für Testing