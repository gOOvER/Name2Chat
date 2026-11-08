<div align="center">
  <img src=".github/assets/social-banner.png" alt="Name2Chat Banner" width="100%" />

  # Name2Chat

  **Automatically Prepends Your Main Name or Alias to Outgoing Guild, Party, Raid, Instance & Custom Channel Messages!**

  [![Code Quality](https://github.com/gOOvER/Name2Chat/actions/workflows/quality.yml/badge.svg)](https://github.com/gOOvER/Name2Chat/actions/workflows/quality.yml)
  [![Release](https://github.com/gOOvER/Name2Chat/actions/workflows/release.yml/badge.svg)](https://github.com/gOOvER/Name2Chat/actions/workflows/release.yml)
  [![GitHub Release](https://img.shields.io/github/v/release/gOOvER/Name2Chat?include_prereleases&label=Version&color=brightgreen&logo=github)](https://github.com/gOOvER/Name2Chat/releases/latest)
  [![CurseForge](https://img.shields.io/badge/CurseForge-Name2Chat-f16436?logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/name2chat)
  [![Wago.io](https://img.shields.io/badge/Wago.io-Name2Chat-c1272d?logo=wagtail&logoColor=white)](https://addons.wago.io/addons/Qb6mWqGP)
  [![WoWInterface](https://img.shields.io/badge/WoWInterface-24357-0078d7)](https://www.wowinterface.com/downloads/info24357-Name2Chat.html)
  [![WoW Versions](https://img.shields.io/badge/WoW-Retail%20%7C%20MoP%20%7C%20Cata%20%7C%20Wrath%20%7C%20TBC%20%7C%20Classic%20%7C%20Forever-f8b700?logo=battle.net&logoColor=white)](#-supported-wow-versions)
  [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
  [![Support](https://img.shields.io/badge/Support-donate.goover.dev-ff69b4?logo=ko-fi&logoColor=white)](https://donate.goover.dev)
</div>

---

**Name2Chat** is a maintained and modernized evolution of the classic *Incognito* addon for **all** current World of Warcraft versions. It automatically prepends your configured main name or nickname in front of your outgoing chat messages across Guild, Officer, Party, Raid, Instance, Communities (`J`), and custom channels.

**Example:**
```text
[Guild] [YourAlt]: Hello everyone!
```
becomes:
```text
[Guild] [YourAlt]: (YourMainName): Hello everyone!
```

---

## 🎮 Supported WoW Versions

- **Retail** (*Midnight `12.x`* & *The War Within `11.2.x`*)
- **Mists of Pandaria Classic** (`5.5.x`)
- **Cataclysm Classic** (`4.4.x`)
- **Wrath of the Lich King Classic** (`3.4.x` / `3.8.x`)
- **Burning Crusade Classic / Anniversary** (`2.5.x`)
- **World of Warcraft: Forever** (`16001`)
- **Classic Era / Hardcore / Season of Discovery** (`1.15.x`)

---

## ✨ Key Features & Options

- **Channel Selection**: Enable or disable name prefixing individually for:
  - **Guild & Officer** (`/g`, `/o`, and the **Guild & Communities `J`** window)
  - **Party** (`/p`)
  - **Raid** (`/raid`)
  - **Instance** (`/i` — LFR, Dungeons, Battlegrounds)
  - **Custom Channels** (supports comma-separated channel names)
- **Smart Matching**: Option to **hide your name if it already matches your current character's name**.
- **Command Ignore (`!`)**: Option to skip prefixing messages starting with `!` (for addon commands such as `!keys`).
- **Safe Combat Handling**: Option to add your name in combat when the client allows chat modifications (automatically skipped during Boss Encounters and Mythic+ to prevent taint/restrictions).
- **Guild Note Fallback for Other Players**: Optionally display the public guild note of guildmates who do not use Name2Chat locally in front of their incoming Guild/Officer messages.

---

## ⌨️ Slash Commands

Use `/name2chat` or `/n2c`, or open `ESC -> Options -> AddOns -> Name2Chat`:

| Command | Description |
| :--- | :--- |
| `/n2c config` | Open the configuration dialog |
| `/n2c enable` | Toggle adding your name to chat messages |
| `/n2c name <Name>` | Set the name displayed in your chat messages |

---

## 📦 Download & Links

- **GitHub Releases**: [github.com/gOOvER/Name2Chat/releases/latest](https://github.com/gOOvER/Name2Chat/releases/latest)
- **CurseForge**: [curseforge.com/wow/addons/name2chat](https://www.curseforge.com/wow/addons/name2chat)
- **Wago.io**: [addons.wago.io/addons/name2chat](https://addons.wago.io/addons/name2chat)
- **WoWInterface**: [wowinterface.com/downloads/info24357-Name2Chat.html](https://www.wowinterface.com/downloads/info24357-Name2Chat.html)
- **Issue Tracker**: [github.com/gOOvER/Name2Chat/issues](https://github.com/gOOvER/Name2Chat/issues)

---

## 📜 Credits & Support

- **Author**: **gOOvER** ([goover.dev](https://www.goover.dev))
- **License**: [GNU General Public License v3.0 (GPL-3.0)](LICENSE)
- **Support Development**: [donate.goover.dev](https://donate.goover.dev) • [Ko-fi](https://ko-fi.com/oldnoob) • [Buy Me a Coffee](https://www.buymeacoffee.com/goover)
