------------------------
---      Module      ---
------------------------

Name2Chat = LibStub("AceAddon-3.0"):NewAddon("Name2Chat",
											"AceConsole-3.0",
											"AceEvent-3.0",
											"AceHook-3.0")


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

	-- Hook the chat send function to prepend the name before messages go out
	self:HookChatSendFunction()

	-- Register event to get character name when available
	self:RegisterEvent("PLAYER_LOGIN", "OnPlayerLogin")
	
	-- Register event for addon chat restrictions (Patch 12.0.0+)
	if self.RegisterEvent then
		pcall(function()
			self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED", "OnAddonRestrictionChanged")
		end)
	end

	self:Safe_Print(L["Loaded"])
end

--------------------------------
---      Event Handlers      ---
--------------------------------

function Name2Chat:OnPlayerLogin()
	-- Get current character name once player is fully loaded
	character_name = UnitName("player")
	self:UnregisterEvent("PLAYER_LOGIN")
end

-- Handle addon restriction state changes (Patch 12.0.0+)
function Name2Chat:OnAddonRestrictionChanged()
	-- Log if addon chat restrictions are being enforced
	-- This CVar was added in Patch 12.0.0
	if GetCVarBool and C_CVar and C_CVar.GetCVarBool then
		local success, isForced = pcall(C_CVar.GetCVarBool, "addonChatRestrictionsForced")
		if success and isForced then
			self:Print(L["warn_restrictions_enforced"])
		elseif success then
			self:Safe_Print(L["warn_restrictions_lifted"])
		end
	elseif GetCVarBool then
		-- Fallback for older API
		local success, isForced = pcall(GetCVarBool, "addonChatRestrictionsForced")
		if success and isForced then
			self:Print(L["warn_restrictions_enforced"])
		elseif success then
			self:Safe_Print(L["warn_restrictions_lifted"])
		end
	end
end

-- Hook über den offiziellen Blizzard-Event für Addon-Textänderungen vor dem Senden.
-- Quelle: ChatFrameEditBoxMixin:OnPreSendText() in ChatFrameEditBox.lua (12.0.0)
-- Kommentar im Blizzard-Code: "Notification for user addons to perform any final
-- edits to chat text contents before sending."
-- Sequenz in SendText(): ParseText(1) → OnPreSendText() → GetText() → SendChatMessage()
-- D.h.: chatType ist bereits aufgelöst (z.B. /g → "GUILD"), SetText() beeinflusst noch den Send.
function Name2Chat:HookChatSendFunction()
	---@diagnostic disable-next-line: undefined-global
	if EventRegistry then
		---@diagnostic disable-next-line: undefined-global
		EventRegistry:RegisterCallback("ChatFrame.OnEditBoxPreSendText", function(event, editBox)
			local success, err = pcall(function()
				Name2Chat:ModifyChatMessage(editBox)
			end)
			if not success then
				Name2Chat:Print(L["hook_error_modify"] .. tostring(err))
			end
		end, Name2Chat)
		self:Print(L["hook_active_eventregistry"])
	else
		-- Fallback for older clients without EventRegistry
		---@diagnostic disable-next-line: undefined-global
		local mixin = ChatFrameEditBoxMixin
		if mixin and mixin.SendText then
			local orig = mixin.SendText
			mixin.SendText = function(editBox, ...)
				local success, err = pcall(function()
					Name2Chat:ModifyChatMessage(editBox)
				end)
				if not success then
					Name2Chat:Print(L["hook_error_modify"] .. tostring(err))
				end
				orig(editBox, ...)
			end
			self:Print(L["hook_active_mixin"])
		else
			self:Print(L["hook_error_no_entry"])
		end
	end
end

-- Modify the chat message in the editBox before it's sent
function Name2Chat:ModifyChatMessage(editBox)
	self:Safe_Print(L["debug_hook_fired"])

	-- Early exit if addon is disabled
	if not self.db.profile.enable then
		self:Safe_Print(L["debug_disabled"])
		return
	end

	-- Don't modify messages during combat lockdown to avoid ADDON_ACTION_FORBIDDEN.
	-- WoW treats editBox:SetText() in this context as tainting the protected
	-- SendChatMessage() call that follows. The message will still be sent as-is.
	if InCombatLockdown() then
		self:Safe_Print(L["debug_combat_lockdown"])
		return
	end

	-- Check if we have a valid name configured
	if not self.db.profile.name or self.db.profile.name == "" then
		self:Safe_Print(L["debug_name_empty"])
		return
	end

	-- Check if we should hide the name when it matches character name
	if self.db.profile.hideOnMatchingCharName and self.db.profile.name == character_name then
		self:Safe_Print(L["debug_name_matches_char"])
		return
	end

	-- Get the message text
	local msg = editBox:GetText()
	
	-- Ignore empty messages
	if not msg or msg == "" then
		self:Safe_Print(L["debug_msg_empty"])
		return
	end
	
	-- Determine chat type from edit box
	local chatType = editBox:GetAttribute("chatType")
	if not chatType and editBox.chatType then
		chatType = editBox.chatType
	end
	if not chatType then
		chatType = "SAY"
	end
	
	self:Safe_Print(L["debug_chattype"]:format(tostring(chatType), tostring(self.db.profile.name)))

	local shouldAddName = false
	
	-- Check based on chat type
	if chatType == "GUILD" and self.db.profile.guild then
		shouldAddName = true
	elseif chatType == "OFFICER" and self.db.profile.guild then
		shouldAddName = true
	elseif chatType == "PARTY" and self.db.profile.party then
		shouldAddName = true
	elseif chatType == "RAID" and self.db.profile.raid then
		shouldAddName = true
	elseif chatType == "INSTANCE_CHAT" and (self.db.profile.instance_chat or self.db.profile.raid) then
		-- In instances (raids, LFR, battlegrounds) WoW routes raid chat as INSTANCE_CHAT
		shouldAddName = true
	elseif (self.db.profile.channel ~= nil) and (self.db.profile.channel ~= "") and chatType == "CHANNEL" then
		-- Special handling for custom channels
		local channelNum = editBox:GetAttribute("channelTarget")
		if not channelNum and editBox.channelTarget then
			channelNum = editBox.channelTarget
		end
		if channelNum then
			local id, chname = GetChannelName(channelNum)
			if chname and strupper(self.db.profile.channel) == strupper(chname) then
				shouldAddName = true
			end
		end
	end

	self:Safe_Print(L["debug_should_add"]:format(tostring(shouldAddName)))

	-- Add name unless it's a special command and ignore option is enabled
	if shouldAddName then
		if self.db.profile.ignoreExclamationMark and self:StartsWithExclamation(msg) then
			-- Don't add name for commands starting with !
			self:Safe_Print(L["debug_skip_exclamation"])
		else
			-- Modify the text in the editbox BEFORE it is sent
			local newMsg = "(" .. self.db.profile.name .. "): " .. msg
			editBox:SetText(newMsg)
			self:Safe_Print(L["debug_modified"]:format(newMsg))
		end
	else
		self:Safe_Print(L["debug_chattype_not_active"]:format(
			tostring(chatType),
			tostring(self.db.profile.guild),
			tostring(self.db.profile.party),
			tostring(self.db.profile.raid),
			tostring(self.db.profile.instance_chat)
		))
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
