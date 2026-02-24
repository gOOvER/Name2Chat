# Name2Chat Changelog

## Version 4.0.3 (24.02.2026)

### Bug Fixes
- **Chat blocked during combat (ADDON_ACTION_FORBIDDEN)**: When the player was in combat lockdown (raid, M+, PvP zones), calling `editBox:SetText()` inside the `ChatFrame.OnEditBoxPreSendText` callback tainted the protected `SendChatMessage()` call that followed — causing the Blizzard combat popup to appear and the message to be fully blocked (issue [#33](https://github.com/gOOvER/Name2Chat/issues/33))
  - **Fix**: Added an `InCombatLockdown()` check at the start of `ModifyChatMessage()`. During combat the function returns immediately without touching the EditBox, so the message is sent as-is (without name prefix) without any error
  - **Trade-off**: The name prefix cannot be added during combat — this is an unavoidable Blizzard engine restriction that affects all chat-modifying addons (e.g., Prat) since Midnight/TWW
- **Raid chat inside instances not working**: In WoW instances (raids, LFR, battlegrounds), `/raid` chat is routed by the game as `INSTANCE_CHAT` instead of `RAID`. Enabling "Raid" in the addon settings now also covers `INSTANCE_CHAT` automatically.
- **Officer chat (`/o`) not covered**: Added explicit handling for `OFFICER` chat type under the guild setting (which already documented `/g and /o` in its description).
- **Name not being prepended to messages (critical fix)**: Found and resolved root cause
  - Previous approaches (`ChatEdit_SendText`, `ChatFrameEditBoxMixin.SendText`) were bypassed because Blizzard completely rearchitected the chat send path in Patch 12.0.0
  - The correct hook point is now `EventRegistry:RegisterCallback("ChatFrame.OnEditBoxPreSendText", ...)`
  - Blizzard included this event **explicitly for addons**: *"Notification for user addons to perform any final edits to chat text contents before sending."* (source: `ChatFrameEditBox.lua` in `Blizzard_ChatFrameBase`)
  - The event fires **after** `ParseText()` (chatType already resolved, e.g. `/g` → `"GUILD"`) but **before** `GetText()` is called for the send — so `SetText()` still affects the outgoing message
  - Hook confirmation `Name2Chat: Hook active (ChatFrame.OnEditBoxPreSendText)` is always printed on load

### Patch 12.0.0 (Midnight) Compatibility
- **Updated for WoW Patch 12.0.0 API changes**:
  - `ChatEdit_SendText` is now a deprecated alias only loaded when `loadDeprecationFallbacks` CVar is set — no longer reliable as a hook target
  - Added support for new `ADDON_RESTRICTION_STATE_CHANGED` event
  - Added monitoring for `addonChatRestrictionsForced` CVar
  - Enhanced error handling to work with the new "Secret Values" system
  - Added `pcall` protection around chat modification code

### Improvements
- **Enhanced Error Handling**: Added debug output at every decision point in `ModifyChatMessage()` — disabled/empty name/unsupported chat type are all now logged when debug mode is active
- **Better User Feedback**: Warns if addon chat restrictions are enforced
- **Cross-Version Support**: Works on all WoW versions (Retail 12.0+, Classic variants) via EventRegistry primary hook and `ChatFrameEditBoxMixin.SendText` fallback

### Localization
- **All hardcoded strings moved to AceLocale-3.0**: Every visible string (UI labels, debug messages, status output) is now fully localized
- **Translations added for all supported languages**: deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW
- **Note**: All translations except `enUS` are AI-generated and may contain inaccuracies. Community corrections are welcome via CurseForge or the GitHub repository.

### Technical Changes
- `HookChatSendFunction()`: Switched primary hook to `EventRegistry` callback; `ChatFrameEditBoxMixin.SendText` kept as fallback for Classic/older clients
- `ModifyChatMessage()`: Added `Safe_Print` debug output at every early-return and decision point
- `OnAddonRestrictionChanged()`: New event handler for Patch 12.0.0 chat restrictions
- Removed unused libraries from `embeds.xml`: `AceComm-3.0`, `AceSerializer-3.0`, `AceTab-3.0`, `AceTimer-3.0`

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
