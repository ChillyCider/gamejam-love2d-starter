-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local ecs = require "ecs"
local world = ecs.World():registerSystemsFromDir("systems")

local example = {}

function example:enter()
    world:add {
        ecs.com.pos(100, 100),
        ecs.com.sprite(_G.images.mantis),
    }
    world:add {
        ecs.com.pos(120, 130),
        ecs.com.sprite(_G.images.mantis),
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
