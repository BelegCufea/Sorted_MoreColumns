local Addon = select(2, ...)
local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_TSM"
local Sorted_Name = "Auction"
local Sorted_Sort = "TSM"

local TSM = {}
Addon.TSM = TSM
local TSM_API = _G.TSM_API

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
		return {[Addon.db.profile.TSM.priceSource] = "TSM not loaded!"}
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
		tsmPriceSources[v] = CONST.PRICE_SOURCE[v]
	end

	return tsmPriceSources
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
local UpdateElement = function(f, data)
    if data.mc_tsm and data.mc_tsm > 0 then
        f.valueIcon:SetTexture(Sorted.GetValueIcon(data.mc_tsm * data.combinedCount))
        f.valueString:SetText(Sorted.FormatValueStringNoIcon(data.mc_tsm * data.combinedCount))

        if data.filtered then
            f.valueString:SetTextColor(Sorted.Color.GREY:GetRGB())
            f.valueIcon:SetDesaturated(true)
            f.valueIcon:SetVertexColor(Sorted.Color.LIGHT_GREY:GetRGB())
        else
            local color = Sorted.GetValueColor(data.mc_tsm * data.combinedCount)
            f.valueString:SetTextColor(color:GetRGB())
            f.valueIcon:SetDesaturated(false)
            f.valueIcon:SetVertexColor(Sorted.Color.WHITE:GetRGB())
        end
    else
        f.valueString:SetText("")
        f.valueIcon:SetTexture("")
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
    if Sorted.IsPlayingCharacterSelected() and not itemData.isGuild then
        if itemData.link then
            local PriceSource = Addon.db.profile.TSM.priceSource
            itemData.mc_tsm = nil
            if TSM.IsTSMLoaded() and TSM_API.GetCustomPriceValue then
                local tsmItemLink = TSM_API.ToItemString(itemData.link)
                if tsmItemLink then
                    itemData.mc_tsm = TSM_API.GetCustomPriceValue(PriceSource, tsmItemLink)
                end
            end
        else
            itemData.mc_tsm = nil
        end
    end
end

Sorted:AddItemColumn(Sorted_Column, Sorted_Name, 48, CreateElement, UpdateElement)
Sorted:AddSortMethod(Sorted_Column, Sorted_Sort, Sort, false)
Sorted:AddDataToItem(nil, PreSort)