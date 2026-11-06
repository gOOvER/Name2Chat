# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2026-11-06

### Added
- **Universal 4-Tier Multi-Client Hook Architecture**:
  - **Tier 1 (`EventRegistry`)**: Feature-detects `ChatFrameEditBoxMixin.OnPreSendText` (in addition to `tocVersion >= 120000` and WoW Forever `16001`, [#40](https://github.com/gOOvER/Name2Chat/issues/40)) to register `ChatFrame.OnEditBoxPreSendText`.
  - **Tier 2 (`ChatFrameEditBoxMixin.SendText`)**: Hooks both `ChatFrameEditBoxMixin.SendText` and all already-created `ChatFrame1EditBox`–`ChatFrameN` frames so XML `Mixin()` copies made prior to addon load are updated.
  - **Tier 3 (`ChatEdit_SendText`)**: Hooks global `ChatEdit_SendText` for Classic Era 1.15.8 ([#35](https://github.com/gOOvER/Name2Chat/issues/35)) and TBC Anniversary 2.5.5 ([#36](https://github.com/gOOvER/Name2Chat/issues/36)) clients where `ChatFrameEditBoxMixin` does not exist.
  - **Tier 4 (`ChatCompat:HookSendChatMessage`)**: Direct `C_ChatInfo.SendChatMessage` / `SendChatMessage` hook as final safety fallback.
- **Guild & Communities Window (`J`) Support ([#38](https://github.com/gOOvER/Name2Chat/issues/38))**:
  - Hooks `CommunitiesFrame.Chat:SendMessage` and `CommunitiesFrame.ChatEditBox` (on load and via `ADDON_LOADED` for `Blizzard_Communities`) and handles `COMMUNITIES_CHANNEL` in `ModifyChatMessage()` so messages typed in the Guild/Communities panel (`J`) or linked Community chat tabs properly receive your name prefix.
- **Mythic+ Keystone & Active Boss Encounter Protection ([#37](https://github.com/gOOvER/Name2Chat/issues/37), [PR #39](https://github.com/gOOvER/Name2Chat/pull/39))**:
  - Added checks for `C_ChallengeMode.IsChallengeModeActive()`, `C_InstanceEncounter.IsEncounterInProgress()`, `IsEncounterInProgress()`, and `C_ChatInfo.InChatMessagingLockdown()` so chat messages are never tainted or blocked during Mythic+ runs or while dead during an active boss encounter.
- **World of Warcraft: Forever Support & Features ([#40](https://github.com/gOOvER/Name2Chat/issues/40))**:
  - Added Interface `16001` (`## Interface-Forever: 16001`) and latest Retail/Classic interface versions (`120100`, `120007`, `120005`, `50504`, `20506`) to `Name2Chat.toc`, CI workflows, and release notes.
  - Added feature detection for `ChatFrameEditBoxMixin:OnPreSendText()` and `IsSecretValue` guards on `UnitName("player")`.
  - Added **"Add name in combat"** (`combat`) option: allows adding the name in combat when `C_ChatInfo.InChatMessagingLockdown()` explicitly reports `false` (outside Boss Encounters and Mythic+).
  - Added **"Show guild note for players without the addon"** (`guildNote`) option: local display filter for incoming guild/officer messages that prepends the sender's public guild note when they don't use Name2Chat.
  - Reorganized the Options panel into clean sections (*General*, *Chat channels*, *Behaviour*, *Received messages*, *Advanced*) with full-width toggles while preserving 100% compatibility with existing `Name2ChatDB` settings.
- **Multi-Channel Custom Channel Support**: The `channel` option now supports comma- or semicolon-separated channel names (e.g. `Channel1, Channel2`), Community stream names, and channel numbers with automatic whitespace trimming.
- **Full Multi-Version TOC Metadata**: Added explicit per-flavor TOC directives (`Interface-Retail`, `Interface-Mists`, `Interface-Cata`, `Interface-Wrath`, `Interface-BCC`, `Interface-Classic`) and localized `Notes-*` entries for all 11 supported languages.
- **Complete Localization Coverage**: Added missing locale strings (`debug_combat_lockdown`, `debug_mythic_plus`, `debug_slash_command`, `debug_already_prefixed`, `debug_msg_too_long`, `hook_active_chatedit`, `hook_active_communities`) across all 11 locale files (`enUS`, `deDE`, `esES`, `esMX`, `frFR`, `itIT`, `koKR`, `ptBR`, `ruRU`, `zhCN`, `zhTW`).

### Changed
- **Clean Login Output**: Changed hook activation status messages (`hook_active_eventregistry`, `hook_active_mixin`, `hook_active_chatedit`, `hook_active_communities`) from `Print` to `Safe_Print` so chat is no longer spammed on every login or `/reload` when Debug mode is disabled.
- **Modernized `ChatCompat` (v4)**: Integrated `ChatCompat` directly into `Name2Chat.lua` with `IsSecretValue()`, `IsEncounterActive()`, `IsMythicPlusActive()`, `GetChatMessagingLockdownState()`, `IsChatMessagingLockedDown()`, and `IsChatRestricted()` helpers.
- **Updated GitHub Actions & BigWigs Packager Config**:
  - Updated `actions/checkout` (`v4` → `v7`), `actions/upload-artifact` (`v4` → `v7`), `actions/download-artifact` (`v4` → `v8`), and `softprops/action-gh-release` (`v2` → `v3`).
  - Updated `BigWigsMods/packager@v2` (`v2.7.0`) integration to use non-deprecated `CF_API_TOKEN` / `GH_API_TOKEN` environment variables (with automatic fallback to `CF_API_KEY`), added `include-hidden-files: true` for `.release/*.zip` artifact upload, and configured `enable-toc-creation: yes` and `markup-type: markdown` for `CHANGELOG.md` in `.pkgmeta`.
  - Added project-specific GitHub Issue Forms (`bug_report.yml`, `feature_request.yml`, `config.yml`) and Pull Request template (`PULL_REQUEST_TEMPLATE.md`).
- **Case-Insensitive Character Name Matching**: `hideOnMatchingCharName` now compares character names case-insensitively and initializes `character_name` immediately on load/reload via `GetCharacterName()`.
- **Leader Chat Type Support**: Added `PARTY_LEADER`, `RAID_LEADER`, and `INSTANCE_CHAT_LEADER` handling alongside `PARTY`, `RAID`, and `INSTANCE_CHAT`.

### Fixed
- **Classic Era 1.15.8 & TBC Anniversary 2.5.5 "No hook entry point found" ([#35](https://github.com/gOOvER/Name2Chat/issues/35), [#36](https://github.com/gOOvER/Name2Chat/issues/36))**: Fixed silent failure on Classic 1.15.8 and TBC Anniversary where `ChatFrameEditBoxMixin` was absent and no fallback to `ChatEdit_SendText` / `SendChatMessage` existed.
- **Chat Blocked in Mythic+ & During Boss Encounters ([#37](https://github.com/gOOvER/Name2Chat/issues/37), [PR #39](https://github.com/gOOvER/Name2Chat/pull/39))**: Fixed `ADDON_ACTION_FORBIDDEN` taint in Mythic+ keystone dungeons and when dead while a boss encounter is still in progress.
- **Guild & Communities Panel (`J`) Not Adding Name ([#38](https://github.com/gOOvER/Name2Chat/issues/38))**: Fixed messages typed in the Guild & Communities window (`J`) bypassing the main chat edit box hook.
- **Slash Commands & Whispers Leaking to Chat on Classic (Critical)**: Fixed a critical bug in non-`EventRegistry` hooks where typing any slash command (`/reload`, `/n2c`, `/afk`, `/w`, etc.) while an active channel like Guild chat was sticky caused `Name2Chat` to prepend `(Name): ` before `ParseText(1)` ran, turning slash commands and whispers into public Guild/Party/Raid messages.
- **Double-Prefixing from Chat History**: Fixed an issue where recalling a previously sent message via `Alt+Up` in the chat edit box prepended `(Name): ` a second time.
- **255-Byte Chat Limit & Hyperlink Truncation**: Added a 255-byte length guard (`MAX_CHAT_BYTES`) so long messages or trailing item/keystone hyperlinks (`|H...|h`) are never truncated or rejected by `SendChatMessage`.
- **Missing `ChatCompat.lua` in Release Fallback Packaging**: Added `ChatCompat.lua` to manual and emergency packaging steps in `.github/workflows/release.yml` and to `luacheck` in `.luacheckrc`, `quality.yml`, and `test.yml`.
- **Legacy Addon Name in `enUS.lua`**: Fixed leftover reference to `"Incognito"` in `hideOnMatchingCharName_desc`.

### Security
- **Slash Command & Whisper Leak Prevention**: Explicitly blocks prefixing any message starting with `/` (`StartsWithSlash`) and resolves `/w` / `/s` channel switches prior to inspection.
- **Patch 12.0.0 Secret Values Protection**: Added `issecretvalue` guards (`ChatCompat:IsSecretValue`) for `editBox:GetText()`, `chatType`, and `channelTarget` to prevent taint/secret value errors in Retail 12.0+.
- **GitHub Actions Hardening**: Added least-privilege `permissions: contents: read` to `quality.yml` and `test.yml`, and moved workflow dispatch inputs in `release.yml` to `env:` variables to prevent shell script injection.

### Removed
- **Unused External Libraries in `.pkgmeta`**: Removed `AceSerializer-3.0`, `AceTab-3.0`, `AceTimer-3.0`, and `AceComm-3.0` from `.pkgmeta` to match `embeds.xml` and reduce release archive size.

---

## Version 4.0.4 (25.02.2026)

### Bug Fixes
- **Classic HC realms / Classic Era 1.15.x broken after 4.0.3**: Classic clients (e.g. 1.15.8) have `EventRegistry` backported but do **not** fire the `ChatFrame.OnEditBoxPreSendText` event — that event is exclusive to Retail Patch 12.0.0 (Midnight/TWW). Because the old `if EventRegistry then` check was satisfied, the `ChatFrameEditBoxMixin.SendText` fallback was never reached and the hook was completely silent. Fixed by gating the `EventRegistry` path on `GetBuildInfo()` interface version ≥ 120000. Classic clients now correctly use the `ChatFrameEditBoxMixin.SendText` hook.

---

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
