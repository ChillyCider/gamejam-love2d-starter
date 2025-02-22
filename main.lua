-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local util = require "util"
local R = require "R"

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
