local Locations = require("locations")
local Functions = require("functions")
local L = {}
L.subscribed = false

function L.Setup(tab3)
    local tab3Text1, tab3Text2, tab3Text3, tab3Text4, tab3Text5, tab3Sprite1
    local coordGrid = nil
    local shapeListTab3
    local colorBlueA = 0x0000FF27
    local colorBlue = 0x0000FFAA

    local function  CleanTab3()
        tab3Text1.content = ""
        tab3Text2.content = ""
        tab3Text3.content = ""
        tab3Text4.content = ""
        tab3Text5.content = ""
        coordGrid = nil
        tab3Sprite1:SetSprite(Plugin.resources.empty)
    end
    local function FindLocationById(id)
        for _, abbrev in ipairs(Locations) do
            if(abbrev.id == id) then
                return abbrev
            end
        end
        return nil
    end
    local function FindLocationByFullName(fullName)
        for _, abbrev in ipairs(Locations) do
            if(string.lower(abbrev.name) == string.lower(fullName)) then
                return abbrev            
            end
            if(abbrev.abbreviation ~= nil) then
                for _, abbrevName in ipairs(abbrev.abbreviation) do
                    if(string.lower(tostring(abbrevName)) == string.lower(fullName)) then
                        return abbrev
                    end
                end
            end
        end
        return nil
    end
    local function FindLocationByPartialName(partialName)
        for _, abbrev in ipairs(Locations) do
            if(string.find(string.lower(abbrev.name), string.lower(partialName), 1, true)) then
                return abbrev
            end
            if(abbrev.abbreviation ~= nil) then
                for _, abbrevName in ipairs(abbrev.abbreviation) do
                    if(string.find(string.lower(tostring(abbrevName)), string.lower(partialName), 1, true)) then
                        return abbrev
                    end
                end            
            end
        end
        return nil
    end
    local function CalloutBoxChange(field, reason, text)
        local partial = false
        local abbrev = nil
        abbrev = FindLocationByFullName(text)
        if(abbrev == nil) then
            abbrev = FindLocationByPartialName(text)
            if(abbrev ~= nil) then
                partial = true
            end
        end
        if(text == "") then
            CleanTab3()
            return
        end
        if(abbrev == nil) then
            return
        end

        if(abbrev ~= nil) then
            if(abbrev.isRegion) then
                tab3Text1.content = "Region: " .. abbrev.name
                tab3Text2.content = ""
                tab3Text3.content = ""
                tab3Text4.content = ""
                tab3Text5.content = ""
                coordGrid = nil
            else
                local calloutRegion = FindLocationById(abbrev.regionId)
                tab3Text1.content = abbrev.name
                if(calloutRegion == nil) then
                    print("Missing region for abbrev: "..abbrev.name)
                else
                    tab3Text2.content = "(Region: " .. calloutRegion.name .. ")"
                end
                tab3Text3.content = "Nearest Teleport: " .. abbrev.nearestTeleport
                tab3Text4.content = "Nearest Lodestone: " .. abbrev.nearestLodestone
                coordGrid = CoordGrid.new(0)
                coordGrid.x = abbrev.coordGridX
                coordGrid.z = abbrev.coordGridZ
                coordGrid.level = abbrev.coordGridLevel
            end

            if(abbrev.map == nil) then
                print("Missing map for abbrev: "..abbrev.name)
                tab3Sprite1:SetSprite(Plugin.resources.empty)
            else
                tab3Sprite1:SetSprite(abbrev.map)
            end
        end
    end
    local calloutLookup = tab3:AddTextField({ placeholder = "Look up location", onChange = CalloutBoxChange, width = 175})

    local function GoToLocation(button, active)
        Functions.ClearShape(shapeListTab3)
        if(not L.subscribed) then
            if(coordGrid == nil) then
                return
            end
            L.subscribed = true
            button:SetText("Stop travel")
            Event.ServerLogic.Subscribe("LocationLocatorEvent", function()
                if(coordGrid == nil) then
                    Functions.ClearShape(shapeListTab3)
                    return
                else
                    local playerCoordGrid = Player.GetEntity().coordGrid
                    tab3Text5.content = "You are "..Functions.CheckDirection(playerCoordGrid, coordGrid).." of the location"
                    shapeListTab3 = Functions.CreateBox(coordGrid, colorBlueA, colorBlue, shapeListTab3, "tab3")
                end
            end)
        else
            L.subscribed = false
            button:SetText("Go to")
            Functions.ClearShape(shapeListTab3)
            tab3Text5.content = ""
            Event.ServerLogic.Unsubscribe("LocationLocatorEvent")
        end

    end

    --#region Controls
    tab3:AddFancyButton("Go to", GoToLocation, {inline = true, width = 75})

    --Name of location
    tab3Text1 = tab3:AddText({ text = "" })
    --Name of region if applicable
    tab3Text2 = tab3:AddText({ text = "" })
    --Nearest teleport if applicable
    tab3Text3 = tab3:AddText({ text = "" })
    --Nearest lodestone if applicable
    tab3Text4 = tab3:AddText({ text = "" })

    tab3:AddDivider({marginTop = 1, marginBottom = 1})

    --Direct to location
    tab3Text5 = tab3:AddText({ text = "" })
    --Map of location
    tab3Sprite1 = tab3:AddSprite(Plugin.resources.empty, {width = 375, height = 215})
    --#endregion
end
return L