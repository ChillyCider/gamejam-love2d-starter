-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

-- Go ahead and import misc. modules as globals
R = require "R"
support = require "support"
util = require "util"
Sprite = require "Sprite"
Group = require "Group"

time = 0.0
TIME_ROLLOVER = 3600.0

Mantis = Sprite:new()

function Mantis:update(dt)
    Sprite.update(self, dt)
    self.rotation = math.cos(time * 2*math.pi / 3.6)
end

function love.load()
    mantises = Group:new()
    for _=1,10 do
        mantises:add(
            Mantis:new(
                math.random(0, love.graphics.getWidth()),
                math.random(0, love.graphics.getHeight()),
                R.sheets.mantis
            )
        )
    end
end

---@param dt number
function love.update(dt)
    time = util.wrap(time + dt, 0.0, TIME_ROLLOVER)
    util.Timers:update(dt)
    mantises:update(dt)
end

function love.draw()
    mantises:draw()
end
