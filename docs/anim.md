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

Animations can also be cloned. They share quad information
internally. You can use this to switch what animation is
playing.

```lua
playing_anim = idle_anim:clone()
-- ... later
playing_anim = run_anim:clone()
```
