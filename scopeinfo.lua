local S = {}
S.Setup = function(tab2)
    local tab2Text1, tab2Text2, tab2Text3, tab2Text4
    local tab2Text
    local function ScopeInfoClick(button, active)
        tab2Text.content = ""
        local inter = ui.Interfaces:GetInterface(id.Interface.MESBOX_V2)
        if(inter == nil) then
            tab2Text.content = "No scope detected"
            return
        end

        --Reads DND tracker for next star time
        local info = var.VarPlayer.DNDTRACKER_SHOOTING_STAR_TIME
        tab2Text.content = tab2Text.content..("Time to next star: "..info.value.." minutes")

        local test = ui.Interfaces:GetComponent(id.Component.FRIENDS2__FRIENDS_TITLE)
        local stringTest = test.content
        local split = string.sub(stringTest, 27)

        --Read telescope (GENERIC WINDOW - BE AWARE IF USING WITH OTHER PLUGINS AND CONTENT)
        
        if(inter ~= nil) then
            local nameLabelID = id.Component.MESBOX_V2__MESBOX_TEXT
            if(ui.Interfaces:GetComponent(nameLabelID) ~= nil) then
                local starText = (ui.Interfaces:GetComponent(nameLabelID).content)
                if(string.find(starText, "You see a shooting star!")) then
                    tab2Text.content = tab2Text.content.."<br>Star call: World "..split.."<br>"..(starText)
                end
            end
        end
    end
    local function ClearScopeInfoClick(button, active)
        tab2Text.content = ""
    end
    --#region Controls
    tab2:AddFancyButton("Push for scope reading", ScopeInfoClick, { variant = "positive" })
    tab2:AddSimpleButton("Clear", ClearScopeInfoClick, {inline = true})
    tab2Text = tab2:AddText({
        text = "",
        height = 125,
        y = 50,
    })
    --#endregion
end
return S