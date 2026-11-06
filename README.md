# Name2Chat

Name2Chat is a maintained fork of the classic *Incognito* addon, completely modernized for **all** current World of Warcraft versions:
- **Retail** (*Midnight* / *The War Within*)
- **Mists of Pandaria Classic**
- **Cataclysm Classic**
- **Wrath of the Lich King Classic**
- **Burning Crusade Classic / Anniversary**
- **World of Warcraft: Forever** (`16001`)
- **Classic Era / Hardcore / Season of Discovery**

Name2Chat automatically adds your configured name in front of your outgoing chat messages. It can be enabled individually for Guild (and Officer), Party, Raid, Instance, and custom channels, and also works inside the **Guild & Communities (`J`)** window.

**Example:**
```text
[Guild] [YourChar]: Some chat message
```
becomes:
```text
[Guild] [YourChar]: (YourName): Some chat message
```

## Usage
You can use the in-game GUI configuration dialog (`ESC -> Options -> AddOns -> Name2Chat`) or the slash commands `/name2chat` or `/n2c`.

### Slash Commands
- `/n2c config` – Open configuration dialog
- `/n2c enable` – Enable or disable adding your name to chat messages
- `/n2c name <Name>` – Set the name that should be displayed in your chat messages

### GUI Options
- **Enable** – Enable adding your name to chat messages
- **Name** – The name that should be displayed in your chat messages
- **Guild** – Add name to guild and officer chat messages (`/g`, `/o`, and Guild & Communities window `J`)
- **Party** – Add name to party chat messages (`/p`)
- **Raid** – Add name to raid chat messages (`/raid`)
- **Instance** – Add name to instance chat messages, e.g., LFR and battlegrounds (`/i`)
- **Channel** – Add name to chat messages in custom channel(s) (supports comma-separated channel names)
- **Hide name if it matches your character's name** – Skip adding the prefix when playing on the character with that exact name
- **Ignore adding name to messages starting with !** – Skip adding the prefix for addon commands like `!keys`
- **Add name in combat** – Also add your name while in combat when the client reports chat messaging is unlocked (automatically skipped during Boss Encounters and Mythic+)
- **Show guild note for players without the addon** – On received guild/officer messages without a `(Name): ` prefix, display the sender's public guild note locally in front of the message
- **Debug** – Enable debugging message output

## Features and Bugs
If you have a feature request or find a bug, please use the [GitHub Issue Tracker](https://github.com/gOOvER/Name2Chat/issues) to report it.

## Download
- **GitHub:** https://github.com/gOOvER/Name2Chat/releases/latest
- **CurseForge:** https://www.curseforge.com/wow/addons/name2chat
- **Wago.io:** https://addons.wago.io/addons/name2chat
- **WoWInterface:** https://www.wowinterface.com/downloads/info24357-Name2Chat.html

## Buy me a Coffee
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/B0B351D0Q)
