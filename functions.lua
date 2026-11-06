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