---------------------------------------------------------------------
-- ChatCompat.lua
-- Abstraction layer for Retail / Classic Chat APIs
-- GitHub Copilot understands this structure very well
-- 
-- Purpose:
-- Unifies access to Chat APIs across all WoW versions
-- (Retail, Wrath Classic, Classic Era, Burning Crusade, Cataclysm)
---------------------------------------------------------------------

local ChatCompat = {}

---------------------------------------------------------------------
-- API Detection
---------------------------------------------------------------------
local function detectApi()
    -- Retail and Wrath Classic use C_ChatInfo
    local hasCChatInfo = type(C_ChatInfo) == "table"
        and type(C_ChatInfo.SendChatMessage) == "function"

    -- INSTANCE_CHAT is only available in Retail and Wrath+
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
---------------------------------------------------------------------
function ChatCompat:Send(msg, chatType, language, channel)
    if self.api.useCChatInfo then
        -- Retail / Wrath Classic
        return C_ChatInfo.SendChatMessage(msg, chatType, language, channel)
    else
        -- Classic Era / Burning Crusade / Cataclysm Classic
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
-- RECOMMENDED: Use HookScript on ChatEditBox "OnEnterPressed" instead.
-- This allows you to modify the text BEFORE the send process begins,
-- avoiding all protected function issues.
-- 
-- Example:
--   editBox:HookScript("OnEnterPressed", function(self)
--       local text = self:GetText()
--       self:SetText(modifiedText)
--   end)
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
