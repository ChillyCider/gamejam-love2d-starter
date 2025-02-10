-- Parse network format into a lua table

local HEX = {
    ["0"]=0,
    ["1"]=1,
    ["2"]=2,
    ["3"]=3,
    ["4"]=4,
    ["5"]=5,
    ["6"]=6,
    ["7"]=7,
    ["8"]=8,
    ["9"]=9,
    ["a"]=10,
    ["b"]=11,
    ["c"]=12,
    ["d"]=13,
    ["e"]=14,
    ["f"]=15
}

---@param s string
---@param len number
---@param pos number
local function parseStringLiteral(s, len, pos)
    local originalPos = pos
    pos = pos + 1
    
    local result = ""
    
    local escape = false
    local finished = false
    while not finished and pos <= len do
        local c = s:sub(pos, pos)
        if escape then
            if c == '"' then
                result = result .. '"'
            elseif c == '\\' then
                result = result .. '\\'
            elseif c == '/' then
                result = result .. '/'
            elseif c == 'b' then
                result = result .. '\b'
            elseif c == 'f' then
                result = result .. '\f'
            elseif c == 'n' then
                result = result .. '\n'
            elseif c == 'r' then
                result = result .. '\r'
            elseif c == 't' then
                result = result .. '\t'
            elseif c == 'u' then
                -- unicode code point
                if pos + 4 > len then
                    error("Incomplete hex glyph in JSON string")
                end
                
                local p1 = HEX[s:sub(pos + 1, pos + 1):lower()]
                local p2 = HEX[s:sub(pos + 2, pos + 2):lower()]
                local p3 = HEX[s:sub(pos + 3, pos + 3):lower()]
                local p4 = HEX[s:sub(pos + 4, pos + 4):lower()]
                
                if p1 == nil or p2 == nil or p3 == nil or p4 == nil then
                    error("Invalid hexadecimal number in JSON string")
                end
                
                result = result .. utf8.char(4096*p1 + 256*p2 + 16*p3 + p4)
                
                pos = pos + 4
            end
            
            pos = pos + 1
            escape = false
        else
            if c == '"' then
                finished = true
            elseif c == '\\' then
                escape = true
            else
                result = result .. c
            end
            
            pos = pos + 1
        end
    end
    
    if not finished then
        error("Incomplete string literal in JSON")
    end
    
    return result, (pos - originalPos)
end

---@param s string
---@param len number
---@param pos number
local function parseNumberLiteral(s, len, pos)
    local originalPos = pos
    
    if s:sub(pos, pos) == '-' then
        pos = pos + 1
    end
    
    while pos <= len and string.find("0123456789", s:sub(pos, pos), 1, true) do
        pos = pos + 1
    end
    
    if pos <= len and s:sub(pos, pos) == "." then
        pos = pos + 1
        local fracPartFound = false
        while pos <= len and string.find("0123456789", s:sub(pos, pos), 1, true) do
            pos = pos + 1
            fracPartFound = true
        end
        
        if not fracPartFound then
            error("Number with decimal point but no fractional part in JSON")
        end
    end
    
    if pos <= len and s:sub(pos, pos):lower() == "e" then
        pos = pos + 1
    
        if pos <= len and s:sub(pos, pos) == '+' or s:sub(pos, pos) == '-' then
            pos = pos + 1
        end
        
        local expPartFound = false
        
        while pos <= len and string.find("0123456789", s:sub(pos, pos), 1, true) do 
            pos = pos + 1
            expPartFound = true
        end
        
        if not expPartFound then
            error("Number with 'e' but no following exponent in JSON")
        end
    end
    
    return tonumber(s:sub(originalPos, pos - 1)), pos - originalPos
end

---@alias TokenType "unset"|"eof"|"lbracket"|"lbrace"|"rbracket"|"rbrace"|"colon"|"comma"|"true"|"false"|"null"|"number"|"string"

---@class Tokenizer
---@field s string
---@field len number
---@field cursor number
---@field tokenType TokenType
---@field tokenPos number
---@field nextTokenType TokenType
---@field nextPosition number
local Tokenizer = {}
Tokenizer.__index = Tokenizer

---@param s string
---@return Tokenizer
function Tokenizer.new()
    local o = {}
    setmetatable(o, Tokenizer)
    return o
end

function Tokenizer:init(s)
    self.s = s
    self.len = string.len(s)
    self.cursor = 1
    self.tokenType = "unset"
    self.tokenPos = 0
    self.nextTokenType = "unset"
    self.nextPosition = 0
    self:advance()
    self:advance()
end

