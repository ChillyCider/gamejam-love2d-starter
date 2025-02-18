TIMERS
======

```lua
local util = require "util"
```

The default timer manager is util.Timers and you can use it for all
your timers if you want. However, you can also create a new Timer
manager using util.Timers.new().

```lua
local myTimers = util.Timers.new()

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
