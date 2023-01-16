local ADDON_NAME = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), ADDON_NAME, "AceConsole-3.0");

local AddonDB_Defaults = {
  profile = {
    EquipmentSets = { showText = false, },
    TSM = { priceSource = "DBMarket", },
  },
}

function Addon:OnInitialize()
	Addon.db = LibStub("AceDB-3.0"):New(ADDON_NAME .. "DB", AddonDB_Defaults, true) -- set true to prefer 'Default' profile as default
end