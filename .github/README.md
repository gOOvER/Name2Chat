# GitHub Actions Workflows

Dieses Repository verwendet mehrere GitHub Actions Workflows für automatisierte Tests, Code-Qualitätsprüfungen und Releases.

## 📋 Verfügbare Workflows

### 1. Tests (`test.yml`)
**Trigger:** Push/Pull Request auf `master`, `main`, `dev`, `develop`

Führt umfassende Tests durch:
- ✅ Lua-Syntax-Prüfung mit luacheck
- ✅ Addon-Struktur-Validierung  
- ✅ Versions-Konsistenz-Prüfung
- ✅ Interface-Kompatibilitäts-Tests

### 2. Release (`release.yml`)
**Trigger:** 
- Git Tags (`v*`)
- Manuell über GitHub UI

Automatisiert den Release-Prozess:
- ✅ Versions-Validierung
- ✅ TOC-Konsistenz-Prüfung
- ✅ Addon-Paketierung (ZIP)
- ✅ GitHub Release erstellen
- ✅ Upload zu Addon-Plattformen (CurseForge, WoWInterface, Wago)

### 3. Code Quality (`quality.yml`)
**Trigger:** 
- Push/Pull Request auf Hauptbranches
- Wöchentlich (Sonntags 3 Uhr UTC)

Prüft Code-Qualität:
- 🔍 Erweiterte Luacheck-Analyse
- 📋 TOC-Datei-Validierung
- 🔒 Sicherheits-Scan
- 📊 Addon-Metadaten-Prüfung

## 🚀 Release erstellen

### Automatischer Release (empfohlen)

1. **Version in TOC aktualisieren:**
   ```toc
   ## Version: 3.5.6
   ```

2. **Tag erstellen und pushen:**
   ```bash
   git tag v3.5.6
   git push origin v3.5.6
   ```

3. **Workflow läuft automatisch** und erstellt:
   - GitHub Release
   - ZIP-Paket
   - Upload zu Addon-Plattformen

### Manueller Release

1. Gehe zu **Actions** → **Release**
2. Klicke **Run workflow**
3. Gebe Version ein (z.B. `3.5.6`)
4. Wähle ob Git-Tag erstellt werden soll
5. Klicke **Run workflow**

## 🔧 Konfiguration

### API-Keys für Addon-Plattformen

Füge diese Secrets in GitHub hinzu (**Settings** → **Secrets and variables** → **Actions**):

| Secret Name | Platform | Beschreibung |
|-------------|----------|--------------|
| `CF_API_KEY` | CurseForge | API-Key für automatische Uploads |
| `WOWI_API_TOKEN` | WoWInterface | API-Token für WoWInterface |
| `WAGO_API_TOKEN` | Wago | API-Token für Wago |

### Luacheck-Konfiguration

Die Workflows verwenden eine automatisch generierte `.luacheckrc` mit:
- WoW API Globals
- Ace3 Library Globals  
- Standard Lua 5.1 + WoW Extensions
- Angepasste Ignore-Rules für WoW-Addons

## 📊 Workflow-Status

Die Workflows erstellen detaillierte Reports:

- **Test Summary:** Zeigt alle Testergebnisse
- **Code Quality Report:** Luacheck-Ergebnisse und TOC-Validierung
- **Release Summary:** Upload-Status für alle Plattformen
- **Security Scan:** Potentielle Sicherheitsprobleme

## 🔍 Troubleshooting

### Häufige Probleme

1. **Versions-Mismatch:**
   - Version in `Name2Chat.toc` muss mit Git-Tag übereinstimmen
   - Format: `X.Y.Z` (z.B. `3.5.6`)

2. **Luacheck-Fehler:**
   - Prüfe Lua-Syntax in den Dateien
   - Siehe `.luacheckrc` für erlaubte Globals

3. **TOC-Validierung fehlgeschlagen:**
   - Prüfe TOC-Datei-Format
   - Stelle sicher, dass alle referenzierten Dateien existieren

4. **Upload fehlgeschlagen:**
   - Prüfe ob API-Keys konfiguriert sind
   - Kontrolliere Plattform-IDs in TOC-Datei

### Debug-Informationen

Alle Workflows erzeugen detaillierte Logs:
- Gehe zu **Actions** → Wähle Workflow → Klicke auf Run
- Expandiere die einzelnen Steps für Details
- Downloads sind als Artifacts verfügbar

## 📁 Datei-Übersicht

```
.github/workflows/
├── test.yml          # Automatische Tests
├── release.yml       # Release-Automation  
├── quality.yml       # Code-Qualitätsprüfungen
└── README.md         # Diese Dokumentation
```

## 🎯 Nächste Schritte

1. **API-Keys konfigurieren** für automatische Platform-Uploads
2. **Ersten Release testen** mit kleiner Versions-Erhöhung
3. **Workflows überwachen** und bei Bedarf anpassen
4. **CHANGELOG.md erstellen** für bessere Release-Notes

---

**Hinweis:** Die Workflows verwenden den BigWigs Packager für professionelle WoW-Addon-Verpackung und sind vollständig kompatibel mit allen WoW-Versionen (Retail + Classic).