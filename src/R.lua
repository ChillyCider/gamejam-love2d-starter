-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local json = require "support.json"
local aseprite_sheet = require "support.aseprite_sheet"

---Holder for resources
local R = {loaded=false}

function R.loadResources()
    ---@class R.images
    R.images = {
        mantis=love.graphics.newImage("assets/images/mantis.png"),
    }

    ---@class R.sheets
    R.sheets = {
        mantis=aseprite_sheet(R.images.mantis, json.load("assets/images/mantis.json")),
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

    R.loaded = true
end

return R
