local Pos = require "com.pos"

return require("ecs").System {
    priority=0,
    filter={"pos", "sprite"},
    
    update=function(self, world, ent, dt)
        -- Do nothing for sprite renderer
    end,
    
    draw=function(self, world, ent)
        love.graphics.draw(ent.sprite.image, ent.pos.x, ent.pos.y)
        -- Just for fun, draw a line between this entity and all the others with sprites
        for other in world:entitiesWith("pos", "sprite") do
            if ent ~= other then
                love.graphics.line(ent.pos.x, ent.pos.y, other.pos.x, other.pos.y)
            end
        end
    end,
}
