# Name2Chat Changelog

## Version 4.0.3 (23.02.2026)

### Bug Fixes
- **Addon not loading / Names not showing (4.0.3-beta1 issues)**: Fixed critical bugs in beta release
  - OnEnterPressed hook was running too late (post-hook instead of pre-hook)
  - Text modification was happening after message was already processed
  - Reverted to proper `ChatEdit_SendText` pre-hook approach
  - Messages now correctly show names in all chat types including Guild chat with XFaction
  - Addon now loads properly and all features work as expected

### Patch 12.0.0 (Midnight) Compatibility
- **Updated for WoW Patch 12.0.0 API changes**:
  - Updated ChatCompat documentation for deprecated APIs
  - Added support for new `ADDON_RESTRICTION_STATE_CHANGED` event
  - Added monitoring for `addonChatRestrictionsForced` CVar
  - Enhanced error handling to work with new "Secret Values" system
  - Added pcall protection around chat modification code
  - ChatEdit_SendText is now deprecated but still functional via fallback

### Improvements
- **Enhanced Error Handling**: Added comprehensive error protection
  - pcall wrapping for chat message modification
  - Graceful degradation if ChatEdit_SendText is missing
  - Safe CVar checking for cross-version compatibility
- **Better User Feedback**: Warns users if addon chat restrictions are enforced
- **Cross-Version Support**: Continues to work on all WoW versions (Retail 12.0+, Classic variants)

### Technical Changes
- **HookChatSendFunction()**: Enhanced with existence checks and error handling
- **ModifyChatMessage()**: Simplified chat type detection, removed ChatCompat dependency for basic checks
- **OnAddonRestrictionChanged()**: New event handler for Patch 12.0.0 chat restrictions
- Direct chat type checks instead of ChatCompat:IsSupportedChatType
- More reliable hook timing ensures text modification happens at the right moment

---

## Version 4.0.2 (27.01.2026)

### New Features
- **ChatCompat Abstraction Layer**: New mini-library for unified Chat API management
  - Automatic feature detection for Retail/Classic APIs
  - Centralized handling of all version differences
  - Reusable for other addons via LibStub

### Bug Fixes
- **SendChatMessage Hook Recursion**: Prevented re-entrance that caused "script ran too long" errors when sending chat messages
  - Calls the stored original API instead of the hooked wrapper
  - Fixes execution stall on message send across all supported clients
- **ChatCompat LibStub Registration**: Fixed critical error "attempt to call method 'HookSendChatMessage' (a nil value)"
  - Corrected LibStub registration mechanism in `ChatCompat.lua`
  - Proper function copying to library table
  - Addon now loads correctly on all WoW versions

### Improvements
- **Code Refactoring**: Use of ChatCompat for clean API abstraction
  - Removal of redundant Retail/Classic checks
  - Simplified hook mechanism
  - Better maintainability and readability
- **TOC Format Update**: Consolidated to modern single-interface format (Patch 10.2.7+)
  - Added `LoadSavedVariablesFirst`
  - Added `AllowAddOnTableAccess` for C_AddOns compatibility
- **Documentation**: Thorough commenting for Copilot-friendly structure

### Technical Changes
- New file: `ChatCompat.lua` for API abstraction layer
- Updated `Name2Chat.lua` to use ChatCompat
- Updated `embeds.xml` to load ChatCompat
- Simplified hook management via `ChatCompat:HookSendChatMessage()`

---

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
