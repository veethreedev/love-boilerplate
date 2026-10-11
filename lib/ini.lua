--------------------------------------------------------------------------
-- ini.lua: ini parser for lua
--------------------------------------------------------------------------
-------------------- CLASS MODULE ----------------------------------------
local classMetatable = {
    __index = function(self, key) return self.__baseClass[key] end,
    __call = function(self, ...) return self:new(...) end
}
local Class = setmetatable( { __baseClass = {}, __type = "class"}, classMetatable)

function Class:new(...)
    local prototype = setmetatable({__baseClass = self}, getmetatable(self))
    local arguments = {...}
    if type(arguments[1]) == "function" then
        prototype.init = arguments[1]
    end
    if prototype.init then prototype:init(...)end
    return prototype
end

function Class.extend(parent, ...)
    local prototype = setmetatable({__baseClass = parent, __super = parent}, getmetatable(parent))
    return prototype
end

---------------------------------------------------------------------------

local ini = Class()
local fs  = love.filesystem
local f   = string.format

--------------------- UTILITY ----------------------


-- Converts boolean to string
local function booleanToString(bool)
    if bool then return "true" else return "false" end
end

-- Convers boolean string to boolean type
local function stringToBoolean(str)
    if str == "true"  then return true end
    if str == "false" then return false end
end

-- Returns true if str is a "true" or "false"
local function isBoolean(str)
    return str == "true" or str == "false"
end

-- Casts value to appropriate type
local function castType(value)
    if isBoolean(value) then return stringToBoolean(value) end
    if tostring(value)  then return tostring(value) end
    if tonumber(value)  then return tonumber(value) end
end

-- Returns true if line matches the pattern of a comment
local function isComment(line)
    return line:match("^;") and true or false
end

-- Returns true if line matches the pattern of a section header
local function isSectionHeader(line)
    return line:match("%[.+%]") and true or false
end

-- Returns true if line matches the pattern of a key value pair
local function isKeyValuePair(line)
    return line:match(".+=.+") and true or false
end

-- Returns true if line matches any valid pattern.
local function isValidLine(line)
    return isComment(line) or isSectionHeader(line) or isKeyValuePair(line) or #line > 0
end

-- Removes trailing and leading whitespace
local function strip(line)
    return line:gsub("^[%s]+", ""):gsub("[%s]+$", "")
end

-- Splits a key value pair into it's components
local function splitKeyValuePair(line)
    if not isKeyValuePair(line) then return end

    local segments = {}
    for segment in line:gmatch("([^=.+]+)") do 
        segments[#segments + 1] = strip(segment) 
    end
    
    return segments[1], segments[2]
end

-- Removes brackets from section header string
local function getSectionHeaderName(str)
    return str:gsub("[%[%]]", "")
end

-- Checks if file exists, Returns false and an error message if it does not
local function checkFile(filename)
    if not filename then return false, "No filename provided" end
    if not fs.getInfo(filename) then return false, f("The file '%s' doesn't exists!", filename) end
    return true
end

-- Updates the rawData table with values from the data table
function ini:updateRawData()
    for line, data in ipairs(self.rawData) do
        if data.key then
            if data.section then
                data.value = self.data[data.section][data.key]
            else
                data.value = self.data[data.key]
            end
        end
    end
end

------------------ USER FUNCTUONS ------------------

-- Initializes ini object
function ini:init()
    self.filename     = false
    self.data         = {}
    self.rawData      = {}
    self.lastSection  = false
end

-- Adds section to the ini
function ini:section(section)
    self.lastSection = section
    if not self.data[section] then self.data[section] = {} end
    return self
end

-- Adds value to the ini
function ini:property(key, value, section)
    section = section or self.lastSection
    -- if type(value) == "boolean" then value = booleanToString(value) end
    self.rawData[#self.rawData + 1] = {
        section = section,
        key = key,
        value = value
    }
    
    if section then
        self.data[section][key] = value
    else
        self.data[key] = value
    end
    return self
end

-- Adds comment to the ini
function ini:comment(comment)
    self.rawData[#self.rawData + 1] = {
        section = false,
        key = false,
        value = false,
        comment = "; " .. comment
    }
    return self
end

function ini:loadTable(tab)
    for section, keys in pairs(tab) do
        self:section(section)
        for key, value in pairs(keys) do
            self:property(key, value)
        end
    end
    return self
end

-- Reads data from .ini file
-- Return value: False if file doesn't exist.
function ini:load(filename)
    local exists, err = checkFile(filename)
    if not exists then return exists, err else self.filename = filename end

    self.rawData = {}
    self.data    = {}

    local currentSection = false
    for line in fs.lines(filename) do
        if isValidLine(line) then
            -- Comment
            if isComment(line) or #line < 1 then
                self.rawData[#self.rawData + 1] = {
                    section = false, key = false, value = false, comment = line
                }
            else
                -- Section
                if isSectionHeader(line) then
                    currentSection = getSectionHeaderName(line)
                    if not self.data[currentSection] then self.data[currentSection] = {} end
                end

                -- Key Value Pair
                if isKeyValuePair(line) then
                    local key, value = splitKeyValuePair(line) 

                    -- Raw data
                    self.rawData[#self.rawData + 1] = {
                        section = currentSection,
                        key     = key,
                        value   = castType(value)
                    }

                    -- Data
                    if currentSection then
                        self.data[currentSection][key] = castType(value)
                    else
                        self.data[key] = castType(value)
                    end
                end
            end 
        else
            if #line < 1 then
                self.rawData[#self.rawData + 1] = {section = false, key = false, value = false, comment = line}
            end
        end
    end

    return self
end

function ini:save(filename)
    filename = filename or self.filename

    -- Updating the values of rawData with ones found in data in case the user changed them
    self:updateRawData()

    local currentSection = false
    local lines          = {}
    local maxKeyLength   = 0

    -- Finding longest key for equals sign alignment reasons
    for line, data in ipairs(self.rawData) do if not data.comment then if #data.key > maxKeyLength then maxKeyLength = #data.key end end end

    for line, data in ipairs(self.rawData) do
        -- Comment
        if data.comment then
            lines[#lines + 1] = data.comment
            lines[#lines + 1] = "\n"
        else
            -- Section Header
            if data.section ~= currentSection then
                if line > 1 then lines[#lines + 1] = "\n" end
                currentSection = data.section
                lines[#lines + 1] = "["
                lines[#lines + 1] = currentSection
                lines[#lines + 1] = "]\n"
            end

            -- Key value pair
            local eqalsSignOffset = maxKeyLength - #data.key + 1
            lines[#lines + 1] = data.key
            for i=1, eqalsSignOffset do lines[#lines + 1] = " " end
			local value = data.value

			if type( value ) == "boolean" then value = booleanToString( value ) end
            lines[#lines + 1] = "= "
            lines[#lines + 1] = value
            lines[#lines + 1] = "\n"
        end
    end

    fs.write(filename, table.concat(lines))

    return self
end

function ini:getTable()
    return self.data
end

return ini
