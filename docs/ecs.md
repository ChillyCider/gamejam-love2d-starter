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

For convenience, you can load all your systems from a directory.

```lua
-- is insecure since it also checks the save directory

world:registerSystemsFromDir("systems")

-- for more security, manually add each system like this

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

But writing components like that for all created entities is error prone, and such
errors would not be detected until later access. So, it is better to use world:add(),
which lets you pass a table of constructed components. (This means that errors happen
at construct time and only there, not somewhere down the line.) An example:

```lua
local com = require "com"

world:add {
    com.Pos(0, 0),
    com.Sprite(myImage),
}
```

Component definitions: A component is just a Lua table. But, it must have a `comName` field
that world:add() can understand. `comName` will be used as the key in the actual raw entity.
Here is a full example definition of com.Pos which you can use as a template for almost any
component you can think of.

```lua
---@class com.Pos
---@field x number
---@field y number
local Pos = {comName="pos"}
local MT = {__index=Pos}

local function constructor(x, y)
    return setmetatable({
        x=x or 0,
        y=y or 0,
    }, MT)
end

---@overload fun(x:number?, y:number?):com.Pos
return setmetatable(Pos, {__call=function(t, ...)
    return constructor(...)
end})
```

System definitions: Check in `systems/`, but here is just an example.

```lua
-- A possible systems/example.lua
local ecs = require "ecs"

return ecs.System {
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
