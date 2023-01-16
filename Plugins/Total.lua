local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_Total"
local Sorted_Name = "Total"
local Sorted_Sort = "All"

Sorted.Color.CYAN = CreateColor(0,1,1)

local CreateElement = function(f)
    f.totalString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.totalString:SetPoint("RIGHT", -2, 0)
    f.totalString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())    
    f.totalString:SetAlpha(0.5)
end

local UpdateElement = function(self, data)
    if not data.totalCount or data.totalCount <= 1 then
        self.totalString:SetText("")
    else
        self.totalString:SetText("(" .. data.totalCount .. ")")
        if data.filtered then
            self.totalString:SetAlpha(0.5)
            self.totalString:SetTextColor(Sorted.Color.GREY:GetRGB())
        else
            if data.totalCount > data.combinedCount then
                self.totalString:SetAlpha(0.8)
                self.totalString:SetTextColor(Sorted.Color.CYAN:GetRGB())
            else
                self.totalString:SetAlpha(0.5)
                self.totalString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
            end
        end
    end
end

local Sort = function(asc, data1, data2)
    if data1.totalCount == data2.totalCount then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if not data1.totalCount then
        return asc
    elseif not data2.totalCount then
        return not asc
    end
    if asc then
        return data1.totalCount < data2.totalCount
    else
        return data1.totalCount > data2.totalCount
    end
end

local PreSort = function(itemData)
    itemData.totalCount = _G.GetItemCount(itemData.itemID, true, nil, true)
end

Sorted:AddItemColumn(Sorted_Column, Sorted_Name, 48, CreateElement, UpdateElement)
Sorted:AddSortMethod(Sorted_Column, Sorted_Sort, Sort, false)
Sorted:AddDataToItem(Sorted_Column, PreSort)