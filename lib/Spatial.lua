local spatial = Class()

local floor  = math.floor
local insert = table.insert
local remove = table.remove

-- Filters for queries
spatial.filters = {
    allpass = function() return true end 
}

function spatial:init(cellSize)
    self.cells    = {} -- A three dimensional table
    self.cellSize = cellSize or 64
    self.length   = 0  -- How many items in hash
end

-- Adds 'item' to cell x, y in cell space
function spatial:addToCell(item, x, y)
    self.cells[y]    = self.cells[y]    or {}
    self.cells[y][x] = self.cells[y][x] or {}

    insert(self.cells[y][x], item)
    return self.cells[y][x]
end

-- Screen space coordinates to cell space
function spatial:toCellSpace(x, y)
    return floor( x / self.cellSize ), floor( y / self.cellSize )
end

-- Cell space coordinates to screen space
function spatial:toScreenSpace(x, y)
    return x * self.cellSize, y * self.cellSize
end

-- Insert item into the hash
function spatial:insert(item, x, y)
    local cellX, cellY = self:toCellSpace(x, y) 
    local cell = self:addToCell(item, cellX, cellY)
    item._SPATIAL = {
        spatial = self,
        cellX   = cellX,
        cellY   = cellY,
        cell    = cell     
    }
end

-- Remove item from the hash
function spatial:remove(item)
    remove(item._SPATIAL.spatial.cells[item._SPATIAL.cellY], item._SPATIAL.cellX)
end

-- Returns all items within a rectangle
-- 'filter' should be a function that returns true if the item should be included.
-- It reveives an item as an argument
function spatial:query(x, y, width, height, filter)
    width, height, filter = width or 1, height or 1, filter or self.filters.allpass
    local cells = {}

    local startX, startY = self:toCellSpace(x, y)
    local endX, endY     = self:toCellSpace(x + width, y + height)

    for y=startY, endY do
        if self.cells[y] then
            for x=startX, endX do
                if self.cells[y][x] then
                    for _, cell in ipairs(self.cells[y][x]) do
                        if filter(cell) then
                            if not Util.contains(cells, cell) then insert(cells, cell) end
                        end
                    end
                end
            end
        end
    end

    return cells, #cells
end

return spatial
