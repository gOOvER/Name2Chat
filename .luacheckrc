-- LuaCheck configuration for WoW Addons
std = "lua51"

-- Global WoW API functions that luacheck should ignore
globals = {
  -- Core WoW Addon globals
  "Name2Chat", "Name2ChatDB",
  
  -- WoW Global Functions
  "LibStub", "GetBuildInfo", "UnitName", "GetChannelName",
  "WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC",
  "WOW_PROJECT_BURNING_CRUSADE_CLASSIC", "WOW_PROJECT_WRATH_CLASSIC",
  "WOW_PROJECT_CATACLYSM_CLASSIC",
  
  -- Ace3 Framework
  "AceAddon", "AceConsole", "AceEvent", "AceHook", "AceConfig", 
  "AceConfigDialog", "AceConfigRegistry", "AceDB", "AceDBOptions",
  "AceLocale",
  
  -- WoW Chat API
  "SendChatMessage", "C_ChatInfo", "ChatFrame_AddMessageEventFilter",
  "ChatFrame_RemoveMessageEventFilter", "DEFAULT_CHAT_FRAME",
  
  -- WoW String Functions
  "strupper", "strlower", "strsub", "strlen", "strfind", "gsub", 
  "format", "strmatch", "gmatch", "strjoin", "strsplit",
  
  -- WoW Unit Functions
  "GetRealmName", "GetLocale",
  
  -- Standard Lua enhanced by WoW
  "print", "error", "type", "select", "pairs", "ipairs", "next",
  "tostring", "tonumber", "table", "math", "bit", "time", "date",
  "string", "unpack", "wipe", "tinsert", "tremove", "sort",
  
  -- Slash Commands
  "SLASH_NAME2CHAT1", "SLASH_NAME2CHAT2", "SlashCmdList",
  
  -- Global WoW Environment
  "_G", "SLASH_"
}

-- Ignore warnings that are normal in WoW addon development
ignore = {
  "111", -- setting non-standard global variable (addon globals)
  "112", -- mutating non-standard global variable (addon state)
  "113", -- accessing undefined variable (WoW API not in std)
  "211", -- unused variable (common in WoW event handling)
  "212", -- unused argument (self, event handlers)
  "213", -- unused loop variable
  "611", -- line contains only whitespace
  "631", -- line is too long (WoW API names can be verbose)
}

-- Files to check
files = {
  "Name2Chat.lua"
}