local Addon = select(2, ...)

local Config = Addon:NewModule("Config")
Addon.Config = Config

local AddonTitle = "Sorted" .. GetAddOnMetadata(..., "Title")

local options = {
	name = AddonTitle,
	type = "group",
	args = {
		EquipmentSetsText = {
			type = "toggle",
			name = "Equipment Sets as text",
			desc = "Show equipment sets as text instead icon.",
            width = "full",
			get = function(info) return Addon.db.profile.EquipmentSets.showText end,
			set = function(info, value)
				Addon.db.profile.EquipmentSets.showText = value
			end,
		},
		TSMPriceSource = {
			type = "select",
			name = "TSM Price Source",
			desc = "Predefined price sources for item value calculation.",
			width = "double",
			values = function() return Addon.TSM.GetAvailablePriceSources() end,
			get = function(info)
				return Addon.db.profile.TSM.priceSource
			end,
			set = function(info, value)
				Addon.db.profile.TSM.priceSource = value
			end,
		}
	},
}

function Config:OnEnable()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddonTitle, options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonTitle)
end