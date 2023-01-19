local Addon = select(2, ...)
local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_TSM"
local Sorted_Name = "Auction"
local Sorted_Sort = "TSM"

local TSM = {}
Addon.mc_tsm = TSM
local TSM_API = _G.mc_tsm_API

local CONST = {}

-- TSM predefined price sources
CONST.PRICE_SOURCE = {
    -- TSM price sources
    ["DBHistorical"] = "TSM: Historical Price",
    ["DBMarket"] = "TSM: Market Value",
    ["DBRecent"] = "TSM: Recent Market Value",
    ["DBMinBuyout"] = "TSM: Min Buyout",
    ["DBRegionHistorical"] = "TSM: Region Historical Price",
    ["DBRegionMarketAvg"] = "TSM: Region Market Value Avg",
    ["DBRegionMinBuyoutAvg"] = "TSM: Region Min Buyout Avg",
    ["DBRegionSaleAvg"] = "TSM: Region Global Sale Average",
}

function TSM.IsTSMLoaded()
	if TSM_API then
		return true
	end
	return false
end

function TSM.GetAvailablePriceSources()
	if not TSM.IsTSMLoaded() then
		return {[Addon.db.profile.mc_tsm.priceSource] = "TSM not loaded!"}
	end

	local keys = {}

	-- filter
	local tsmPriceSources = {}
    TSM_API.GetPriceSourceKeys(tsmPriceSources)

	for k, v in pairs(tsmPriceSources) do
		if CONST.PRICE_SOURCE[k] then
			table.insert(keys, k)
		elseif CONST.PRICE_SOURCE[v] then
			table.insert(keys, v)
		end
	end


	sort(keys)

	for _,v in ipairs(keys) do
		priceSources[v] = CONST.PRICE_SOURCE[v]
	end

	return priceSources
end

local CreateElement = function(f)
    f.valueIcon = f:CreateTexture()
    f.valueIcon:SetPoint("RIGHT", -2, 0)
    f.valueString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.valueString:SetPoint("RIGHT",  f.valueIcon, "LEFT", -2, 0)
    f.valueString:SetPoint("LEFT", 2, 0)
    f.valueString:SetHeight(1)
    f.valueString:SetJustifyH("RIGHT")
end
local UpdateElement = function(self, data)
    if data.mc_tsm and data.mc_tsm > 0 then
        self.valueIcon:SetTexture(Sorted.GetValueIcon(data.mc_tsm * data.combinedCount))
        self.valueString:SetText(Sorted.FormatValueStringNoIcon(data.mc_tsm * data.combinedCount))

        if data.filtered then
            self.valueString:SetTextColor(Sorted.Color.GREY:GetRGB())
            self.valueIcon:SetDesaturated(true)
            self.valueIcon:SetVertexColor(Sorted.Color.LIGHT_GREY:GetRGB())
        else
            local color = Sorted.GetValueColor(data.mc_tsm * data.combinedCount)
            self.valueString:SetTextColor(color:GetRGB())
            self.valueIcon:SetDesaturated(false)
            self.valueIcon:SetVertexColor(Sorted.Color.WHITE:GetRGB())
        end
    else
        self.valueString:SetText("")
        self.valueIcon:SetTexture("")
    end
end

local Sort = function(asc, data1, data2)
    if data1.mc_tsm == data2.mc_tsm then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if not data1.mc_tsm then
        return asc
    elseif not data2.mc_tsm then
        return not asc
    end
    if asc then
        return data1.mc_tsm * data1.combinedCount < data2.mc_tsm * data2.combinedCount
    else
        return data1.mc_tsm * data1.combinedCount > data2.mc_tsm * data2.combinedCount
    end
end

local PreSort = function(itemData)
    local PriceSource = Addon.db.profile.mc_tsm.priceSource
    itemData.mc_tsm = nil
    if TSM.IsTSMLoaded() and TSM_API.GetCustomPriceValue then
        local tsmItemLink = TSM_API.ToItemString(itemData.link)
        if tsmItemLink then
            itemData.mc_tsm = TSM_API.GetCustomPriceValue(PriceSource, tsmItemLink)
        end
    end
end

Sorted:AddItemColumn(Sorted_Column, Sorted_Name, 48, CreateElement, UpdateElement)
Sorted:AddSortMethod(Sorted_Column, Sorted_Sort, Sort, false)
Sorted:AddDataToItem(Sorted_Column, PreSort)