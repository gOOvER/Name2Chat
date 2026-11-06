---------------------------------------------------------------------
-- ChatCompat.lua
-- Abstraction layer for Retail / Classic / Forever Chat APIs
-- Updated for Patch 12.0.x (Midnight), Classic flavors, and WoW Forever
--
-- Purpose:
-- Unifies access to Chat APIs, restriction checks, and version detection
-- across all WoW versions (Retail 12.0+, MoP, Cata, Wrath, TBC, Classic Era, Forever)
---------------------------------------------------------------------

local ChatCompat = {}

---------------------------------------------------------------------
-- Version & API Detection
---------------------------------------------------------------------
local function detectApi()
	local _, _, _, tocVersion = GetBuildInfo()
	tocVersion = tonumber(tocVersion) or 0

	-- Since 12.0.0, always use C_ChatInfo.SendChatMessage
	-- The old global SendChatMessage is deprecated in Retail 12.0+
	local hasCChatInfo = type(C_ChatInfo) == "table"
		and type(C_ChatInfo.SendChatMessage) == "function"

	-- ChatFrame.OnEditBoxPreSendText was introduced in Retail Patch 12.0.0
	-- and is triggered by ChatFrameEditBoxMixin:OnPreSendText().
	-- Classic 1.15.x has EventRegistry backported without OnPreSendText(),
	-- whereas WoW Forever (interface 16001) runs the modern 12.x UI with OnPreSendText().
	local hasOnPreSendTextMethod = type(ChatFrameEditBoxMixin) == "table"
		and type(ChatFrameEditBoxMixin.OnPreSendText) == "function"
	local isForever = tocVersion >= 16000 and tocVersion < 20000
	local hasPreSendTextEvent = (hasOnPreSendTextMethod or isForever or tocVersion >= 120000)
		and type(EventRegistry) == "table"
		and type(EventRegistry.RegisterCallback) == "function"

	-- INSTANCE_CHAT is available in Retail and MoP/Cata/Wrath/modern Classic clients
	local supportsInstanceChat = (ChatTypeInfo and ChatTypeInfo["INSTANCE_CHAT"] ~= nil)
		or tocVersion >= 30400
		or isForever

	return {
		tocVersion = tocVersion,
		isRetail120Plus = tocVersion >= 120000,
		isForever = isForever,
		useCChatInfo = hasCChatInfo,
		hasPreSendTextEvent = hasPreSendTextEvent,
		supportsInstanceChat = supportsInstanceChat,
	}
end

ChatCompat.api = detectApi()

---------------------------------------------------------------------
-- Secret Value & Restriction Helpers (Patch 12.0.0+ / Forever / M+ / Encounters)
---------------------------------------------------------------------

-- Returns true if the given value is a Patch 12.0.0+ / Forever "Secret Value"
-- that cannot be compared or concatenated by addon code without error.
function ChatCompat:IsSecretValue(val)
	if val ~= nil and type(issecretvalue) == "function" then
		local ok, result = pcall(issecretvalue, val)
		if ok and result then
			return true
		end
	end
	return false
end

