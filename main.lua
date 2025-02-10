local GS = require "hump.gamestate"
local Timer = require "hump.timer"
local AsepriteSheet = require "support.aseprite_sheet"

-- based on vrld's proxy
local function Proxy(loadFunc)
    return setmetatable({}, {__index=function(t, key)
        local v = loadFunc(key)
        rawset(t, key, v)
        return v
    end})
end

---@type table<string, love.Image>
_G.images = Proxy(function(k)
    if love.filesystem.getInfo("assets/images/" .. k .. ".png") then
        return love.graphics.newImage("assets/images/" .. k .. ".png")
    end

    return love.graphics.newImage("assets/images/" .. k .. ".jpg")
end)
---@type table<string, AsepriteSheet>
_G.sheets = Proxy(function(k)
    return AsepriteSheet(_G.images[k], "assets/images/" .. k .. ".json")
end)
---@type table<string, love.Font>
_G.fonts = Proxy(function(k)
    if love.filesystem.getInfo("assets/fonts/" .. k .. ".fnt") then
        return love.graphics.newFont("assets/fonts/" .. k .. ".fnt")
    end
    return love.graphics.newFont("assets/fonts/" .. k .. ".ttf")
end)
---@type table<string, love.SoundData>
_G.sounds = Proxy(function(k)
    return love.sound.newSoundData("assets/sounds/" .. k .. ".wav")
end)
---@type table<string, string>
_G.music = Proxy(function(k)
    return "assets/music/" .. k .. ".ogg"
end)
---@type table<string, table>
_G.states = Proxy(function(k)
    return assert(love.filesystem.load("states/" .. k .. ".lua"))()
end)

function love.load()
    GS.registerEvents()

    -- Switch to the first state
    local firstState, err = love.filesystem.read("states/first_state.txt")
    if type(err) == "string" then
        error(err)
    end
    firstState = firstState:gsub("^%s*([^%s]+)%s*$", "%1")
    GS.switch(_G.states[firstState])
end

function love.update(dt)
    Timer.update(dt)
end

function love.draw()
end
