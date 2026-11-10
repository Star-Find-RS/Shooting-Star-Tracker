local otherSizes = {"average", "very big", "fairly big", "big", "very small", "fairly small", "small"}
local regions = 
{
    {
        name = "amber",
        regionId = 0
    },
    {
        name = "anach",
        regionId = 1
    },
    {
        name = "asgar",
        regionId = 2
    },
    {
        name = "ashd",
        regionId = 3
    },
    {
        name = "cran",
        regionId = 4
    },
    {
        name = "daemo",
        regionId = 5
    },
    {
        name = "feldip",
        regionId = 6
    },
    {
        name = "freme",
        regionId = 7
    },
    {
        name = "kand",
        regionId = 8
    },
    {
        name = "dese",
        regionId = 9
    },
    {
        name = "grove",
        regionId = 10
    },
    {
        name = "mena",
        regionId = 11
    },
    {
        name = "misth",
        regionId = 12
    },
    {
        name = "mory",
        regionId = 13
    },
    {
        name = "pisca",
        regionId = 14
    },
    {
        name = "wendle",
        regionId = 15
    },
    {
        name = "wilder",
        regionId = 16
    }
}
local Locations = require("resources/Locations")
local S = {}
S.Setup = function(tab2)
    local tab2Text1, tab2Text2, tab2Text3, tab2Text4
    --local tab2Text
    local function ClearTextTab2()
        tab2Text1.content = ""
        tab2Text2.content = ""
        tab2Text3.content = ""
        tab2Text4.content = ""
    end
    local function ScopeInfoClick(button, active)
        ClearTextTab2()
        local inter = ui.Interfaces:GetInterface(id.Interface.MESBOX_V2)
        if(inter == nil) then
            tab2Text1.content = "No scope detected"
            return
        end

        --Reads DND tracker for next star time
        local info = var.VarPlayer.DNDTRACKER_SHOOTING_STAR_TIME
        tab2Text1.content = "Time : "..info.value.." minutes"

        local friendListTitle = ui.Interfaces:GetComponent(id.Component.FRIENDS2__FRIENDS_TITLE)
        local friendListTitleText = friendListTitle.content
        local world = string.sub(friendListTitleText, 27)

        --Read telescope (GENERIC WINDOW - BE AWARE IF USING WITH OTHER PLUGINS AND CONTENT)
        
        if(inter ~= nil) then
            local nameLabelID = id.Component.MESBOX_V2__MESBOX_TEXT
            if(ui.Interfaces:GetComponent(nameLabelID) ~= nil) then
                local scopeText = (ui.Interfaces:GetComponent(nameLabelID).content)
                if(string.find(scopeText, "You see a shooting star!")) then
                    tab2Text2.content = "World: "..world
                    scopeText = string.gsub(scopeText, "<br>", " ")
                    local indexFirst = string.find(scopeText, " The")
                    local indexSecond = string.find(string.sub(scopeText, indexFirst + 1), " The")
                    if(indexSecond ~= nil) then

                        --Get region reading
                        local textRegion = string.sub(scopeText, indexFirst + 1, indexFirst + 1 + indexSecond - 1)
                        for index, value in ipairs(regions) do
                            if(string.find(string.lower(textRegion), value.name)) then
                                for index, location in ipairs(Locations) do
                                    if(location.id == value.regionId) then
                                        textRegion = location.name
                                        break
                                    end
                                end
                                break
                            end
                        end
                        tab2Text3.content = "Region: " .. textRegion

                        --Get size reading
                        local textSize = string.sub(string.sub(scopeText, indexFirst + 1 + indexSecond), 1, indexSecond - 1)
                        local actualSize = ""
                        for index, value in ipairs(otherSizes) do
                            if(string.find(textSize, value)) then
                                actualSize = value
                                break
                            end
                        end
                        if(actualSize == "") then
                            --The star looks to be size ...
                            actualSize = string.gsub(textSize, "The star looks to be size ", "")
                            actualSize = string.gsub(actualSize, "%.", "")
                        end
                        tab2Text4.content = "Size: " .. actualSize
                    end
                end
            end
        end
    end
    local function ClearScopeInfoClick(button, active)
        ClearTextTab2()
    end
    --#region Controls
    tab2:AddFancyButton("Push for scope reading", ScopeInfoClick, { variant = "positive" })
    tab2:AddSimpleButton("Clear", ClearScopeInfoClick, {inline = true})
    tab2Text1 = tab2:AddText({
        text = "",
    })
    tab2Text2 = tab2:AddText({
        text = "",
    })
    tab2Text3 = tab2:AddText({
        text = ""
    })
    tab2Text4 = tab2:AddText({
        text = ""
    })
    --#endregion
end
return S