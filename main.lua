-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

-- Go ahead and import misc. modules as globals
R = require "R"
support = require "support"
util = require "util"
Sprite = require "Sprite"

time = 0.0
TIME_ROLLOVER = 3600.0

---@param sprites Sprite[]
---@param dt number
local function updateAll(sprites, dt)
    for _,s in ipairs(sprites) do if s.active then s:update(dt) end end
end

---@param sprites Sprite[]
local function drawAll(sprites)
    for _, spr in ipairs(sprites) do if spr.visible then spr:draw() end end
end

Mantis = Sprite:new()
function Mantis:update(dt)
    Sprite.update(self, dt)
    self.rotation = math.cos(time * 2*math.pi / 3.6)
end

function love.load()
    sprites = {}
    for _=1,10 do
        table.insert(
            sprites,
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
    updateAll(sprites, dt)
end

function love.draw()
    drawAll(sprites)
end
