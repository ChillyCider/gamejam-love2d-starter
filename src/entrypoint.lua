-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

globals = require "globals"

local R = require "R"
local util = require "util"

function love.load()
    R.loadResources()
end

---@param dt number
function love.update(dt)
    time = util.wrap(globals.time + dt, 0.0, globals.TIME_ROLLOVER)
    util.timers:update(dt)
end

function love.draw()
end