function Tokenizer:advance()
    self.tokenType = self.nextTokenType
    self.tokenPos = self.nextPosition

    local c = nil
    if self.cursor <= self.len then
        c = self.s:sub(self.cursor, self.cursor)
        
        while c == " " or c == "\n" or c == "\r" or c == "\t" do
            self.cursor = self.cursor + 1
            if self.cursor <= self.len then
                c = self.s:sub(self.cursor, self.cursor)
            else
                c = nil -- end of file was reached
            end
        end
    end
    
    if c == '"' then
        -- string
        local _, skip = parseStringLiteral(self.s, self.len, self.cursor)
        self.nextPosition = self.cursor
        self.nextTokenType = "string"
        self.cursor = self.cursor + skip
    elseif c == '[' then
        self.cursor = self.cursor + 1
        self.nextPosition = self.cursor
        self.nextTokenType = "lbracket"
    elseif c == '{' then
        self.cursor = self.cursor + 1
        self.nextPosition = self.cursor
        self.nextTokenType = "lbrace"
    elseif c == ']' then
        self.cursor = self.cursor + 1
        self.nextPosition = self.cursor
        self.nextTokenType = "rbracket"
    elseif c == '}' then
        self.cursor = self.cursor + 1
        self.nextPosition = self.cursor
        self.nextTokenType = "rbrace"
    elseif c == ':' then
        self.cursor = self.cursor + 1
        self.nextPosition = self.cursor
        self.nextTokenType = "colon"
    elseif c == ',' then
        self.cursor = self.cursor + 1
        self.nextPosition = self.cursor
        self.nextTokenType = "comma"
    elseif c == 'n' or c == 't' or c == 'f' then
        -- could be null, true, or false
        local origCursor = self.cursor
        
        self.cursor = self.cursor + 1
        while self.cursor <= self.len and string.find("nulfasetr", self.s:sub(self.cursor, self.cursor), 1, true) do
            self.cursor = self.cursor + 1
        end
        
        if self.s:sub(origCursor, self.cursor - 1) == "null" then
            self.nextPosition = origCursor
            self.nextTokenType = "null"
        elseif self.s:sub(origCursor, self.cursor - 1) == "true" then
            self.nextPosition = origCursor
            self.nextTokenType = "true"
        elseif self.s:sub(origCursor, self.cursor - 1) == "false" then
            self.nextPosition = origCursor
            self.nextTokenType = "false"
        else
            error("Unrecognized token in JSON")
        end
    elseif c == nil then
        self.nextPosition = self.cursor
        self.nextTokenType = "eof"
    elseif string.find("-0123456789", c, 1, true) then
        -- number
        local _, skip = parseNumberLiteral(self.s, self.len, self.cursor)
        self.nextPosition = self.cursor
        self.nextTokenType = "number"
        self.cursor = self.cursor + skip
    else
        error(string.format("Encountered unknown token type '%s' in JSON at ", c, self.nextPosition))
    end
end

local parseValue

---@param t Tokenizer
local function parseArray(t)
    t:advance()
    local items = {}
    
    while t.tokenType ~= "rbracket" and t.tokenType ~= "eof" do
        local value = parseValue(t)
        if t.tokenType == "comma" then
            t:advance()
        elseif t.tokenType ~= "rbracket" then
            error("Unexpected " .. t.tokenType .. " token in array in JSON")
        end
        
        table.insert(items, value)
    end
    
    if t.tokenType == "rbracket" then
        t:advance()
    elseif t.tokenType == "eof" then
        error("Incomplete array in JSON")
    end
    
    return items
end

---@param t Tokenizer
local function parseObject(t)
    t:advance()
    
    local obj = {}
    
    while t.tokenType ~= "rbrace" and t.tokenType ~= "eof" do
        if t.tokenType ~= "string" then
            error("Key must be string in JSON object")
        end
        
        local key = parseStringLiteral(t.s, t.len, t.tokenPos)
        
        t:advance()
        
        if t.tokenType ~= "colon" then
            error("Colon expected in JSON object")
        end
        
        t:advance()
        
        local value = parseValue(t)
        
        if t.tokenType == "comma" then
            t:advance()
        elseif t.tokenType ~= "rbrace" then
            error("Unexpected " .. t.tokentype .. " token in JSON object")
        end
        
        obj[key] = value
    end
    
    if t.tokenType == "rbrace" then
        t:advance()
    elseif t.tokenType == "eof" then
        error("Incomplete object in JSON")
    end
    
    return obj
end

---@param t Tokenizer
parseValue = function(t)
    if t.tokenType == "lbracket" then
        return parseArray(t)
    elseif t.tokenType == "lbrace" then
        return parseObject(t)
    elseif t.tokenType == "string" then
        local str, _ = parseStringLiteral(t.s, t.len, t.tokenPos)
        t:advance()
        return str
    elseif t.tokenType == "number" then
        local num, _ = parseNumberLiteral(t.s, t.len, t.tokenPos)
        t:advance()
        return num
    elseif t.tokenType == "true" then
        t:advance()
        return true
    elseif t.tokenType == "false" then
        t:advance()
        return false
    elseif t.tokenType == "null" then
        t:advance()
        return nil
    end
    
    error(t.tokenType .. " is not a valid value token for JSON")
end

---@param s string
---@return any
local function fromString(s)
    --- Tokenize the string
    local t = Tokenizer.new()
    t:init(s)
    return parseValue(t)
end

return {
    fromString=fromString
}
