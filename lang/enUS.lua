local debug = false
--[===[@debug@
debug = true
--@end-debug@]===]

local L = LibStub("AceLocale-3.0"):NewLocale("Name2Chat", "enUS", true, debug)

L["channel"] = "Channel"
L["channel_desc"] = "Add name to chat messages in this custom channel."
L["config"] = "Configuration"
L["config_desc"] = "Open configuration dialog."
L["debug"] = "Debug"
L["debug_desc"] = "Enable debugging messages output. You probably don't want to enable this."
L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages."
L["guild"] = "Guild"
L["guild_desc"] = "Add name to guild chat messages (/g and /o)."
L["hideOnMatchingCharName"] = "Hide name if it matches your character's name"
L["hideOnMatchingCharName_desc"] = "If the name specified above matches your current character's name, Incognito will not add it again if this option is checked."
L["instance_chat"] = "Instance"
L["instance_chat_desc"] = "Add name to instance chat messages, e.g., LFR and battlegrounds (/i)."
L["Loaded"] = "Loaded."
L["name"] = "Name"
L["name_desc"] = "The name that should be displayed in your chat messages."
L["party"] = "Party"
L["party_desc"] = "Add name to party chat messages (/p)."
L["raid"] = "Raid"
L["raid_desc"] = "Add name to raid chat messages (/raid)."
L["ignoreExclamationMark"] = "Ignore adding name to messages starting with !"
L["ignoreExclamationMark_desc"] = "If a message begins with an exclamation mark (!), the name will not be added. This is useful for addon commands like !keys."

-- Status / warning messages
L["hook_active_eventregistry"] = "Hook active (ChatFrame.OnEditBoxPreSendText)"
L["hook_active_mixin"] = "Hook active (ChatFrameEditBoxMixin.SendText fallback)"
L["hook_error_no_entry"] = "ERROR: No hook entry point found."
L["hook_error_modify"] = "Error modifying chat message: "
L["warn_restrictions_enforced"] = "Warning: Addon chat restrictions are now enforced. Name2Chat functionality may be limited."
L["warn_restrictions_lifted"] = "Addon chat restrictions have been lifted."

-- Debug messages
L["debug_hook_fired"] = "ModifyChatMessage: hook fired"
L["debug_disabled"] = "ModifyChatMessage: addon is DISABLED, skipping"
L["debug_name_empty"] = "ModifyChatMessage: name is EMPTY, skipping"
L["debug_name_matches_char"] = "ModifyChatMessage: name matches character name and hideOnMatchingCharName is set, skipping"
L["debug_msg_empty"] = "ModifyChatMessage: message is empty, skipping"
L["debug_chattype"] = "ModifyChatMessage: chatType=%s, name=%s"
L["debug_should_add"] = "ModifyChatMessage: shouldAddName=%s"
L["debug_skip_exclamation"] = "ModifyChatMessage: skipping, message starts with ! (ignoreExclamationMark active)"
L["debug_modified"] = "ModifyChatMessage: OK -> %s"
L["debug_chattype_not_active"] = "ModifyChatMessage: chatType '%s' not in active channel list. guild=%s party=%s raid=%s"
