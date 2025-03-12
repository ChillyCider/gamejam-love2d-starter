THE ANIM MODULE
===============

The anim module gives you a way to play animations using a spritesheet.
An example is probably enough to understand it:

```lua
local spritesheet = require "util.spritesheet"
local anim = require "util.anim"

local mantis, idle_anim

function love.load()
    mantis = love.graphics.newImage("assets/images/mantis.png")

    local sheet = spritesheet(
        2,                 -- number of columns
        1,                 -- number of rows
        mantis:getWidth(), -- full image width
        mantis:getHeight() -- full image height
    )

    idle_anim = anim(
        sheet:quads {1, 2}, -- use quads 1 and 2 in this animation
        {0.5, 1}            -- duration of each quad
    )
end

function love.update(dt)
    idle_anim:update(dt)
end

function love.draw()
    idle_anim:draw(mantis, 0, 0)
end
```

If all quads have the same duration, then you can just pass
a single number for the duration argument of anim().

Animations can be cloned with `:clone()`. You can use this to bootstrap a new
animation player from a previously initialized one.

```lua
-- When starting out
playing_anim = idle_anim:clone()
```

Later, when you want to change the playing animation, you can do so with
`:changeTo(other)`. This will copy most fields from another animation.

```lua
-- ... later, when needing to change
playing_anim:changeTo(run_anim)
```
