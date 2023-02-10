local Addon = select(2, ...)
local Sorted = LibStub("Sorted.")

local Sorted_Column = "MC_EquipmentSets"
local Sorted_Name = "Equipment Sets"
local Sorted_Sort = "|TInterface\\AddOns\\Sorted_MoreColumns\\Textures\\EquipmentManager:18:18:0:0:32:32:0:32:0:32|t"

local private = {}

private.OnUpdate = function(data)
    if data.link then
        local ShowText = Addon.db.profile.EquipmentSets.showText
        data.mc_equipmentSets = nil
        for setIndex=1, C_EquipmentSet.GetNumEquipmentSets() do
            local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
            local equipmentSetID = equipmentSetIDs[setIndex]
            local name, icon, setID, isEquipped, numItems, numEquipped, numInventory, numMissing, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID)

            local equipLocations = C_EquipmentSet.GetItemLocations(equipmentSetID)
            if equipLocations then
                for locationIndex=INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
                    local location = equipLocations[locationIndex]
                    if location ~= nil then
                        -- TODO: Keep an eye out for a new way to do this in the API
                        local isPlayer, isBank, isBags, isVoidStorage, equipSlot, equipBag, equipTab, equipVoidSlot = EquipmentManager_UnpackLocation(location)
                        equipSlot = tonumber(equipSlot)
                        equipBag = tonumber(equipBag)

                        local isFound = false

                        if isBank and not equipBag then -- main bank container
                            local foundLink = GetInventoryItemLink("player", equipSlot)
                            if foundLink == data.link then
                                isFound = true
                            end
                        elseif isBank or isBags then -- any other bag
                            local itemLocation = ItemLocation:CreateFromBagAndSlot(equipBag, equipSlot)
                            if itemLocation:HasAnyLocation() and itemLocation:IsValid() then
                                local foundLink = C_Item.GetItemLink(itemLocation)
                                if foundLink == data.link then
                                    isFound = true
                                end
                            end
                        end

                        if isFound then
                            if ShowText then
                                if data.mc_equipmentSets then
                                    data.mc_equipmentSets = data.mc_equipmentSets .. ", " .. name
                                else
                                    data.mc_equipmentSets = name
                                end
                            else
                                if data.mc_equipmentSets then
                                    data.mc_equipmentSets = data.mc_equipmentSets .. " |T" .. icon .. ":16|t"
                                else
                                    data.mc_equipmentSets = "|T" .. icon .. ":16|t"
                                end
                            end

                            break
                        end
                    end
                end
            end
        end
    else
        data.mc_equipmentSets = nil
    end
end

local CreateElement = function(f)
    f.equipmentsetsString = f:CreateFontString(nil, "OVERLAY", "SortedFont")
    f.equipmentsetsString:SetPoint("LEFT", -2, 0)
    f.equipmentsetsString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
end
local UpdateElement = function(f, data)
    --private.OnUpdate(data)
    if not data.mc_equipmentSets then
        f.equipmentsetsString:SetText("")
    else
        f.equipmentsetsString:SetText(data.mc_equipmentSets)
        if data.filtered then
            f.equipmentsetsString:SetAlpha(0.4)
            f.equipmentsetsString:SetTextColor(Sorted.Color.GREY:GetRGB())
        else
            f.equipmentsetsString:SetAlpha(1)
            f.equipmentsetsString:SetTextColor(Sorted.Color.YELLOWISH_TEXT:GetRGB())
        end
    end
end

local Sort = function(asc, data1, data2)
    if data1.mc_equipmentSets == data2.mc_equipmentSets then
        return Sorted.DefaultItemSort(data1, data2)
    end
    if not data1.mc_equipmentSets then
        return asc
    elseif not data2.mc_equipmentSets then
        return not asc
    end
    if asc then
        return data1.mc_equipmentSets < data2.mc_equipmentSets
    else
        return data1.mc_equipmentSets > data2.mc_equipmentSets
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