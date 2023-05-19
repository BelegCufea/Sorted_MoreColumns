local Addon = select(2, ...)
local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_UpgradeLevel"
local Sorted_Name = "Upgrade level"
local Sorted_Sort = "(U)"

Sorted.Color.CYAN = CreateColor(0,1,1)

local private = {}

local ITEM_UPGRADE_TOOLTIP_1 = strsplit(":",ITEM_UPGRADE_TOOLTIP_FORMAT)..CHAT_HEADER_SUFFIX
local ITEM_UPGRADE_TOOLTIP_2 = strsplit(":",ITEM_UPGRADE_TOOLTIP_FORMAT_STRING)..CHAT_HEADER_SUFFIX

private.OnUpdate = function(data)
    if data.link and data.link then
        data.mc_upgradeLevel = nil
        local tooltipData = C_TooltipInfo.GetHyperlink(data.link)
        if tooltipData then
            for _, v in ipairs(tooltipData.lines) do
                if v.leftText then
                    local found, type, upgrade
                    if v.leftText:find(ITEM_UPGRADE_TOOLTIP_1) then
                        found = true
                        data.mc_upgradeLevel = v.leftText:gsub(ITEM_UPGRADE_TOOLTIP_1,"")
                        type, upgrade = data.mc_upgradeLevel:match("(%w+)%s+(%S+)")
                    elseif v.leftText:find(ITEM_UPGRADE_TOOLTIP_2) then
                        found = true
                        data.mc_upgradeLevel = v.leftText:gsub(ITEM_UPGRADE_TOOLTIP_2,"")
                        type, upgrade = data.mc_upgradeLevel:match("(%w+)%s+(%S+)")
                    end
                    if found then
                        if type then
                            data.mc_upgradeLevel = type:sub(1, Addon.db.profile.UpgradeLevel.numChars) .. upgrade
                        end
                        if not upgrade then
                            upgrade = data.mc_upgradeLevel
                        end
                        local cur, max = upgrade:match("(%d+)/(%d+)")
                        data.mc_upgradeLevelFull = cur == max
                    end
                end
            end
        end
    else
        data.mc_upgradeLevel = nil
    end
end

local CreateElement = function(f)
    f.upgradeLevelString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.upgradeLevelString:SetPoint("RIGHT", 0, 0)
    f.upgradeLevelString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
end
local UpdateElement = function(f, data)
    private.OnUpdate(data)
    if not data.mc_upgradeLevel then
        f.upgradeLevelString:SetText("")
    else
        f.upgradeLevelString:SetText(data.mc_upgradeLevel)
        if data.filtered then
            f.upgradeLevelString:SetAlpha(0.4)
            f.upgradeLevelString:SetTextColor(Sorted.Color.GREY:GetRGB())
        elseif data.mc_upgradeLevelFull then
            f.upgradeLevelString:SetAlpha(0.8)
            f.upgradeLevelString:SetTextColor(Sorted.Color.CYAN:GetRGB())
        else
            f.upgradeLevelString:SetAlpha(0.5)
            f.upgradeLevelString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
        end
    end
end

local Sort = function(asc, data1, data2)
    if data1.mc_upgradeLevel == data2.mc_upgradeLevel then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if not data1.mc_upgradeLevel then
        return asc
    elseif not data2.mc_upgradeLevel then
        return not asc
    end
    if asc then
        return data1.mc_upgradeLevel < data2.mc_upgradeLevel
    else
        return data1.mc_upgradeLevel > data2.mc_upgradeLevel
    end
end

local PreSort = function(itemData)
    if Sorted.IsPlayingCharacterSelected() and not itemData.isGuild then
        private.OnUpdate(itemData)
    end
end

Sorted:AddItemColumn(Sorted_Column, Sorted_Name, 48, CreateElement, UpdateElement)
Sorted:AddSortMethod(Sorted_Column, Sorted_Sort, Sort, false)
Sorted:AddDataToItem(nil, PreSort)