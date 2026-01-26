------------------------
---      Module      ---
------------------------

Name2Chat = LibStub("AceAddon-3.0"):NewAddon("Name2Chat",
											"AceConsole-3.0",
											"AceEvent-3.0",
											"AceHook-3.0")

-- Version compatibility constants
-- Patch 12.0.0 (Midnight) introduces Secret Values system for combat info protection
-- C_ChatInfo.SendChatMessage remains available and unchanged
-- Classic variants use legacy SendChatMessage API
local INTERFACE_VERSION = select(4, GetBuildInfo())
local IS_RETAIL = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) or (WOW_PROJECT_ID == nil and INTERFACE_VERSION >= 100000)
local IS_CLASSIC = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC or INTERFACE_VERSION < 20000
local IS_TBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC or (INTERFACE_VERSION >= 20000 and INTERFACE_VERSION < 30000)
local IS_WRATH = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC or (INTERFACE_VERSION >= 30000 and INTERFACE_VERSION < 40000)
local IS_CATA = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC or (INTERFACE_VERSION >= 40000 and INTERFACE_VERSION < 100000)


----------------------------
--      Localization      --
----------------------------


local L = LibStub("AceLocale-3.0"):GetLocale("Name2Chat", true)

local Options = {
	type = "group",
	get = function(item) return Name2Chat.db.profile[item[#item]] end,
	set = function(item, value) Name2Chat.db.profile[item[#item]] = value end,
	args = {
		name = {
			order = 1,
			type = "input",
			name = L["name"],
			desc = L["name_desc"],
		},
		enable = {
			order = 2,
			type = "toggle",
			name = L["enable"],
			desc = L["enable_desc"],
		},
		debug = {
			order = 3,
			type = "toggle",
			name = L["debug"],
			desc = L["debug_desc"],
		},
		guild = {
			order = 4,
			type = "toggle",
			name = L["guild"],
			desc = L["guild_desc"],
		},
		party = {
			order = 5,
			type = "toggle",
			name = L["party"],
			desc = L["party_desc"],
		},
		raid = {
			order = 6,
			type = "toggle",
			name = L["raid"],
			desc = L["raid_desc"],
		},
		instance_chat = {
			order = 7,
			type = "toggle",
			name = L["instance_chat"],
			desc = L["instance_chat_desc"],
		},
		channel = {
			order = 8,
			type = "input",
			name = L["channel"],
			desc = L["channel_desc"],
		},
		hideOnMatchingCharName = {
			order = 9,
			type = "toggle",
			name = L["hideOnMatchingCharName"],
			desc = L["hideOnMatchingCharName_desc"],
		},
		ignoreExclamationMark = {
			order = 10,
			type = "toggle",
			name = L["ignoreExclamationMark"],
			desc = L["ignoreExclamationMark_desc"],
		}
	},
}

local Defaults = {
	profile = {
		enable = true,
		guild = true,
		party = false,
		raid = false,
		instance_chat = false,
		debug = false,
		channel = nil,
		hideOnMatchingCharName = false,
		ignoreExclamationMark = true,
	},
}

local SlashOptions = {
	type = "group",
	handler = Name2Chat,
	get = function(item) return Name2Chat.db.profile[item[#item]] end,
	set = function(item, value) Name2Chat.db.profile[item[#item]] = value end,
	args = {
		enable = {
			type = "toggle",
			name = L["enable"],
			desc = L["enable_desc"],
		},
		name = {
			type = "input",
			name = L["name"],
			desc = L["name_desc"],
		},
		config = {
			type = "execute",
			name = L["config"],
			desc = L["config_desc"],
			func = function()
				-- Use AceConfigDialog to open the options
				LibStub("AceConfigDialog-3.0"):Open("Name2Chat Options")
			end,
		},
	},
}

local SlashCmds = {
  "n2c",
  "Name2Chat",
};

local character_name

----------------------
---      Init      ---
----------------------

function Name2Chat:OnInitialize()
	-- Load our database.
	self.db = LibStub("AceDB-3.0"):New("Name2ChatDB", Defaults, "Default")

	-- Set up our config options.
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

	local config = LibStub("AceConfig-3.0")
	config:RegisterOptionsTable("Name2Chat", SlashOptions, SlashCmds)

	local registry = LibStub("AceConfigRegistry-3.0")
	registry:RegisterOptionsTable("Name2Chat Options", Options)
	registry:RegisterOptionsTable("Name2Chat Profiles", profiles);

	local dialog = LibStub("AceConfigDialog-3.0");
	self.optionFrames = {
		main = dialog:AddToBlizOptions(	"Name2Chat Options", "Name2Chat"),
		profiles = dialog:AddToBlizOptions(	"Name2Chat Profiles", "Profiles", "Name2Chat");
	}

	-- Hook SendChatMessage function with version detection
	-- Modern API (Retail 10.0+) uses C_ChatInfo.SendChatMessage
	-- Legacy API (Classic, TBC, Wrath, Cata) uses global SendChatMessage function
	self._useCChatInfo = IS_RETAIL and C_ChatInfo and type(C_ChatInfo.SendChatMessage) == "function"
	
	if self._useCChatInfo then
		local success = pcall(function()
			self:RawHook(C_ChatInfo, "SendChatMessage", true)
		end)
		if success then
			local versionStr = INTERFACE_VERSION >= 120000 and "Midnight 12.0.1+" or "DF/TWW"
			self:Safe_Print("Using modern C_ChatInfo.SendChatMessage API (" .. versionStr .. ", Interface: " .. INTERFACE_VERSION .. ")")
		else
			self:Print("Warning: Failed to hook C_ChatInfo.SendChatMessage")
			self._useCChatInfo = false
		end
	else
		local success = pcall(function()
			self:RawHook("SendChatMessage", true)
		end)
		if success then
			local clientType = "Unknown"
			if IS_CLASSIC then clientType = "Classic Era"
			elseif IS_TBC then clientType = "TBC Classic"
			elseif IS_WRATH then clientType = "Wrath Classic"
			elseif IS_CATA then clientType = "Cata Classic"
			end
			self:Safe_Print("Using legacy SendChatMessage API (" .. clientType .. ", Interface: " .. INTERFACE_VERSION .. ")")
		else
			self:Print("Warning: Failed to hook SendChatMessage")
		end
	end

	-- Register event to get character name when available
	self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")

	self:Safe_Print(L["Loaded"])
end

function Name2Chat:OnPlayerLogin()
	-- Get current character name once player is fully loaded
	character_name = UnitName("player")
	self:UnregisterEvent("PLAYER_LOGIN")
end

--------------------------------
---      Event Handlers      ---
--------------------------------

function Name2Chat:SendChatMessage(msg, chatType, language, channel)
	-- Early exit if addon is disabled
	if not self.db.profile.enable then
		self:CallOriginalSendChatMessage(msg, chatType, language, channel)
		return
	end

	-- Check if we have a valid name configured
	if not self.db.profile.name or self.db.profile.name == "" then
		self:CallOriginalSendChatMessage(msg, chatType, language, channel)
		return
	end

	-- Check if we should hide the name when it matches character name
	if self.db.profile.hideOnMatchingCharName and self.db.profile.name == character_name then
		self:CallOriginalSendChatMessage(msg, chatType, language, channel)
		return
	end

	local shouldAddName = false
	
	-- Check if we should add name based on chat type
	if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER")) or
	   (self.db.profile.raid and chatType == "RAID") or
	   (self.db.profile.party and chatType == "PARTY") or
	   (self.db.profile.instance_chat and chatType == "INSTANCE_CHAT") then
		shouldAddName = true
	elseif (self.db.profile.channel ~= nil) and (self.db.profile.channel ~= "") and chatType == "CHANNEL" then
		local id, chname = GetChannelName(channel)
		if chname and strupper(self.db.profile.channel) == strupper(chname) then
			shouldAddName = true
		end
	end

	-- Add name unless it's a special command and ignore option is enabled
	if shouldAddName then
		if self.db.profile.ignoreExclamationMark and self:StartsWithExclamation(msg) then
			-- Don't add name for commands starting with !
			self:Safe_Print("Ignoring message starting with exclamation mark: " .. msg)
		else
			msg = "(" .. self.db.profile.name .. "): " .. msg
		end
	end

	-- Call original function
	self:CallOriginalSendChatMessage(msg, chatType, language, channel)
end

-- Helper function to call the original SendChatMessage function
function Name2Chat:CallOriginalSendChatMessage(msg, chatType, language, channel)
	if self._useCChatInfo then
		self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, language, channel)
	else
		self.hooks.SendChatMessage(msg, chatType, language, channel)
	end
end

---------------------------
---      Functions      ---
---------------------------

function Name2Chat:Safe_Print(msg)
	if self.db.profile.debug then
		self:Print(msg)
	end
end

-- Local helper function to check if message starts with exclamation mark
function Name2Chat:StartsWithExclamation(msg)
	if not msg or msg == "" then
		return false
	end
	return string.sub(msg, 1, 1) == "!"
end

-- Utility function to safely get character name
function Name2Chat:GetCharacterName()
	return character_name or UnitName("player") or "Unknown"
end
