local Locations = require("locations")
local Stars = require("star sizes")

--#region Don't ask, only way for me to get all the files loaded
local game_window = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
local myGroupBox = ui.GroupBox.new(game_window)
myGroupBox.stylesheetID = id.StyleSheet.DEFAULT
myGroupBox:SetHeaderLayout(0,0,0,0,0)
myGroupBox:SetSize(256,200)
myGroupBox:SetPos(0,0,0.6,0.4)

local sprite = ui.Sprite.new(myGroupBox)
sprite:SetSize(256,200)
sprite.sprite = Plugin.resources.empty

for _, abbrev in ipairs(Locations) do
    if(abbrev.map == nil) then
        print("Missing map for abbrev: "..abbrev.name)
    else
        sprite.sprite = abbrev.map
    end
end
myGroupBox:DeleteAll()
myGroupBox:Destroy()
--#endregion

--#region Start of main application
local parent = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__GAME_AREA)
local MainWindow = prettyui.Window.new(parent, { title = "Shooting Star Tracker", x = 0, y = 350, width = 425, height = 450, scrollable = false, rowBackgroundColours = { 0x24211EFF, 0x2E2825FF } })
local tabList
local function OnTabChange(tabs, index, value, page)
    if(index == 3) then
        MainWindow:SetSize(425, 600)
    else
        MainWindow:SetSize(425, 450)
    end
end
tabList = MainWindow:AddTabs({{text = "Star Info"}, {text = "Scope Info"}, {text = "Lookup"}}, { height = 525, width = 375, onChange = OnTabChange })
local tab1 = tabList:GetPage(1)
local tab2 = tabList:GetPage(2)
local tab3 = tabList:GetPage(3)

--Tab 1
local tab1Text1, tab1Text2, tab1Text3, tab1Text4, tab1Text5
--Tab 2
local tab2Text1, tab2Text2, tab2Text3, tab2Text4
local tab2Text = tab2:AddText({
    text = "",
    height = 125,
    y = 50,
})
--Tab 3
local tab3Text1, tab3Text2, tab3Text3, tab3Text4, tab3Text5, tab3Sprite1
--#endregion

--#region Variables
local shapeListTab1
local shapeListTab3
local colorBlueA = 0x0000FF27
local colorBlue = 0x0000FFAA
local colorGreenA = 0x00FF0027
local colorGreen = 0x00FF00AA
local subscribedTab1 = false
local subscribedTab3 = false

--#endregion

--#region Functions
local function CheckDirection(coordFirst, coordSecond)
    if(coordFirst.x < coordSecond.x) then
        if(coordFirst.z < coordSecond.z) then
            return "southwest"
        elseif(coordFirst.z > coordSecond.z) then
            return "northwest"
        else
            return "west"
        end
    elseif(coordFirst.x > coordSecond.x) then
        if(coordFirst.z < coordSecond.z) then
            return "southeast"
        elseif(coordFirst.z > coordSecond.z) then
            return "northeast"
        else
            return "east"
        end
    else
        if(coordFirst.z < coordSecond.z) then
            return "south"
        elseif(coordFirst.z > coordSecond.z) then
            return "north"
        end
    end
    return "same position"
end

--Range is limited per Mod Jewel
local range = 32
local function CheckLimit(coordGrid1, coordGrid2)
    if(coordGrid1 == nil or coordGrid2 == nil) then
        return true
    end
    if(coordGrid1.x < coordGrid2.x - range
    or coordGrid1.x > coordGrid2.x + range
    or coordGrid1.z < coordGrid2.z - range
    or coordGrid1.z > coordGrid2.z + range) then
        return true
    end
    return false
end
local function ClearShapeTab1()
    if(shapeListTab1 ~= nil) then
        shapeListTab1:Destroy()
        shapeListTab1 = nil
    end
end
local function ClearShapeTab3()
    if(shapeListTab3 ~= nil) then
        shapeListTab3:Destroy()
        shapeListTab3 = nil
    end
