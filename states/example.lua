-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local ecs = require "ecs"
local world = ecs.World():registerSystemsFromDir("systems")

local example = {}

function example:enter()
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
