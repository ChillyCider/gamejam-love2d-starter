local ecs = require "ecs"

return ecs.System {
    priority=0,
    requires={"foo"},
    
    update=function(self, world, ent, dt)
    end,
    
    draw=function(self, world, ent)
    end,
}
