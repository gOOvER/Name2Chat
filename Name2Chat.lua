------------------------
---      Module      ---
------------------------

Name2Chat = LibStub("AceAddon-3.0"):NewAddon(
	"Name2Chat",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceHook-3.0"
)

----------------------------
--      Localization      --
----------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("Name2Chat", true)
local ChatCompat = LibStub("ChatCompat", true)

-- Maximum byte length allowed by WoW's SendChatMessage API
local MAX_CHAT_BYTES = 255

-- Helper for building option toggles with full or custom width
local function Toggle(key, order, width)
	return {
		order = order,
		type = "toggle",
		width = width or "full",
		name = L[key],
		desc = L[key .. "_desc"],
	}
end

-- Options panel organized into inline sections (leaf keys unchanged so existing SavedVariables stay compatible)
local Options = {
	type = "group",
	get = function(item) return Name2Chat.db.profile[item[#item]] end,
	set = function(item, value) Name2Chat.db.profile[item[#item]] = value end,
	args = {
		general = {
			order = 1,
			type = "group",
			inline = true,
			name = L["group_general"],
			args = {
				enable = Toggle("enable", 1),
				name = {
					order = 2,
					type = "input",
					width = "double",
					name = L["name"],
					desc = L["name_desc"],
				},
			},
		},
		channels = {
			order = 2,
			type = "group",
			inline = true,
			name = L["group_channels"],
			args = {
				guild = Toggle("guild", 1, "normal"),
				party = Toggle("party", 2, "normal"),
				raid = Toggle("raid", 3, "normal"),
				instance_chat = Toggle("instance_chat", 4, "normal"),
				channel = {
					order = 5,
					type = "input",
					width = "double",
					name = L["channel"],
					desc = L["channel_desc"],
				},
			},
		},
		behaviour = {
			order = 3,
			type = "group",
			inline = true,
			name = L["group_behaviour"],
			args = {
				hideOnMatchingCharName = Toggle("hideOnMatchingCharName", 1),
				ignoreExclamationMark = Toggle("ignoreExclamationMark", 2),
				combat = Toggle("combat", 3),
			},
		},
		received = {
			order = 4,
			type = "group",
			inline = true,
			name = L["group_received"],
			args = {
				guildNote = Toggle("guildNote", 1),
			},
		},
		advanced = {
			order = 5,
			type = "group",
			inline = true,
			name = L["group_advanced"],
			args = {
				debug = Toggle("debug", 1),
			},
		},
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
		combat = false,
		guildNote = false,
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
				LibStub("AceConfigDialog-3.0"):Open("Name2Chat Options")
			end,
		},
	},
}

local SlashCmds = {
	"n2c",
	"Name2Chat",
}

local character_name

-- Helper to check if a value is a Patch 12.0+ / WoW Forever Secret Value
local function IsSecret(val)
	return ChatCompat and ChatCompat:IsSecretValue(val) or false
end

-- Helper to trim leading and trailing whitespace
local function TrimString(s)
	if not s then return "" end
	if type(strtrim) == "function" then
		return strtrim(s)
	end
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

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
	registry:RegisterOptionsTable("Name2Chat Profiles", profiles)

	local dialog = LibStub("AceConfigDialog-3.0")
	self.optionFrames = {
		main = dialog:AddToBlizOptions("Name2Chat Options", "Name2Chat"),
		profiles = dialog:AddToBlizOptions("Name2Chat Profiles", "Profiles", "Name2Chat"),
	}

	-- Try to initialize character name early (in case of /reload)
	self:GetCharacterName()

	-- Hook the chat send function to prepend the name before messages go out
	self:HookChatSendFunction()

	-- Hook the Guild & Communities window (J) input box (#38, #40)
	self:SetupCommunitiesHook()

	-- Incoming guild messages: optionally display sender's guild note when they don't use Name2Chat (#40)
	self:SetupGuildNoteFilter()

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
	local name = UnitName and UnitName("player")
	if name and not IsSecret(name) and name ~= "" and name ~= UNKNOWNOBJECT then
		character_name = name
	end
	self:UnregisterEvent("PLAYER_LOGIN")
	self:RequestGuildRoster()
end

-- Handle addon restriction state changes (Patch 12.0.0+)
function Name2Chat:OnAddonRestrictionChanged()
	if C_CVar and type(C_CVar.GetCVarBool) == "function" then
		local success, isForced = pcall(C_CVar.GetCVarBool, "addonChatRestrictionsForced")
		if success and isForced then
			self:Print(L["warn_restrictions_enforced"])
		elseif success then
			self:Safe_Print(L["warn_restrictions_lifted"])
		end
	elseif type(GetCVarBool) == "function" then
		local success, isForced = pcall(GetCVarBool, "addonChatRestrictionsForced")
		if success and isForced then
			self:Print(L["warn_restrictions_enforced"])
		elseif success then
			self:Safe_Print(L["warn_restrictions_lifted"])
		end
	end
end

-----------------------------------------------
---      Guild Note on Received Messages    ---
-----------------------------------------------
-- Display-only feature (ported from Name2Chat Forever, #40):
-- When a guild member's message does not already start with a "(Name): " prefix,
-- show their public guild note in front of the message in our local chat frame.

local guildNotes = {}
local lastRosterRequest = 0
local ROSTER_REQUEST_INTERVAL = 60

function Name2Chat:RequestGuildRoster()
	if not IsInGuild or not IsInGuild() then return end
	lastRosterRequest = GetTime and GetTime() or 0
	if C_GuildInfo and type(C_GuildInfo.GuildRoster) == "function" then
		pcall(C_GuildInfo.GuildRoster)
	elseif type(GuildRoster) == "function" then
		pcall(GuildRoster)
	end
end

function Name2Chat:UpdateGuildNotes()
	if wipe then
		wipe(guildNotes)
	else
		guildNotes = {}
	end
	if not IsInGuild or not IsInGuild() or type(GetNumGuildMembers) ~= "function" or type(GetGuildRosterInfo) ~= "function" then
		return
	end
	local numMembers = GetNumGuildMembers() or 0
	for i = 1, numMembers do
		local name, _, _, _, _, _, note = GetGuildRosterInfo(i)
		if name and note and not IsSecret(name) and not IsSecret(note) then
			note = TrimString(note)
			if note ~= "" then
				guildNotes[name] = note
				local short = strsplit and strsplit("-", name) or string.match(name, "^([^-]+)")
				if short and guildNotes[short] == nil then
					guildNotes[short] = note
				end
			end
		end
	end
end

function Name2Chat:GetGuildNote(author)
	if not author or IsSecret(author) then return nil end
	local note = guildNotes[author]
	if not note then
		local short = strsplit and strsplit("-", author) or string.match(author, "^([^-]+)")
		if short then
			note = guildNotes[short]
		end
	end
	return note
end

-- Removes leading spaces and color codes (|cAARRGGBB, |r) so a prefix check isn't fooled
local function StripLeadingCodes(s)
	local prev
	repeat
		prev = s
		s = string.gsub(s, "^%s+", "")
		s = string.gsub(s, "^|c%x%x%x%x%x%x%x%x", "")
		s = string.gsub(s, "^|r", "")
	until s == prev
	return s
end

-- Checks if an incoming chat event is from the local player using GUID first (WoW Forever surnames/realms)
local function IsFromPlayer(author, guid)
	if guid and not IsSecret(guid) and type(UnitGUID) == "function" then
		local playerGUID = UnitGUID("player")
		if playerGUID and not IsSecret(playerGUID) then
			return guid == playerGUID
		end
	end
	local charName = Name2Chat:GetCharacterName()
	local shortAuthor = strsplit and strsplit("-", author) or string.match(author, "^([^-]+)") or author
	return charName ~= nil and strlower(shortAuthor) == strlower(charName)
end

local function GuildNoteFilter(_, event, msg, author, ...)
	local addon = Name2Chat
	if not addon.db or not addon.db.profile or not addon.db.profile.enable or not addon.db.profile.guildNote then
		return false
	end
	if type(msg) ~= "string" or type(author) ~= "string" or IsSecret(msg) or IsSecret(author) then
		return false
	end

	-- arg12 = sender GUID; "..." starts at arg3, so it is the 10th vararg
	local guid = select(10, ...)
	addon:Safe_Print(L["debug_guildnote"]:format(tostring(event), author, tostring(not IsSecret(guid) and guid or "?"), msg))

	local plainMsg = StripLeadingCodes(msg)
	-- Already prefixed by Name2Chat (or a compatible addon): leave it alone
	if string.find(plainMsg, "^%(.-%): ") then
		return false
	end
	-- Addon commands like !keys
	if string.sub(plainMsg, 1, 1) == "!" then
		return false
	end
	-- Own messages are already handled on the send side
	if IsFromPlayer(author, guid) then
		return false
	end

	local shortAuthor = strsplit and strsplit("-", author) or string.match(author, "^([^-]+)") or author
	local note = addon:GetGuildNote(author)
	if not note then
		local now = GetTime and GetTime() or 0
		if now - lastRosterRequest > ROSTER_REQUEST_INTERVAL then
			addon:RequestGuildRoster()
		end
		return false
	end

	-- Respect hideOnMatchingCharName for guild notes too
	if addon.db.profile.hideOnMatchingCharName
		and strlower(TrimString(note)) == strlower(TrimString(shortAuthor))
	then
		return false
	end

	local notePrefix = "(" .. note .. "): "
	if string.find(msg, notePrefix, 1, true) then
		return false
	end
	return false, notePrefix .. msg, author, ...
end

function Name2Chat:SetupGuildNoteFilter()
	---@diagnostic disable-next-line: undefined-global
	local addFilter = ChatFrame_AddMessageEventFilter
		or (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter)
	if not addFilter then
		self:Safe_Print(L["debug_guildnote_no_filter"])
		return
	end
	addFilter("CHAT_MSG_GUILD", GuildNoteFilter)
	addFilter("CHAT_MSG_OFFICER", GuildNoteFilter)
	self:RegisterEvent("GUILD_ROSTER_UPDATE", "UpdateGuildNotes")
	self:RegisterEvent("PLAYER_GUILD_UPDATE", "RequestGuildRoster")
end

------------------------------------------------
---      Outgoing Chat Hook Registration     ---
------------------------------------------------

-- Helper to safely parse chat channel headers (/g, /p, /raid, /s, /w, etc.)
-- with send = 0 before inspecting chatType in non-EventRegistry hooks.
-- Passing send = 0 resolves channel switches without executing slash commands.
local function PreParseChatHeaders(editBox)
	if not editBox or (ChatCompat and ChatCompat:IsChatRestricted(Name2Chat.db and Name2Chat.db.profile and Name2Chat.db.profile.combat)) then
		return
	end
	if type(editBox.ParseText) == "function" then
		pcall(editBox.ParseText, editBox, 0)
	elseif type(ChatEdit_ParseText) == "function" then
		pcall(ChatEdit_ParseText, editBox, 0)
	end
end

-- 4-Tier Hook Chain across all WoW versions (Retail 12.0+, Forever, MoP, Cata, Wrath, TBC, Classic Era):
-- Tier 1: EventRegistry "ChatFrame.OnEditBoxPreSendText" (Retail 12.0+ & WoW Forever)
-- Tier 2: ChatFrameEditBoxMixin.SendText + existing ChatFrame1..N EditBox instances
-- Tier 3: Global ChatEdit_SendText (Classic Era 1.15.8, TBC Anniversary 2.5.5, Wrath, Cata)
-- Tier 4: Direct C_ChatInfo.SendChatMessage / SendChatMessage hook via ChatCompat
function Name2Chat:HookChatSendFunction()
	local _, _, _, tocVersion = GetBuildInfo()
	tocVersion = tonumber(tocVersion) or 0

	---@diagnostic disable-next-line: undefined-global
	local mixin = ChatFrameEditBoxMixin
	local hasPreSendEvent = type(mixin) == "table" and type(mixin.OnPreSendText) == "function"
	local isForever = tocVersion >= 16000 and tocVersion < 20000
	local useEventRegistry = hasPreSendEvent or isForever or tocVersion >= 120000

	-- Tier 1: Official Blizzard EventRegistry callback (Patch 12.0.0+ / WoW Forever)
	---@diagnostic disable-next-line: undefined-global
	if useEventRegistry and EventRegistry and type(EventRegistry.RegisterCallback) == "function" then
		---@diagnostic disable-next-line: undefined-global
		EventRegistry:RegisterCallback("ChatFrame.OnEditBoxPreSendText", function(_, editBox)
			local success, err = pcall(function()
				Name2Chat:ModifyChatMessage(editBox)
			end)
			if not success then
				Name2Chat:Print(L["hook_error_modify"] .. tostring(err))
			end
		end, Name2Chat)
		self:Safe_Print(L["hook_active_eventregistry"])
		return
	end

	-- Helper to wrap an EditBox SendText function safely with a re-entrancy guard
	local function createSendTextWrapper(origFunc)
		return function(editBox, ...)
			if not Name2Chat._inSendText then
				Name2Chat._inSendText = true
				local success, err = pcall(function()
					PreParseChatHeaders(editBox)
					Name2Chat:ModifyChatMessage(editBox)
				end)
				if not success then
					Name2Chat:Print(L["hook_error_modify"] .. tostring(err))
				end
				Name2Chat._inSendText = false
			end
			return origFunc(editBox, ...)
		end
	end

	-- Tier 2: ChatFrameEditBoxMixin.SendText + already-instantiated ChatFrameXEditBox frames
	-- AND Tier 3: Global ChatEdit_SendText (used by Classic 1.15.8 & TBC Anniversary 2.5.5)
	local hookedEditBox = false

	if mixin and type(mixin.SendText) == "function" then
		local origMixinSendText = mixin.SendText
		local wrappedMixinSendText = createSendTextWrapper(origMixinSendText)
		mixin.SendText = wrappedMixinSendText

		local maxWindows = NUM_CHAT_WINDOWS
			or (Constants and Constants.ChatFrameConstants and Constants.ChatFrameConstants.MaxChatWindows)
			or 10
		for i = 1, maxWindows do
			local eb = _G["ChatFrame" .. i .. "EditBox"]
			if eb and type(eb.SendText) == "function" then
				if eb.SendText == origMixinSendText then
					eb.SendText = wrappedMixinSendText
				else
					eb.SendText = createSendTextWrapper(eb.SendText)
				end
			end
		end
		if _G["ChatFrameEditBox"] and type(_G["ChatFrameEditBox"].SendText) == "function" then
			if _G["ChatFrameEditBox"].SendText == origMixinSendText then
				_G["ChatFrameEditBox"].SendText = wrappedMixinSendText
			else
				_G["ChatFrameEditBox"].SendText = createSendTextWrapper(_G["ChatFrameEditBox"].SendText)
			end
		end

		-- Also hook FCF_OpenTemporaryWindow so dynamically created temporary chat windows (e.g. via ElvUI or Blizzard) are wrapped
		if type(_G.FCF_OpenTemporaryWindow) == "function" and type(hooksecurefunc) == "function" then
			hooksecurefunc("FCF_OpenTemporaryWindow", function()
				for i = 1, (NUM_CHAT_WINDOWS or 20) do
					local eb = _G["ChatFrame" .. i .. "EditBox"]
					if eb and type(eb.SendText) == "function" and not eb._n2cHooked then
						eb._n2cHooked = true
						if eb.SendText == origMixinSendText then
							eb.SendText = wrappedMixinSendText
						elseif eb.SendText ~= wrappedMixinSendText then
							eb.SendText = createSendTextWrapper(eb.SendText)
						end
					end
				end
			end)
		end

		hookedEditBox = true
		self:Safe_Print(L["hook_active_mixin"])
	end

	-- Tier 3: Global ChatEdit_SendText (primary entry point in Classic 1.15.8 & TBC 2.5.5)
	---@diagnostic disable-next-line: undefined-global
	if type(ChatEdit_SendText) == "function" then
		---@diagnostic disable-next-line: undefined-global
		ChatEdit_SendText = createSendTextWrapper(ChatEdit_SendText)
		if not hookedEditBox then
			self:Safe_Print(L["hook_active_chatedit"])
		end
		hookedEditBox = true
	end

	if hookedEditBox then
		return
	end

	-- Tier 4: Direct SendChatMessage hook via ChatCompat (ultimate fallback if no EditBox hook exists)
	if ChatCompat and type(ChatCompat.HookSendChatMessage) == "function" then
		ChatCompat:HookSendChatMessage(self)
		self:Safe_Print(L["hook_active_chatedit"])
		return
	end

	self:Print(L["hook_error_no_entry"])
end

------------------------------------------------
---      Guild & Communities Window (J)      ---
------------------------------------------------
-- The Guild & Communities window (default key "J") has its own input box
-- (CommunitiesFrame.ChatEditBox / CommunitiesFrame.Chat:SendMessage) which
-- may send via C_Club.SendMessage(clubId, streamId, text) directly (#38, #40).

function Name2Chat:SetupCommunitiesHook()
	local isLoaded = false
	if C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function" then
		isLoaded = C_AddOns.IsAddOnLoaded("Blizzard_Communities")
	elseif type(IsAddOnLoaded) == "function" then
		isLoaded = IsAddOnLoaded("Blizzard_Communities")
	end

	if isLoaded then
		self:HookCommunitiesChat()
	else
		self:RegisterEvent("ADDON_LOADED", "OnAddonLoaded")
	end
end

function Name2Chat:OnAddonLoaded(_, addonName)
	if addonName == "Blizzard_Communities" then
		self:HookCommunitiesChat()
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Name2Chat:HookCommunitiesChat()
	if self.communitiesHooked then return end

	---@diagnostic disable-next-line: undefined-global
	local commFrame = CommunitiesFrame
	if not commFrame then
		self:Safe_Print(L["hook_error_communities"])
		return
	end

	local hookedAny = false

	-- Hook CommunitiesFrame.Chat:SendMessage(text) if present
	local chat = commFrame.Chat
	if chat and type(chat.SendMessage) == "function" then
		local origSendMessage = chat.SendMessage
		chat.SendMessage = function(chatFrame, text, ...)
			local ok, modifiedText = pcall(Name2Chat.ModifyCommunitiesMessage, Name2Chat, chatFrame, text)
			if not ok then
				Name2Chat:Print(L["hook_error_modify"] .. tostring(modifiedText))
			elseif modifiedText then
				text = modifiedText
			end
			return origSendMessage(chatFrame, text, ...)
		end
		hookedAny = true
	end

	-- Also hook CommunitiesFrame.ChatEditBox.SendText if it uses a separate SendText reference
	local chatEditBox = commFrame.ChatEditBox
	if chatEditBox and type(chatEditBox.SendText) == "function" then
		local origEditBoxSendText = chatEditBox.SendText
		chatEditBox.SendText = function(editBox, ...)
			if not Name2Chat._inSendText then
				Name2Chat._inSendText = true
				local ok, err = pcall(function()
					PreParseChatHeaders(editBox)
					Name2Chat:ModifyChatMessage(editBox)
				end)
				if not ok then
					Name2Chat:Print(L["hook_error_modify"] .. tostring(err))
				end
				Name2Chat._inSendText = false
			end
			return origEditBoxSendText(editBox, ...)
		end
		hookedAny = true
	end

	if hookedAny then
		self.communitiesHooked = true
		self:Safe_Print(L["hook_active_communities"])
	else
		self:Safe_Print(L["hook_error_communities"])
	end
end

-- Helper to check if a Communities (C_Club) stream should have the name added
function Name2Chat:ShouldAddNameForCommunityStream(clubId, streamId)
	if not clubId or not streamId or not C_Club or type(C_Club.GetStreamInfo) ~= "function" then
		return false
	end
	if IsSecret(clubId) or IsSecret(streamId) then
		return false
	end

	local okStream, streamInfo = pcall(C_Club.GetStreamInfo, clubId, streamId)
	if not okStream or not streamInfo then
		return false
	end

	local streamType = streamInfo.streamType
	local isGuildOrOfficer = Enum and Enum.ClubStreamType
		and (streamType == Enum.ClubStreamType.Guild or streamType == Enum.ClubStreamType.Officer)

	self:Safe_Print(L["debug_chattype"]:format("COMMUNITIES:" .. tostring(streamType), tostring(self.db.profile.name)))

	if isGuildOrOfficer and self.db.profile.guild then
		return true
	end

	-- Also allow matching custom channel names against Community/Stream names
	if self.db.profile.channel and self.db.profile.channel ~= "" then
		if streamInfo.name and not IsSecret(streamInfo.name) then
			if self:MatchesConfiguredChannel(streamInfo.name, nil) then
				return true
			end
		end
		if type(C_Club.GetClubInfo) == "function" then
			local okClub, clubInfo = pcall(C_Club.GetClubInfo, clubId)
			if okClub and clubInfo and clubInfo.name and not IsSecret(clubInfo.name) then
				if self:MatchesConfiguredChannel(clubInfo.name, nil) then
					return true
				end
			end
		end
	end

	return false
end

-- Modifies outgoing message text from CommunitiesFrame.Chat:SendMessage(text) (#38, #40)
function Name2Chat:ModifyCommunitiesMessage(chatFrame, text)
	self:Safe_Print(L["debug_hook_fired"])

	local communitiesFrame = (chatFrame and type(chatFrame.GetCommunitiesFrame) == "function" and chatFrame:GetCommunitiesFrame())
		or _G["CommunitiesFrame"]
	if not communitiesFrame then
		return nil
	end

	local clubId = type(communitiesFrame.GetSelectedClubId) == "function" and communitiesFrame:GetSelectedClubId() or nil
	local streamId = type(communitiesFrame.GetSelectedStreamId) == "function" and communitiesFrame:GetSelectedStreamId() or nil
	if not clubId or not streamId then
		return nil
	end

	local shouldAdd = self:ShouldAddNameForCommunityStream(clubId, streamId)
	self:Safe_Print(L["debug_should_add"]:format(tostring(shouldAdd)))
	if not shouldAdd then
		return nil
	end

	if not self:CanAddNameNow() then
		return nil
	end

	local newMsg = self:BuildPrefixedText(text)
	if newMsg then
		self:Safe_Print(L["debug_modified"]:format(newMsg))
	end
	return newMsg
end

------------------------------------------------
---      Core Message Modification Logic     ---
------------------------------------------------

-- Common pre-flight checks before adding a name prefix
function Name2Chat:CanAddNameNow()
	if not self.db or not self.db.profile then
		return false
	end

	-- Early exit if addon is disabled
	if not self.db.profile.enable then
		self:Safe_Print(L["debug_disabled"])
		return false
	end

	-- Check combat, active boss encounters, Mythic+ keystones, and chat restrictions (#33, #37, PR #39, #40)
	if ChatCompat then
		local isRestricted, reason = ChatCompat:IsChatRestricted(self.db.profile.combat)
		if isRestricted then
			if reason == "mythic_plus" then
				self:Safe_Print(L["debug_mythic_plus"])
			elseif reason == "combat_chat_lockdown" then
				self:Safe_Print(L["debug_combat_chat_lockdown"])
			else
				self:Safe_Print(L["debug_combat_lockdown"])
			end
			return false
		end
	elseif InCombatLockdown and InCombatLockdown() then
		self:Safe_Print(L["debug_combat_lockdown"])
		return false
	end

	-- Check if we have a valid name configured
	local configuredName = self.db.profile.name
	if not configuredName or configuredName == "" then
		self:Safe_Print(L["debug_name_empty"])
		return false
	end

	-- Check if we should hide the name when it matches character name (case-insensitive, trimmed)
	if self.db.profile.hideOnMatchingCharName then
		self:Safe_Print(L["debug_name_compare"]:format(
			tostring(configuredName),
			tostring(self:GetCharacterName())
		))
		if self:NameMatchesCharacter() then
			self:Safe_Print(L["debug_name_matches_char"])
			return false
		end
	end

	return true
end

-- Builds the prefixed chat string, or returns nil if the message must not be modified
function Name2Chat:BuildPrefixedText(msg)
	-- Guard against Patch 12.0.0+ / Forever Secret Values
	if IsSecret(msg) then
		return nil
	end

	-- Ignore empty or whitespace-only messages
	if type(msg) ~= "string" or msg == "" or not strfind(msg, "%S") then
		self:Safe_Print(L["debug_msg_empty"])
		return nil
	end

	-- CRITICAL: Never prepend name to slash commands (e.g. /reload, /n2c, /afk, /w).
	if self:StartsWithSlash(msg) then
		self:Safe_Print(L["debug_slash_command"])
		return nil
	end

	-- Don't add name for commands starting with ! when ignoreExclamationMark is enabled
	if self.db.profile.ignoreExclamationMark and self:StartsWithExclamation(msg) then
		self:Safe_Print(L["debug_skip_exclamation"])
		return nil
	end

	-- Prevent double-prefixing (e.g. when recalling a previously sent message from EditBox history)
	if self:StartsWithPrefix(msg) then
		self:Safe_Print(L["debug_already_prefixed"])
		return nil
	end

	local newMsg = self:GetPrefix() .. msg

	-- Respect WoW's 255-byte chat limit so long messages or trailing hyperlinks (|H...|h) are not truncated/broken
	if #newMsg > MAX_CHAT_BYTES then
		self:Safe_Print(L["debug_msg_too_long"])
		return nil
	end

	return newMsg
end

-- Modify the chat message in the editBox before it's sent
function Name2Chat:ModifyChatMessage(editBox)
	self:Safe_Print(L["debug_hook_fired"])

	if not editBox or not self:CanAddNameNow() then
		return
	end

	-- Get the message text
	local msg = editBox:GetText()
	if IsSecret(msg) or not msg or msg == "" or not strfind(msg, "%S") then
		self:Safe_Print(L["debug_msg_empty"])
		return
	end

	-- Determine chat type from edit box
	local chatType = editBox.GetAttribute and editBox:GetAttribute("chatType")
	if not chatType and editBox.chatType then
		chatType = editBox.chatType
	end
	if IsSecret(chatType) then
		return
	end
	if not chatType then
		chatType = "SAY"
	end

	self:Safe_Print(L["debug_chattype"]:format(tostring(chatType), tostring(self.db.profile.name)))

	local shouldAddName = false

	-- Check based on chat type
	if (chatType == "GUILD" or chatType == "OFFICER") and self.db.profile.guild then
		shouldAddName = true
	elseif (chatType == "PARTY" or chatType == "PARTY_LEADER") and self.db.profile.party then
		shouldAddName = true
	elseif (chatType == "RAID" or chatType == "RAID_LEADER") and self.db.profile.raid then
		shouldAddName = true
	elseif (chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER")
		and (self.db.profile.instance_chat or self.db.profile.raid)
	then
		-- In instances (raids, LFR, battlegrounds) WoW routes raid/instance chat as INSTANCE_CHAT
		shouldAddName = true
	elseif chatType == "COMMUNITIES_CHANNEL" then
		-- Guild & Communities streams routed through ChatFrame or CommunitiesFrame.ChatEditBox (#38)
		local channelTarget = editBox.GetAttribute and editBox:GetAttribute("channelTarget") or editBox.channelTarget
		local clubId, streamId
		if channelTarget and not IsSecret(channelTarget) then
			if type(ChatFrame_GetCommunityAndStreamFromChannel) == "function" then
				local ok, cId, sId = pcall(ChatFrame_GetCommunityAndStreamFromChannel, channelTarget)
				if ok then
					clubId, streamId = cId, sId
				end
			end
		end
		if (not clubId or not streamId) and _G["CommunitiesFrame"] then
			local cf = _G["CommunitiesFrame"]
			clubId = type(cf.GetSelectedClubId) == "function" and cf:GetSelectedClubId() or clubId
			streamId = type(cf.GetSelectedStreamId) == "function" and cf:GetSelectedStreamId() or streamId
		end
		shouldAddName = self:ShouldAddNameForCommunityStream(clubId, streamId)
	elseif self.db.profile.channel and self.db.profile.channel ~= "" and chatType == "CHANNEL" then
		-- Special handling for custom channels (supports single channel or comma-separated list)
		local channelNum = editBox.GetAttribute and editBox:GetAttribute("channelTarget")
		if not channelNum and editBox.channelTarget then
			channelNum = editBox.channelTarget
		end
		if channelNum and not IsSecret(channelNum) then
			local id, chname = GetChannelName(channelNum)
			if chname and not IsSecret(chname) then
				shouldAddName = self:MatchesConfiguredChannel(chname, id)
			end
		end
	end

	self:Safe_Print(L["debug_should_add"]:format(tostring(shouldAddName)))

	if shouldAddName then
		local newMsg = self:BuildPrefixedText(msg)
		if newMsg then
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

-- Tier 4 Fallback handler when ChatCompat:HookSendChatMessage(self) is used
function Name2Chat:SendChatMessage(msg, chatType, language, channel)
	if self:CanAddNameNow() and chatType and not IsSecret(chatType) then
		local shouldAddName = false
		if ChatCompat and ChatCompat:IsSupportedChatType(chatType, self.db.profile) then
			shouldAddName = true
		elseif self.db.profile.channel and self.db.profile.channel ~= "" and chatType == "CHANNEL" and channel then
			local id, chname = GetChannelName(channel)
			if chname and not IsSecret(chname) then
				shouldAddName = self:MatchesConfiguredChannel(chname, id)
			end
		end

		if shouldAddName then
			local newMsg = self:BuildPrefixedText(msg)
			if newMsg then
				msg = newMsg
			end
		end
	end

	return self:CallOriginalSendChatMessage(msg, chatType, language, channel)
end

function Name2Chat:CallOriginalSendChatMessage(msg, chatType, language, channel)
	if ChatCompat and ChatCompat.api and ChatCompat.api.useCChatInfo then
		if self.hooks and self.hooks[C_ChatInfo] and self.hooks[C_ChatInfo].SendChatMessage then
			return self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, language, channel)
		end
	elseif self.hooks and self.hooks.SendChatMessage then
		return self.hooks.SendChatMessage(msg, chatType, language, channel)
	end
end

---------------------------
---      Functions      ---
---------------------------

function Name2Chat:Safe_Print(msg)
	if self.db and self.db.profile and self.db.profile.debug then
		self:Print(msg)
	end
end

-- Prefix added in front of messages, e.g. "(YourName): "
function Name2Chat:GetPrefix()
	return "(" .. tostring(self.db.profile.name) .. "): "
end

-- True if the message already starts with our prefix
function Name2Chat:StartsWithPrefix(msg)
	if not msg or msg == "" or not self.db or not self.db.profile or not self.db.profile.name then
		return false
	end
	local prefix = self:GetPrefix()
	return string.sub(msg, 1, #prefix) == prefix
end

-- Check if message starts with exclamation mark (!)
function Name2Chat:StartsWithExclamation(msg)
	if not msg or msg == "" then
		return false
	end
	return string.sub(msg, 1, 1) == "!"
end

-- Check if message starts with a slash (/) or leading whitespace followed by slash
function Name2Chat:StartsWithSlash(msg)
	if not msg or msg == "" then
		return false
	end
	return strfind(msg, "^%s*/") ~= nil
end

-- Check if the active custom channel matches the user's configured channel(s)
function Name2Chat:MatchesConfiguredChannel(chname, channelId)
	local configured = self.db and self.db.profile and self.db.profile.channel
	if not configured or configured == "" or not chname then
		return false
	end

	local targetUpper = strupper(TrimString(chname))
	local idStr = channelId and tostring(channelId) or nil

	-- Support comma- or semicolon-separated channel names
	for token in string.gmatch(configured, "[^,;]+") do
		local trimmed = TrimString(token)
		if trimmed ~= "" then
			if strupper(trimmed) == targetUpper or (idStr and trimmed == idStr) then
				return true
			end
		end
	end

	return false
end

-- Utility function to safely get character name (guards against secret values on Forever/12.0+)
function Name2Chat:GetCharacterName()
	if not character_name
		or character_name == ""
		or character_name == UNKNOWNOBJECT
		or IsSecret(character_name)
	then
		local unitName = UnitName and UnitName("player")
		if unitName
			and not IsSecret(unitName)
			and unitName ~= ""
			and unitName ~= UNKNOWNOBJECT
		then
			character_name = unitName
		end
	end
	if not character_name or IsSecret(character_name) then
		return nil
	end
	return character_name
end

-- True if the configured name matches the current character's name (case-insensitive, trimmed)
function Name2Chat:NameMatchesCharacter()
	local charName = self:GetCharacterName()
	local configuredName = self.db and self.db.profile and self.db.profile.name
	if not charName or not configuredName or IsSecret(configuredName) then
		return false
	end
	return strlower(TrimString(configuredName)) == strlower(TrimString(charName))
end
