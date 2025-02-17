ECS
===

The starter includes an unoptimized Entity-Component-System implementation.

Create a world like so:

```lua
local ecs = require "ecs"
local world = ecs.World()

function love.update(dt)
    world:update(dt)
end

function love.draw()
    world:draw()
end
```

For convenience, you can load all your systems from a directory. Note this
also checks the save directory, which means users are able to inject their
own systems, whether you want that or not. (I'm not sure how to avoid that.)

```lua
world:registerSystemsFromDir("systems")

-- or, for more security, manually add each system like this

world:registerSystems {
    require "systems.physics",
    require "systems.drawing",
}
```

An entity is a table containing components. In their raw form
an example entity would look like this:

```lua
-- this is an entity
local e = {
    pos={x=0, y=0},
}
```

But "pos" like that for all created entities is error prone.
So, it is better to use world:add(), which lets you pass it table of constructed
components. (This means that any error with naming happens at construct time and only
there, not somewhere down the line.) An example:

```lua
local Pos = require "com.Pos"
local Sprite = require "com.Sprite"

world:add {
    Pos(0, 0),
    Sprite(myImage),
}
```

Autoloading: there's a handy function in `util.lua` called autoLoader which can make components
more convenient at the cost of losing type information (from LuaLS annotations). The example
should be sufficient documentation:

```lua
local util = require "util"
local com = util.autoLoader "com"

world:add {
    com.Pos(0, 0),
    com.Sprite(myImage),
}
```

Component definitions: A component is just a Lua table. But, it must have a `comName` field
that world:add() can understand. Here is a full example definition of com.Pos which you can
use as a template for any component you can think of.

```lua
-- example contents of com/Pos.lua
local Pos = {comName="pos"}
local PosMT = {__index=Pos} -- enables instances to read comName

return function(x, y)
    return setmetatable({
        x=x or 0,
        y=y or 0,
    }, PosMT)
end
```

System definitions: Here is just an example.

```lua
return require("ecs").System {
    -- Systems with a lower priority number will run first
    priority=0,
    
    -- This system will only run on entities that have a "pos" and "sprite" component
    filter={"pos", "sprite"},
    
    -- Optional
    update=function(self, world, ent, dt)
        if math.random(1, 20) == 1 then
            -- Just for fun, random chance of removal
            world:scheduleRemoval(ent)
        end
    end,
    
    -- Optional
    draw=function(self, world, ent)
        love.graphics.draw(ent.sprite.image, ent.pos.x, ent.pos.y)
    end,
}
```

Systems can send messages to each other.

```lua
return require("ecs").System {
    update=function(self, world, ent, dt)
        world:notify("blah", 1, 2, 3)
    end,
    
    notify=function(self, msg, ...)
        if msg == "blah" then
            print("blah received")
        end
    end,
}
```
