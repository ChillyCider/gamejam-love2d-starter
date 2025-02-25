-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

globals = require "globals"

local R = require "R"
local util = require "util"

function love.load()
    -- Load all game assets
    R.loadResources()
end

---@param dt number
function love.update(dt)
    -- Move clock forward, rolling over if necessary
    globals.time = globals.time + dt
    if globals.time >= globals.TIME_ROLLOVER then
        globals.time = globals.time - globals.TIME_ROLLOVER
    end

    -- Update all running timers
    util.timers:update(dt)
end

function love.draw()
end

