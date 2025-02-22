-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

-- Go ahead and import misc. modules as globals
R = require "R"
support = require "support"
util = require "util"

function love.load()
end

---@param dt number
function love.update(dt)
    util.Timers:update(dt)
end

function love.draw()
end
