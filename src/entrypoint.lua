-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local R = require "R"
local sound_player = require "sound_player"
local util = require "util"
local clock = require "clock"

function love.load()
    -- Load all game assets
    R.loadResources()
    sound_player.init()
end

---@param dt number
function love.update(dt)
    clock.advance(dt)
    util.timers:update(dt)
    sound_player.update()
end

function love.draw()
end

