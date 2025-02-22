-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

-- Go ahead and import misc. modules as globals
R = require "R"
support = require "support"
util = require "util"

state = {}

function _G.switchState(newState)
    if state and state.leave then state:leave() end
    state = newState
    if state and state.enter then state:enter() end
end

function love.load()
    state = R.states.example
end

---@param dt number
function love.update(dt)
    util.Timers:update(dt)
    if state.update then state:update(dt) end
end

function love.draw()
    if state.draw then state:draw() end
end
