------------------------
---      Module      ---
------------------------

Name2Chat  = LibStub("AceAddon-3.0"):NewAddon(	"Name2Chat",
												"AceConsole-3.0",
												"AceEvent-3.0",
												"AceHook-3.0");


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
		},
                bracketStyle = {
                        order = 11,
                        type = "select",
                        name = L["bracketStyle"],
                        desc = L["bracketStyle_desc"],
                        values = {
                                curly = L["bracketStyle_curly"],
                                square = L["bracketStyle_square"],
                                round = L["bracketStyle_round"],
                                angle = L["bracketStyle_angle"],
                        },
                },
                ignoreLeadingSymbols = {
                        order = 12,
                        type = "input",
                        name = L["ignoreLeadingSymbols"],
                        desc = L["ignoreLeadingSymbols_desc"],
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
		bracketStyle = "square",
		ignoreLeadingSymbols = "/!#@?.",
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
				if Settings and Settings.OpenToCategory then
					Settings.OpenToCategory("Name2Chat")
				elseif InterfaceOptionsFrame_OpenToCategory then
					InterfaceOptionsFrame_OpenToCategory(Name2Chat.optionFrames.main)
				end
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

	-- Hook SendChatMessage function (global fallback)
	self:SecureHook("SendChatMessage", "SendChatMessageGlobal")
	-- Hook C_ChatInfo.SendChatMessage (Retail path)
	if C_ChatInfo and type(C_ChatInfo.SendChatMessage) == "function" then
		self:SecureHook(C_ChatInfo, "SendChatMessage", "SendChatMessageC")
	end
	-- Do NOT raw-hook ChatEdit_* (secure in 11.x). We'll hook edit boxes directly instead.

	if self.db.profile.debug then
		self:Print("Name2Chat: Hooks installed (SendChatMessage, C_ChatInfo.SendChatMessage)")
	end

	-- get current character name
	character_name, _ = UnitName("player")

	self:Safe_Print(L["Loaded"])
end

function Name2Chat:OnEnable()
	-- Attach to chat edit boxes and reattach when chat windows change
	self:AttachEditBoxHooks()
	self:RegisterEvent("UPDATE_CHAT_WINDOWS", "AttachEditBoxHooks")
end

--------------------------------
---      Event Handlers      ---
--------------------------------

-- Helpers to build the nickname prefix according to selected bracket style
function Name2Chat:GetBracketPair()
	local style = self.db and self.db.profile and self.db.profile.bracketStyle or "square"
	if style == "curly" then return "{", "}" end
	if style == "round" then return "(", ")" end
	if style == "angle" then return "<", ">" end
	return "[", "]"
end

function Name2Chat:GetPrefix()
    if not (self.db and self.db.profile and self.db.profile.name and self.db.profile.name ~= "") then return nil end
    local l, r = self:GetBracketPair()
    return l .. self.db.profile.name .. r .. ": "
end

-- Helper: check if already prefixed
local function AlreadyPrefixed(text)
    if type(text) ~= "string" then return true end
    local prefix = Name2Chat:GetPrefix()
    if not prefix then return true end
    return string.sub(text, 1, #prefix) == prefix
end

 -- Helper: should prefix based on chat type and settings
 function Name2Chat:ShouldPrefixForChatType(chatType)
     if not chatType then return false end
     if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER")) then return true end
     if (self.db.profile.raid and (chatType == "RAID" or chatType == "RAID_LEADER" or chatType == "RAID_WARNING")) then return true end
     if (self.db.profile.party and (chatType == "PARTY" or chatType == "PARTY_LEADER")) then return true end
     if (self.db.profile.instance_chat and (chatType == "INSTANCE_CHAT" or chatType == "INSTANCE_CHAT_LEADER")) then return true end
     return false
 end

 -- Helper: build prefixed message if conditions are met
 function Name2Chat:BuildPrefixedMessageIfNeeded(text, chatType, channelRef)
     if not self.db.profile.enable then return text end
     if not (self.db.profile.name and self.db.profile.name ~= "") then return text end
     if (self.db.profile.hideOnMatchingCharName and self.db.profile.name == character_name) then return text end
     -- Never modify slash commands (e.g., /reload, /p, /g)
     if type(text) == "string" and string.match(text, "^%s*/") then return text end
    -- Ignore other common command symbols the user configures
    if type(text) == "string" and self.db.profile.ignoreLeadingSymbols and self.db.profile.ignoreLeadingSymbols ~= "" then
        local first = string.match(text, "^%s*(.)")
        if first and string.find(self.db.profile.ignoreLeadingSymbols, first, 1, true) then
            return text
        end
    end
    if self.db.profile.ignoreExclamationMark and type(text) == "string" and string.sub(text, 1, 5) == '!keys' then return text end
    if AlreadyPrefixed(text) then return text end

     local prefix = self:GetPrefix()
     if not prefix then return text end
 
     -- Group/instance/guild/raid path
     if self:ShouldPrefixForChatType(chatType) then
        return prefix .. text
     end
 
     -- Channel path
     if (self.db.profile.channel and self.db.profile.channel ~= "" and chatType == "CHANNEL") then
         local _, chname = GetChannelName(channelRef)
         if chname and strupper(self.db.profile.channel) == strupper(chname) then
            return prefix .. text
         end
     end
 
     return text
 end

-- Global SendChatMessage hook (classic and fallback)
function Name2Chat:SendChatMessageGlobal(msg, chatType, language, channel, ...)
    -- SecureHook: cannot modify arguments or call original here. Rely on ChatEdit_* hooks for user-typed messages.
    -- Optionally debug what would be sent:
    if self.db and self.db.profile and self.db.profile.debug then
        local would = self:BuildPrefixedMessageIfNeeded(msg, chatType, channel)
        if would ~= msg then
            self:Safe_Print("Would prefix outgoing message via SendChatMessage")
        end
    end
end

-- Retail C_ChatInfo.SendChatMessage hook
function Name2Chat:SendChatMessageC(msg, chatType, language, channel, target, ...)
    -- SecureHook: cannot modify arguments or call original here. Rely on ChatEdit_* hooks for user-typed messages.
    if self.db and self.db.profile and self.db.profile.debug then
        local would = self:BuildPrefixedMessageIfNeeded(msg, chatType, channel)
        if would ~= msg then
            self:Safe_Print("Would prefix outgoing message via C_ChatInfo.SendChatMessage")
        end
    end
end

-- Normalize chat type strings from edit boxes to the standard forms.
-- This helper converts special chat types (e.g. "BN_WHISPER" or leader channels)
-- to the base forms expected by SendChatMessage.
local function NormalizeChatType(chatType)
        if chatType == "BN_WHISPER" then
                return "WHISPER"
        elseif chatType == "INSTANCE" or chatType == "INSTANCE_LEADER" then
                return "INSTANCE_CHAT"
        elseif chatType == "PARTY_LEADER" then
                return "PARTY"
        elseif chatType == "RAID_LEADER" then
                return "RAID"
        end
        return chatType
end

-- Attach hooks to all chat edit boxes
function Name2Chat:AttachEditBoxHooks()
	local function resolveEditBox(cf, i)
		if not cf then return _G["ChatFrame" .. i .. "EditBox"] end
		if cf.editBox then return cf.editBox end
		if cf.GetEditBox then return cf:GetEditBox() end
		return _G["ChatFrame" .. i .. "EditBox"]
	end
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		local edit = resolveEditBox(cf, i)
		if edit and not self:IsHooked(edit, "OnEnterPressed") then
			-- Use RawHookScript so we can modify text before send
			self:RawHookScript(edit, "OnEnterPressed", "EditBox_OnEnterPressed")
		end
	end
	if self.db and self.db.profile and self.db.profile.debug then
		self:Print("EditBox hooks attached")
	end
end

function Name2Chat:EditBox_OnEnterPressed(editBox)
	local text = editBox:GetText()
	local chatType = editBox:GetAttribute("chatType")
	local channelTarget = editBox:GetAttribute("channelTarget")
        chatType = NormalizeChatType(chatType)

	local newText = self:BuildPrefixedMessageIfNeeded(text, chatType, channelTarget)
	if type(newText) == "string" and newText ~= text then
		editBox:SetText(newText)
		if self.db and self.db.profile and self.db.profile.debug then
			self:Print("Prefix applied in EditBox_OnEnterPressed")
		end
	end
	-- Call original script
	return self.hooks[editBox].OnEnterPressed(editBox)
end

---------------------------
---      Functions      ---
---------------------------

function Name2Chat:Safe_Print(msg)
	if self.db.profile.debug then
		self:Print(msg)
	end
end
