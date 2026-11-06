## 📋 Summary

<!-- Briefly describe what this Pull Request changes, adds, or fixes -->

Closes #<!-- issue number, if applicable -->

## 🔄 Type of Change

- [ ] 🐛 **Bug fix** (non-breaking change that fixes an issue)
- [ ] ✨ **New feature** (non-breaking change that adds functionality)
- [ ] 🛡️ **Taint / Combat Lockdown / Secret Value fix** (Retail 12.0+ / M+ / Encounter safety)
- [ ] 🌍 **Localization update** (`lang/*.lua` synchronization)
- [ ] 📦 **TOC / Client version update** (`Name2Chat.toc` / `ChatCompat.lua` / CI workflows)

## 🎮 Tested / Targeted WoW Versions

- [ ] **Retail** (*Midnight* / *The War Within* – `120100` / `120001` / `110207`)
- [ ] **Mists of Pandaria Classic** (`50504` / `50503`)
- [ ] **Cataclysm Classic** (`40402`)
- [ ] **Wrath of the Lich King Classic** (`30405` / `38002`)
- [ ] **Burning Crusade Classic / Anniversary** (`20506` / `20505`)
- [ ] **World of Warcraft: Forever** (`16001`)
- [ ] **Classic Era / Hardcore / SoD** (`11509` / `11508`)

## ✅ Checklist

- [ ] Code passes `luacheck --no-color --codes ChatCompat.lua Name2Chat.lua` without warnings or errors
- [ ] Chat hooks respect combat/encounter/Mythic+ restrictions (`ChatCompat:IsChatRestricted`, `C_ChatInfo.InChatMessagingLockdown`, `issecretvalue`) and do not cause `ADDON_ACTION_FORBIDDEN` taint
- [ ] Slash commands (`/reload`, `/w`, `/n2c`, etc.) and `!` commands are not accidentally prefixed
- [ ] If new locale keys (`L["..."]`) were added, all 11 locale files in `lang/*.lua` have been updated
- [ ] `CHANGELOG.md` has been updated under the current/upcoming version section

