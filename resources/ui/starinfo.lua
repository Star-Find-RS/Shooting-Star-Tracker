local Stars = require("resources/star sizes")
local Functions = require("resources/functions")
local S = {}
S.subscribed = false

S.Setup = function(tab1)
    --Tab 1
    local tab1Text1, tab1Text2, tab1Text3, tab1Text4, tab1Text5
    
    local shapeListTab1
    local colorGreenA = 0x00FF0027
    local colorGreen = 0x00FF00AA
    local function ClearTextTab1()
        tab1Text1.content = ""
        tab1Text2.content = ""
        tab1Text3.content = ""
        tab1Text4.content = ""
        tab1Text5.content = ""
    end
    local function LookUpId(configValue)
        for _, star in ipairs(Stars) do
            if star.configValue.id == configValue then
                return star
            end
        end
        return nil
    end
    local function SetTextTab1()
        ClearTextTab1()

        --Read DND tracker for active star
        local infoActive = var.VarPlayer.DNDTRACKER_SHOOTING_STAR_ACTIVE
        if(infoActive.value == 1) then 
        tab1Text1.content = ("Is star active? Yes")
        else
        tab1Text1.content = ("Is star active? No")
        end

        local coordGrid = nil
        --Read local area and report nearby star
        local allLocs = LocList.ByName("*crashed star*")
        for _,locEntity in ipairs(allLocs) do
            local configEntity = LookUpId(locEntity.configID)
            if(configEntity ~= nil) then
                if(Functions.CheckLimit(Player.GetEntity().coordGrid, locEntity.coordGrid)) then
                    tab1Text2.content = "No star found nearby"
                    break
                end
                tab1Text2.content = "Current size: "..configEntity.name
                coordGrid = locEntity.coordGrid
            end
        end

        --Read local area and report nearby star sprite
        local allNpcs = NPCList.ByName("*star sprite*")
        for _,locEntity in ipairs(allNpcs) do
            local configEntity = LookUpId(locEntity.configID)
            if(configEntity ~= nil) then
                if(Functions.CheckLimit(Player.GetEntity().coordGrid, locEntity.coordGrid)) then
                    tab1Text2.content = "No star found nearby"
                    break
                end
                tab1Text2.content = "Current size: "..configEntity.name
                coordGrid = locEntity.coordGrid
            end
        end
        
        --No star found
        if(coordGrid == nil) then
            tab1Text2.content = "No star found nearby"
        else
            tab1Text3.content = "You are "..Functions.CheckDirection(Player.GetEntity().coordGrid, coordGrid).." of the star"
        end
        tab1Text4.content = "Next star in: "..var.VarPlayer.DNDTRACKER_SHOOTING_STAR_TIME.value.." minutes"
        if(var.VarPlayer.DNDTRACKER_SHOOTING_STAR_TIME.value < 25) then
            tab1Text4.content = tab1Text4.content.."*"
            tab1Text5.content = "*Note: The star may be part of the new wave,<br> tracker may be displaying time until end of wave"
        end

        return coordGrid
    end
    local function StarInfoClick(button, active)
        if(not S.subscribed) then
            S.subscribed = true
            button:SetText("Stop searching for stars")
            Event.ServerLogic.Subscribe("StarLocatorEvent", function()
                local coordGrid = SetTextTab1()
                if(coordGrid == nil) then
                    Functions.ClearShape(shapeListTab1)
                    return
                else
                    shapeListTab1 = Functions.CreateBox(coordGrid, colorGreenA, colorGreen, shapeListTab1, "tab1")
                end
            end)
        else
            S.subscribed = false
            ClearTextTab1()
            Functions.ClearShape(shapeListTab1)
            button:SetText("Start searching for stars")
            Event.ServerLogic.Unsubscribe("StarLocatorEvent")
        end
    end

    --#region Controls
    local starInfoButton = tab1:AddFancyButton("Start searching for stars", StarInfoClick, { variant = "positive" })

    --Star active
    tab1Text1 = tab1:AddText({ text = "" })
    --Star size
    tab1Text2 = tab1:AddText({ text = "" })
    --Star direction
    tab1Text3 = tab1:AddText({ text = "" })
    --Time to next star
    tab1Text4 = tab1:AddText({ text = "" })
    --Warning message for next star time
    tab1Text5 = tab1:AddText({
        text = "",
        font = id.Font.MUSEO_SANS_15PT_BOLD,
        marginTop = 5
    })
    --#endregion
end

return S