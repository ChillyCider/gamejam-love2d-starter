TIMERS
======

```lua
local timers = require "util.timers"
```

The default timer manager is util.timers and you can use it for all
your timers if you want. However, you can also create a new Timer
manager using timers.new().

```lua
local myTimers = timers.new()

myTimers:delay(2.5, function() print("hello") end)
myTimers:delay(5, function(thisFunc)
    myTimers:delay(4, thisFunc)
end)
myTimers:every(10, function() print("10 seconds passed again") end)
```

The timer manager must be updated in love.update(), like this:

```lua
function love.update(dt)
    myTimers:update(dt)
end
```

Timers can be canceled too.

```lua
local handle = myTimers:delay(1, function() print("hello") end)
myTimers:cancel(handle)
```

For convenience and inspired by hump's api, tweening is part of the timing library.
I'm actually considering splitting these up, because sometimes you want tweens
to occur before other things. So maybe in the future we'll have a tween manager
all on its own.

Anyway, use tweens like so:

```lua
local handle = myTimers:tween(obj, {x=30, y=40}, 5, myTimers.ease.circOut)
```

Easing functions can be combined for cool in-out behaviors.

```lua
-- invoking inOut will produce a new function
-- so consider saving and reusing your combined tween function
-- (don't make a new one every time)

local handle = myTimers:tween(obj, {x=100, y=100}, 4, myTimers.ease.inOut(myTimers.ease.elasticIn, myTimers.ease.circOut))
```
