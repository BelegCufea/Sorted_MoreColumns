local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_Total"
local Sorted_Name = "Sum of every character"
local Sorted_Sort = "Total"

Sorted.Color.CYAN = CreateColor(0,1,1)
local sortedData = Sorted_Data

local private = {}

private.OnUpate = function(data)
    local totalCount = 0
    if data.link then

        for _, player in pairs(sortedData) do
            for _, container in pairs(player.containers) do
                for _, slot in pairs(container) do
                    if slot.itemID == data.itemID and slot.count then
                        totalCount = totalCount + slot.count
                    end
                end
            end
        end
        data.mc_totalCountChar = _G.GetItemCount(data.itemID, true, nil, true)
        data.mc_totalCount = totalCount
    else
        data.mc_totalCountChar = nil
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
    if not data.mc_totalCount or not data.mc_totalCountChar or data.mc_totalCount <= 1 then
        f.totalString:SetText("")
    else
        f.totalString:SetText("[" .. data.mc_totalCount .. "]")
        if data.filtered then
            f.totalString:SetAlpha(0.5)
            f.totalString:SetTextColor(Sorted.Color.GREY:GetRGB())
        else
            if data.mc_totalCount > data.mc_totalCountChar then
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