---------------------------------------------------------------------
-- ChatCompat.lua
-- Abstraction layer for Retail / Classic Chat APIs
-- Updated for Patch 12.0.0 (Midnight)
-- 
-- Purpose:
-- Unifies access to Chat APIs across all WoW versions
-- (Retail 12.0+, Classic Era, Burning Crusade, Wrath, Cataclysm)
---------------------------------------------------------------------

local ChatCompat = {}

---------------------------------------------------------------------
-- API Detection
---------------------------------------------------------------------
local function detectApi()
    -- Since 12.0.0, always use C_ChatInfo.SendChatMessage
    -- The old global SendChatMessage is deprecated but still available via fallback
    local hasCChatInfo = type(C_ChatInfo) == "table"
        and type(C_ChatInfo.SendChatMessage) == "function"

    -- INSTANCE_CHAT is available in Retail and Wrath+
    local supportsInstanceChat = ChatTypeInfo and ChatTypeInfo["INSTANCE_CHAT"] ~= nil

    return {
        useCChatInfo = hasCChatInfo,
        supportsInstanceChat = supportsInstanceChat,
    }
end

ChatCompat.api = detectApi()

---------------------------------------------------------------------
-- Unified SendChatMessage Wrapper
-- Sends a message via the correct API endpoint
-- 
-- Note: SendChatMessage is deprecated in Retail 12.0+ but still available
-- via Deprecated_ChatInfo.lua fallback. In Classic variants, it's the
-- primary API and not deprecated.
---------------------------------------------------------------------
function ChatCompat:Send(msg, chatType, language, channel)
    if self.api.useCChatInfo then
        -- Retail / Wrath Classic (12.0+: use C_ChatInfo.SendChatMessage)
        return C_ChatInfo.SendChatMessage(msg, chatType, language, channel)
    else
        -- Classic Era / Burning Crusade / Cataclysm Classic
        -- SendChatMessage is NOT deprecated in these versions
        return SendChatMessage(msg, chatType, language, channel)
    end
end

---------------------------------------------------------------------
-- Unified Hook Registration
-- AceHook-compatible
-- 
-- NOTE: Hooking SendChatMessage is problematic in modern WoW because
-- it's a protected function that can only be called by Blizzard code
-- in response to hardware events. Attempting to call it from within
-- a hook will trigger ADDON_ACTION_FORBIDDEN errors.
--
-- WARNING: Even hooking ChatEdit_SendText can cause issues in protected
-- environments (M+, raids, PvP) because calling the original function
-- will still trigger SendChatMessage internally.
-- 
-- PATCH 12.0.0 CHANGES:
-- - ChatEdit_SendText is now deprecated (but still available via fallback)
-- - New addon chat restrictions via CVar 'addonChatRestrictionsForced'
-- - New enum Enum.SendAddonMessageResult.AddOnMessageLockdown
-- - Event ADDON_RESTRICTION_STATE_CHANGED notifies when restrictions change
-- - "Secret Values" system can restrict addon operations on tainted paths
-- 
-- RECOMMENDED: Use direct text modification on the EditBox BEFORE 
-- ChatEdit_SendText is called. This is the most compatible approach:
-- 
-- Example:
--   local origChatEdit_SendText = ChatEdit_SendText
--   ChatEdit_SendText = function(editBox, addHistory)
--       -- Modify editBox:GetText() and editBox:SetText() here
--       origChatEdit_SendText(editBox, addHistory)
--   end
-- 
-- This function is kept for backwards compatibility but is not recommended.
-- addon = your AceAddon with RawHook method
---------------------------------------------------------------------
function ChatCompat:HookSendChatMessage(addon)
    if self.api.useCChatInfo then
        -- Retail / Wrath Classic: Hook the C_ChatInfo.SendChatMessage
        addon:RawHook(C_ChatInfo, "SendChatMessage", true)
    else
        -- Classic Era / TBC / Cata: Hook the global SendChatMessage
        addon:RawHook("SendChatMessage", true)
    end
end

---------------------------------------------------------------------
-- Unified Unhook
---------------------------------------------------------------------
function ChatCompat:UnhookSendChatMessage(addon)
    if self.api.useCChatInfo then
        addon:Unhook(C_ChatInfo, "SendChatMessage")
    else
        addon:Unhook("SendChatMessage")
    end
end

---------------------------------------------------------------------
-- Helper: Is this chat type supported by this version?
-- 
-- Uses config to check if the chat type is enabled
-- Considers Classic limitations (e.g., no INSTANCE_CHAT)
---------------------------------------------------------------------
function ChatCompat:IsSupportedChatType(chatType, config)
    if chatType == "SAY" and config.say then return true end
    if chatType == "YELL" and config.yell then return true end
    if chatType == "WHISPER" and config.whisper then return true end
    if chatType == "GUILD" and config.guild then return true end
    if chatType == "OFFICER" and config.officer then return true end
    if chatType == "PARTY" and config.party then return true end
    if chatType == "RAID" and config.raid then return true end
    if chatType == "PARTY_LEADER" and config.party_leader then return true end
    if chatType == "RAID_LEADER" and config.raid_leader then return true end
    if chatType == "RAID_WARNING" and config.raid_warning then return true end

    -- INSTANCE_CHAT only on Retail/Wrath+
    if chatType == "INSTANCE_CHAT" and config.instance_chat and self.api.supportsInstanceChat then
        return true
    end

    return false
end

---------------------------------------------------------------------
-- Info: API Details (Debug)
---------------------------------------------------------------------
function ChatCompat:GetApiInfo()
    return {
        useCChatInfo = self.api.useCChatInfo,
        supportsInstanceChat = self.api.supportsInstanceChat,
    }
end

---------------------------------------------------------------------
-- Registration as LibStub for other addons
---------------------------------------------------------------------
local MAJOR, MINOR = "ChatCompat", 1
local ChatCompatLib = LibStub:NewLibrary(MAJOR, MINOR)

if not ChatCompatLib then return end

-- Copy all functions to the library table
for k, v in pairs(ChatCompat) do
    ChatCompatLib[k] = v
end

return ChatCompatLib
