local Locations = require("locations")
local Lookup = require("lookupinfo")
local Starinfo = require("starinfo")
local Scopeinfo = require("scopeinfo")

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
Starinfo.Setup(tabList:GetPage(1))
Scopeinfo.Setup(tabList:GetPage(2))
Lookup.Setup(tabList:GetPage(3))
--#endregion

MainWindow:RefreshRowBackgrounds()

function PluginShutdown()
    if(Starinfo.subscribed) then
        Event.ServerLogic.Unsubscribe("StarLocatorEvent")
    end
    if(Lookup.subscribed) then
        Event.ServerLogic.Unsubscribe("LocationLocatorEvent")
    end
    MainWindow:Destroy()
end