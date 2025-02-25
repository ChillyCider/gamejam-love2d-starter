-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local json = require "support.json"
local AsepriteSheet = require "support.AsepriteSheet"

---Holder for resources
local R = {}

function R.loadResources()
    ---@class R.images
    R.images = {
        mantis=love.graphics.newImage("assets/images/mantis.png"),
    }

    ---@class R.sheets
    R.sheets = {
        mantis=AsepriteSheet(R.images.mantis, json.load("assets/images/mantis.json")),
    }

    ---@class R.fonts
    R.fonts = {}

    ---@class R.sounds
    R.sounds = {}

    ---@class R.music
    R.music = {}
end

return R
