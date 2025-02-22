-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local AsepriteSheet = require "support.aseprite_sheet"
local json = require "support.json"

---Holder for resource loaders
local R = {}

local function Proxy(loadFunc)
    -- based on vrld's proxy
    return setmetatable({}, {__index=function(t, key)
        local v = loadFunc(key)
        rawset(t, key, v)
        return v
    end})
end

---Loader for images.
---
---@type table<string, love.Image>
R.images = Proxy(function(k)
    if love.filesystem.getInfo("assets/images/" .. k .. ".png") then
        return love.graphics.newImage("assets/images/" .. k .. ".png")
    end

    return love.graphics.newImage("assets/images/" .. k .. ".jpg")
end)

---@type table<string, AsepriteSheet>
R.sheets = Proxy(function(k)
    return AsepriteSheet(_G.images[k], json.load("assets/images/" .. k .. ".json"))
end)

---@type table<string, love.Font>
R.fonts = Proxy(function(k)
    if love.filesystem.getInfo("assets/fonts/" .. k .. ".fnt") then
        return love.graphics.newFont("assets/fonts/" .. k .. ".fnt")
    end
    return love.graphics.newFont("assets/fonts/" .. k .. ".ttf")
end)

---@type table<string, love.SoundData>
R.sounds = Proxy(function(k)
    return love.sound.newSoundData("assets/sounds/" .. k .. ".wav")
end)

---@type table<string, string>
R.music = Proxy(function(k)
    return "assets/music/" .. k .. ".ogg"
end)

---@type table<string, table>
R.states = Proxy(function(k)
    return assert(love.filesystem.load("states/" .. k .. ".lua"))()
end)

return R