-- Returns true if an instance boss encounter is currently in progress.
-- Even when a player is dead and released (InCombatLockdown() == false),
-- WoW still enforces chat taint restrictions during active boss encounters (#37, PR #39).
function ChatCompat:IsEncounterActive()
	if C_InstanceEncounter and type(C_InstanceEncounter.IsEncounterInProgress) == "function" then
		local ok, inProgress = pcall(C_InstanceEncounter.IsEncounterInProgress)
		if ok and not self:IsSecretValue(inProgress) and inProgress then
			return true
		end
	end
	if type(IsEncounterInProgress) == "function" then
		local ok, inProgress = pcall(IsEncounterInProgress)
		if ok and not self:IsSecretValue(inProgress) and inProgress then
			return true
		end
	end
	return false
end

-- Returns true if a Mythic+ Challenge Mode keystone timer is currently active (#37, PR #39).
function ChatCompat:IsMythicPlusActive()
	if C_ChallengeMode and type(C_ChallengeMode.IsChallengeModeActive) == "function" then
		local ok, active = pcall(C_ChallengeMode.IsChallengeModeActive)
		if ok and not self:IsSecretValue(active) and active then
			return true
		end
	end
	return false
end

-- Returns true if Blizzard's chat messaging lockdown is active, false if explicitly unlocked,
-- or nil if the client does not provide C_ChatInfo.InChatMessagingLockdown.
function ChatCompat:GetChatMessagingLockdownState()
	if C_CVar and type(C_CVar.GetCVarBool) == "function" then
		local ok, isForced = pcall(C_CVar.GetCVarBool, "addonChatRestrictionsForced")
		if ok and not self:IsSecretValue(isForced) and isForced then
			return true
		end
	elseif type(GetCVarBool) == "function" then
		local ok, isForced = pcall(GetCVarBool, "addonChatRestrictionsForced")
		if ok and not self:IsSecretValue(isForced) and isForced then
			return true
		end
	end
	if C_ChatInfo and type(C_ChatInfo.InChatMessagingLockdown) == "function" then
		local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
		if ok and not self:IsSecretValue(locked) then
			return locked and true or false
		end
	end
	return nil
end

-- Returns true if Blizzard's chat messaging lockdown is active (Patch 12.0.0+ / Forever).
function ChatCompat:IsChatMessagingLockedDown()
	return self:GetChatMessagingLockdownState() == true
end

-- Returns true (and a reason key) if addon chat modifications are currently restricted.
-- When allowInCombat is true (WoW Forever / 12.0+ option), combat is allowed ONLY if
-- outside boss encounters & M+ AND C_ChatInfo.InChatMessagingLockdown() explicitly returns false.
function ChatCompat:IsChatRestricted(allowInCombat)
	if self:IsEncounterActive() then
		return true, "encounter"
	end
	if self:IsMythicPlusActive() then
		return true, "mythic_plus"
	end
	local lockdownState = self:GetChatMessagingLockdownState()
	if lockdownState == true then
		return true, "lockdown"
	end
	if InCombatLockdown and InCombatLockdown() then
		if not allowInCombat then
			return true, "combat"
		end
		if lockdownState ~= false then
			return true, "combat_chat_lockdown"
		end
	end
	return false, nil
end

---------------------------------------------------------------------
-- Unified SendChatMessage Wrapper
-- Sends a message via the correct API endpoint
---------------------------------------------------------------------
function ChatCompat:Send(msg, chatType, language, channel)
	if self.api.useCChatInfo then
		return C_ChatInfo.SendChatMessage(msg, chatType, language, channel)
	elseif type(SendChatMessage) == "function" then
		return SendChatMessage(msg, chatType, language, channel)
	end
end

---------------------------------------------------------------------
-- Direct SendChatMessage Hook Registration (Fallback / Legacy)
---------------------------------------------------------------------
function ChatCompat:HookSendChatMessage(addon)
	if not addon or type(addon.RawHook) ~= "function" then return end
	if self.api.useCChatInfo then
		addon:RawHook(C_ChatInfo, "SendChatMessage", true)
	else
		addon:RawHook("SendChatMessage", true)
	end
end

function ChatCompat:UnhookSendChatMessage(addon)
	if not addon or type(addon.Unhook) ~= "function" then return end
	if self.api.useCChatInfo then
		addon:Unhook(C_ChatInfo, "SendChatMessage")
	else
		addon:Unhook("SendChatMessage")
	end
end

---------------------------------------------------------------------
-- Helper: Is this chat type supported by this version and config?
---------------------------------------------------------------------
function ChatCompat:IsSupportedChatType(chatType, config)
	if not chatType or not config or self:IsSecretValue(chatType) then
		return false
	end

	if chatType == "SAY" and config.say then return true end
	if chatType == "YELL" and config.yell then return true end
	if chatType == "WHISPER" and config.whisper then return true end
	if (chatType == "GUILD" or chatType == "OFFICER") and (config.guild or config.officer) then return true end
	if (chatType == "PARTY" or chatType == "PARTY_LEADER") and (config.party or config.party_leader) then return true end
	if (chatType == "RAID" or chatType == "RAID_LEADER") and (config.raid or config.raid_leader) then return true end
	if chatType == "RAID_WARNING" and config.raid_warning then return true end

	-- INSTANCE_CHAT is used inside instances/battlegrounds/LFR (routes /i and often /raid)
	if (chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER")
		and (config.instance_chat or config.raid)
	then
		return true
	end

	return false
end

---------------------------------------------------------------------
-- Info: API Details (Debug)
---------------------------------------------------------------------
function ChatCompat:GetApiInfo()
	return {
		tocVersion = self.api.tocVersion,
		isRetail120Plus = self.api.isRetail120Plus,
		isForever = self.api.isForever,
		useCChatInfo = self.api.useCChatInfo,
		hasPreSendTextEvent = self.api.hasPreSendTextEvent,
		supportsInstanceChat = self.api.supportsInstanceChat,
	}
end

---------------------------------------------------------------------
-- Registration as LibStub for Name2Chat and other addons
---------------------------------------------------------------------
if LibStub then
	local MAJOR, MINOR = "ChatCompat", 4
	local ChatCompatLib = LibStub:NewLibrary(MAJOR, MINOR)

	if ChatCompatLib then
		for k, v in pairs(ChatCompat) do
			ChatCompatLib[k] = v
		end
		return ChatCompatLib
	end
	return LibStub(MAJOR, true)
end

return ChatCompat