end
local function CreateBox(coordGrid, colorAlpha, colorEdge, shapeToClear)
    -- A basic tile shape
    local tileShape = ShapeData.new()
    -- 2x2 box
    tileShape.positions = 
    { 
    Vector3.new(-256, 1000, -256), Vector3.new(768, 1000, -256), Vector3.new(768, 1000, 768), Vector3.new(-256, 1000, 768),
    Vector3.new(-256, 0, -256), Vector3.new(768, 0, -256), Vector3.new(768, 0, 768), Vector3.new(-256, 0, 768),
    Vector3.new(-256, 1000, -256), Vector3.new(768, 1000, -256), Vector3.new(768, 1000, 768), Vector3.new(-256, 1000, 768),
    Vector3.new(-256, 0, -256), Vector3.new(768, 0, -256), Vector3.new(768, 0, 768), Vector3.new(-256, 0, 768),}
    tileShape.lines = 
    { 
    -- Edges for fill
    0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 4, 1, 5, 2, 6, 3, 7,
    -- Thicker edges
    8, 9, 9, 10, 10, 11, 11, 8, 12, 13, 13, 14, 14, 15, 15, 12, 8, 12, 9, 13, 10, 14, 11, 15
    }
    
    -- Triangles to fill in shape
    tileShape.tris = { 0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7, 0, 4, 5, 0, 5, 1, 1, 5, 6, 1, 6, 2, 2, 6, 7, 2, 7, 3, 3, 7, 4, 3, 4, 0}
        
    tileShape.rgba = { 
    -- Color for fill
    colorAlpha, colorAlpha, colorAlpha, colorAlpha, 
    colorAlpha, colorAlpha, colorAlpha, colorAlpha,
    -- Color for edges
    colorEdge, colorEdge, colorEdge, colorEdge, 
    colorEdge, colorEdge, colorEdge, colorEdge,  }
    

    -- Choose a tile and convert to a position
    local instancePos = coordGrid:ToCoordFine(true).position

    -- Get the ground height at that position
    local groundHeight = World.GetGroundHeight(coordGrid.level, instancePos.x, instancePos.z)
    -- Create start and end heights for the bounce
    local startHeight = groundHeight

    -- Set the instance height
    instancePos.y = startHeight

    if(shapeToClear == "tab1") then
        ClearShapeTab1()
    end
    if(shapeToClear == "tab3") then
        ClearShapeTab3()
    end

    -- Create the named shape instance
    local instance = ShapeList.CreateInstance("myInstance"..shapeToClear)
    instance:SetShapeData(tileShape)
    instance.translation = instancePos
    instance.ignoreDepth = true

    -- Add to shape list so we can keep track and remove when no longer required
    if(shapeToClear == "tab1") then
        shapeListTab1 = instance
    elseif(shapeToClear == "tab3") then
        shapeListTab3 = instance
    end
end
--#endregion


--#region Star Information
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
            if(CheckLimit(Player.GetEntity().coordGrid, locEntity.coordGrid)) then
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
            if(CheckLimit(Player.GetEntity().coordGrid, locEntity.coordGrid)) then
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
        tab1Text3.content = "You are "..CheckDirection(Player.GetEntity().coordGrid, coordGrid).." of the star"
    end
    tab1Text4.content = "Next star in: "..var.VarPlayer.DNDTRACKER_SHOOTING_STAR_TIME.value.." minutes"
    if(var.VarPlayer.DNDTRACKER_SHOOTING_STAR_TIME.value < 25) then
        tab1Text4.content = tab1Text4.content.."*"
        tab1Text5.content = "*Note: The star may be part of the new wave,<br> tracker may be displaying time until end of wave"
    end

    return coordGrid
end
local function StarInfoClick(button, active)
    if(not subscribedTab1) then
        subscribedTab1 = true
        button:SetText("Stop searching for stars")
        Event.ServerLogic.Subscribe("StarLocatorEvent", function()
            local coordGrid = SetTextTab1()
            if(coordGrid == nil) then
                ClearShapeTab1()
                return
            else
                CreateBox(coordGrid, colorGreenA, colorGreen, "tab1")
            end
        end)
    else
        subscribedTab1 = false
        ClearTextTab1()
        ClearShapeTab1()
        button:SetText("Start searching for stars")
        Event.ServerLogic.Unsubscribe("StarLocatorEvent")
    end
end
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

--#region Scope Information
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
tab2:AddFancyButton("Push for scope reading", ScopeInfoClick, { variant = "positive" })
local function ClearScopeInfoClick(button, active)
    tab2Text.content = ""
end
tab2:AddSimpleButton("Clear", ClearScopeInfoClick, {inline = true})
--#endregion

--#region Look up Information

local coordGrid = nil

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
   ClearShapeTab3()
    if(not subscribedTab3) then
        if(coordGrid == nil) then
            return
        end
        subscribedTab3 = true
        button:SetText("Stop travel")
        Event.ServerLogic.Subscribe("LocationLocatorEvent", function()
            if(coordGrid == nil) then
                ClearShapeTab3()
                return
            else
                local playerCoordGrid = Player.GetEntity().coordGrid
                tab3Text5.content = "You are "..CheckDirection(playerCoordGrid, coordGrid).." of the location"
                CreateBox(coordGrid, colorBlueA, colorBlue, "tab3")
            end
        end)
    else
        subscribedTab3 = false
        button:SetText("Go to")
        ClearShapeTab3()
        tab3Text5.content = ""
        Event.ServerLogic.Unsubscribe("LocationLocatorEvent")
    end

end
tab3:AddFancyButton("Go to", GoToLocation, {inline = true, width = 75})

--Name of location
tab3Text1 = tab3:AddText({ text = "" })
--Region if applicable
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

MainWindow:RefreshRowBackgrounds()

function PluginShutdown()
    if(subscribedTab1) then
        Event.ServerLogic.Unsubscribe("StarLocatorEvent")
    end
    if(subscribedTab3) then
        Event.ServerLogic.Unsubscribe("LocationLocatorEvent")
    end
    MainWindow:Destroy()
end