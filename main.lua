-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

-- Go ahead and import misc. modules as globals
R = require "R"
support = require "support"
util = require "util"
Sprite = require "Sprite"
Group = require "Group"
justPressed = {} ---@type table<love.Scancode, boolean>
justReleased = {} ---@type table<love.Scancode, boolean>

time = 0.0
TIME_ROLLOVER = 3600.0

Mantis = Sprite:new()
function Mantis:update(dt)
    Sprite.update(self, dt)
    self.rotation = math.cos(time * 2*math.pi / 3.6)
end

sprites = Group:new()
mantises = Group:new()
sprites:add(mantises)

function love.load()
    for _=1,10 do
        mantises:add(Mantis:new(
            math.random(0, love.graphics.getWidth()),
            math.random(0, love.graphics.getHeight()),
            R.sheets.mantis
        ))
    end
end

---@param dt number
function love.update(dt)
    time = util.wrap(time + dt, 0.0, TIME_ROLLOVER)
    util.Timers:update(dt)
    sprites:update(dt)

    -- Reset the `justPressed` and `justReleased` tables
    for k,v in pairs(justPressed) do if v then justPressed[k] = false end end
    for k,v in pairs(justReleased) do if v then justReleased[k] = false end end
end

function love.draw()
    sprites:draw()
end

function love.keypressed(_, scancode, _)  justPressed[scancode]  = true end
function love.keyreleased(_, scancode, _) justReleased[scancode] = true end
