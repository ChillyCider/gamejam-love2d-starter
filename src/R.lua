-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---Holder for resource loaders
local proxies = {}

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
proxies.images = Proxy(function(k)
    if love.filesystem.getInfo("assets/images/" .. k .. ".png") then
        return love.graphics.newImage("assets/images/" .. k .. ".png")
    end

    return love.graphics.newImage("assets/images/" .. k .. ".jpg")
end)

---@type table<string, support.AsepriteSheet>
proxies.sheets = Proxy(function(k)
    return support.AsepriteSheet(R.images[k], support.json.load("assets/images/" .. k .. ".json"))
end)

---@type table<string, love.Font>
proxies.fonts = Proxy(function(k)
    if love.filesystem.getInfo("assets/fonts/" .. k .. ".fnt") then
        return love.graphics.newFont("assets/fonts/" .. k .. ".fnt")
    end
    return love.graphics.newFont("assets/fonts/" .. k .. ".ttf")
end)

---@type table<string, love.SoundData>
proxies.sounds = Proxy(function(k)
    return love.sound.newSoundData("assets/sounds/" .. k .. ".wav")
end)

---@type table<string, string>
proxies.music = Proxy(function(k)
    return "assets/music/" .. k .. ".ogg"
end)

return proxies
