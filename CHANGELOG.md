# Name2Chat Changelog

## Version 4.0.0 (26.01.2026)

### Major Updates
- **Patch 12.0.1 (Midnight) Support**: Updated for WoW Patch 12.0.1 (Interface 120001)
- **Full Classic Compatibility**: Added comprehensive support for all WoW variants
  - Classic Era (Interface 11508)
  - Season of Discovery
  - TBC Classic (Interface 20504)
  - Wrath Classic (Interface 30403)
  - Cata Classic (Interface 40400)

### Improvements
- **Enhanced Version Detection**: Automatic detection of all WoW client types
- **Improved API Handling**: 
  - Smart detection between modern `C_ChatInfo.SendChatMessage` (Retail) and legacy `SendChatMessage` (Classic variants)
  - Robust error handling with pcall protection
  - Automatic fallback mechanisms for API compatibility
- **Better Logging**: 
  - Detailed client type identification in debug messages
  - Shows exact WoW version being used (e.g., "Classic Era", "TBC Classic", "Midnight 12.0.1+")
  - Interface version displayed in all log messages
- **Patch 12.0.0 Compatibility**: Ready for Secret Values system introduced in Midnight expansion

### Technical Changes
- Added version compatibility constants for all WoW variants (IS_RETAIL, IS_CLASSIC, IS_TBC, IS_WRATH, IS_CATA)
- Improved hook initialization with pcall error protection
- Enhanced version string generation for different client types
- Updated comments to reflect Patch 12.0.0/12.0.1 API changes

---

## Version 3.4.1 (19.11.2022)
- Added AceDB-3.0

## Version 3.4.0 (15.11.2022)
- Updated TOC for prepatch 2

## Version 3.3.5 (14.11.2022)
- Re-added all libs to prevent errors

## Version 3.3.4 (31.10.2022)
- Removed space after Name
