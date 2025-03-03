-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local json = require "support.json"
local aseprite_sheet = require "support.aseprite_sheet"

---Holder for resources
local R = {loaded=false}

function R.loadResources()
    ---------------------------------
    -- EXPLICITLY PRELOADED ASSETS --
    ---------------------------------
    -- Lazy loading behavior is implemented below these. In short,
    -- attempting to access a nil field will attempt to load it.

    ---@class R.images
    R.images = {
    }

    ---@class R.sheets
    R.sheets = {
    }

    ---@class R.fonts
    R.fonts = {
        -- example=love.graphics.newFont("assets/fonts/example.fnt"),
    }

    ---@class R.sounds
    R.sounds = {
        -- I recommend you put love.SoundData objects in here, so that multiple
        -- love.Source can use the same sound data.
        --
        -- example=love.sound.newSoundData("assets/sounds/explosion.wav"),
    }

    ---@class R.music
    R.music = {
        -- Probably just put musics' filenames in this table since music is streamed
    }

    ---------------------------
    -- LAZY LOADING HANDLERS --
    ---------------------------

    -- Handler for lazily loaded images
    setmetatable(R.images, {__index=function(t, k)
        local img = love.graphics.newImage("assets/images/" .. k .. ".png")
        rawset(t, k, img)
        return img
    end})

    -- Handler for lazily loaded sheets
    setmetatable(R.sheets, {__index=function(t, k)
        local sheet = aseprite_sheet(R.images[k], json.load("assets/images/" .. k .. ".json"))
        rawset(t, k, sheet)
        return sheet
    end})

    -- Handler for lazily loaded fonts
    setmetatable(R.fonts, {__index=function(t, k)
        local fnt = love.graphics.newFont("assets/fonts/" .. k .. ".fnt")
        rawset(t, k, fnt)
        return fnt
    end})

    -- Handler for lazily loaded sounds
    setmetatable(R.sounds, {__index=function(t, k)
        local wav = love.sound.newSoundData("assets/sounds/" .. k .. ".wav")
        rawset(t, k, wav)
        return wav
    end})

    -- Handler for lazily loaded music
    setmetatable(R.music, {__index=function(t, k)
        local mus = "assets/music/" .. k .. ".ogg"
        rawset(t, k, mus)
        return mus
    end})

    R.loaded = true
end

return R
