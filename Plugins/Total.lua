local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_Total"
local Sorted_Name = "Total"
local Sorted_Sort = "All"

Sorted.Color.CYAN = CreateColor(0,1,1)

local private = {}

private.OnUpate = function(data)
    if data.link then
        data.mc_totalCount = _G.GetItemCount(data.itemID, true, nil, true)
    else
        data.mc_totalCount = nil
    end
end

local CreateElement = function(f)
    f.totalString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.totalString:SetPoint("RIGHT", -2, 0)
    f.totalString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
    f.totalString:SetAlpha(0.5)
end

local UpdateElement = function(f, data)
    private.OnUpate(data)
    if not data.mc_totalCount or data.mc_totalCount <= 1 then
        f.totalString:SetText("")
    else
        f.totalString:SetText("(" .. data.mc_totalCount .. ")")
        if data.filtered then
            f.totalString:SetAlpha(0.5)
            f.totalString:SetTextColor(Sorted.Color.GREY:GetRGB())
        else
            if data.mc_totalCount > data.combinedCount then
                f.totalString:SetAlpha(0.8)
                f.totalString:SetTextColor(Sorted.Color.CYAN:GetRGB())
            else
                f.totalString:SetAlpha(0.5)
                f.totalString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
            end
        end
    end
end

local Sort = function(asc, data1, data2)
    if data1.mc_totalCount == data2.mc_totalCount then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if not data1.mc_totalCount then
        return asc
    elseif not data2.mc_totalCount then
        return not asc
    end
    if asc then
        return data1.mc_totalCount < data2.mc_totalCount
    else
        return data1.mc_totalCount > data2.mc_totalCount
    end
end

local PreSort = function(itemData)
    if Sorted.IsPlayingCharacterSelected() and not itemData.isGuild then
        private.OnUpate(itemData)
    end
end

Sorted:AddItemColumn(Sorted_Column, Sorted_Name, 48, CreateElement, UpdateElement)
Sorted:AddSortMethod(Sorted_Column, Sorted_Sort, Sort, false)
Sorted:AddDataToItem(nil, PreSort)