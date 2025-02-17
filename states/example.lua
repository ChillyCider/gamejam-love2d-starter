-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local ecs = require "ecs"
local util = require "util"
local com = util.autoLoader("com")
local world = ecs.World():registerSystemsFromDir("systems")

local example = {}

function example:enter()
    world:add {
        com.Pos(100, 100),
        com.Sprite(_G.images.mantis),
    }
    world:add {
        com.Pos(120, 130),
        com.Sprite(_G.images.mantis),
    }
end

function example:leave()
    world:wipe()
end

function example:update(dt)
    world:update(dt)
end

function example:draw()
    world:draw()
end

return example
