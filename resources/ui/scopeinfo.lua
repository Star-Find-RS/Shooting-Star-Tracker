
local Locations = require("resources/Locations")
local Scope = require("resources/scope")
local S = {}
S.Setup = function(tab2)
    local tab2Text1, tab2Text2, tab2Text3, tab2Text4, tab2TextBox1
    --local tab2Text
    local function ClearTextTab2()
        tab2Text1.content = ""
        tab2Text2.content = ""
        tab2Text3.content = ""
        tab2Text4.content = ""
        tab2TextBox1:SetText("")
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
                        for index, value in ipairs(Scope.regions) do
                            if(string.find(string.lower(textRegion), string.lower(value.name))) then
                                textRegion = value.regionCall
                                break
                            end
                        end
                        tab2Text3.content = "Region: " .. textRegion

                        --Get size reading
                        local textSize = string.sub(string.sub(scopeText, indexFirst + 1 + indexSecond), 1, indexSecond - 1)
                        local actualSize = ""
                        for index, value in ipairs(Scope.otherSizes) do
                            if(string.find(string.lower(textSize), string.lower(value))) then
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

                        --/call world:205 region:Crandor/Karamja size:4 relative-time:58
                        tab2TextBox1:SetText("/call world:"..world.." region:"..textRegion.." size:"..actualSize.." relative-time:"..info.value)
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
    tab2TextBox1 = tab2:AddTextField({ placeholder = "Scope info" })
    --#endregion
end
return S