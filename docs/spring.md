SPRINGS
=======

This is more of a tip, rather than an API documentation. Springs are useful
and can create engaging visual movements. They have two parameters: stiffness
and damping.

```lua
-- Parameters
local stiffness = 100
local damping = 1.2

local obj = {x=0, y=0, vel_x=0, vel_y=0}
local goal = {x=100, y=100}

function love.update(dt)
    -- apply spring force to velocity
    obj.vel_x = obj.vel_x + stiffness*-(obj.x-goal.x)*dt - damping*obj.vel_x*dt
    obj.vel_y = obj.vel_y + stiffness*-(obj.y-goal.y)*dt - damping*obj.vel_y*dt

    -- apply velocity to position
    obj.x = obj.x + obj.vel_x * dt
    obj.y = obj.y + obj.vel_y * dt
end
```

It will take guesswork to find the right stiffness and damping for your desired
effect.

A more exact implementation is possible, but it requires advanced math like
Ordinary Differential Equations. Not worth it, in my opinion. See Ryan Juckett's
blog post[1] for details.

[1]: https://www.ryanjuckett.com/damped-springs/
