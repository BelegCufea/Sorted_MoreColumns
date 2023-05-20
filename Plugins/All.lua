local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_All"
local Sorted_Name = "Sum of every container"
local Sorted_Sort = "All"

Sorted.Color.CYAN = CreateColor(0,1,1)

local private = {}

private.OnUpate = function(data)
    if data.link then
        data.mc_allCount = _G.GetItemCount(data.itemID, true, nil, true)
    else
        data.mc_allCount = nil
    end
end

local CreateElement = function(f)
    f.allString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.allString:SetPoint("RIGHT", -2, 0)
    f.allString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
    f.allString:SetAlpha(0.5)
end

local UpdateElement = function(f, data)
    private.OnUpate(data)
    if not data.mc_allCount or data.mc_allCount <= 1 then
        f.allString:SetText("")
    else
        f.allString:SetText("(" .. data.mc_allCount .. ")")
        if data.filtered then
            f.allString:SetAlpha(0.5)
            f.allString:SetTextColor(Sorted.Color.GREY:GetRGB())
        else
            if data.mc_allCount > data.combinedCount then
                f.allString:SetAlpha(0.8)
                f.allString:SetTextColor(Sorted.Color.CYAN:GetRGB())
            else
                f.allString:SetAlpha(0.5)
                f.allString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
            end
        end
    end
end

local Sort = function(asc, data1, data2)
    if data1.mc_allCount == data2.mc_allCount then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if not data1.mc_allCount then
        return asc
    elseif not data2.mc_allCount then
        return not asc
    end
    if asc then
        return data1.mc_allCount < data2.mc_allCount
    else
        return data1.mc_allCount > data2.mc_allCount
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