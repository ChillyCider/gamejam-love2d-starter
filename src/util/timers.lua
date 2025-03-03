-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class util.TimerHandle
---@field seconds number
---@field end_action function?
---@field ongoing_action function?

---@class util.timers
---@field private activeTimers table<util.TimerHandle, boolean?>
---@field private toAdd table<util.TimerHandle, boolean?>
local timers = {}
local timersMT = {__index=timers}

function timers.new()
    return setmetatable({
        activeTimers={},
        toAdd={},
    }, timersMT)
end

---Removes all timers.
function timers:clear()
    for newTimer, _ in pairs(self.toAdd) do
        self.toAdd[newTimer] = nil
    end

    for timer, _ in pairs(self.activeTimers) do
        self.activeTimers[timer] = nil
    end
end

---Runs a function every tick until a later time.
---
---@param how_long number The number of seconds to run the function every tick for.
---@param callback fun(dt:number) The callback to invoke every tick.
---@return util.TimerHandle
function timers:every_tick(how_long, callback)
    local handle = {seconds=how_long, ongoing_action=callback}
    self.toAdd[handle] = true
    return handle
end

---Defers a function until a later time.
---
---@param seconds number The number of seconds to wait.
---@param callback function The callback to invoke when the timer is done.
---@return util.TimerHandle
function timers:delay(seconds, callback)
    local handle = {seconds=seconds, end_action=function() callback(callback) end}
    self.toAdd[handle] = true
    return handle
end

---Execute a function periodically.
---
---@param seconds number The number of seconds between invocations.
---@param callback function The callback to invoke.
---@return util.TimerHandle
function timers:every(seconds, callback)
    local handle

    handle = self:delay(seconds, function(_)
        callback()

        -- Go again
        handle.seconds = handle.seconds + seconds
    end)

    return handle
end

---Call this every love.update().
---
---@param dt number Seconds elapsed since last frame.
function timers:update(dt)
    -- Move new timers to the active list
    for newTimer, _ in pairs(self.toAdd) do
        self.toAdd[newTimer] = nil
        self.activeTimers[newTimer] = true
    end

    -- Tick down all timers
    for timer, _ in pairs(self.activeTimers) do
        timer.seconds = timer.seconds - dt

        if timer.ongoing_action then
            timer.ongoing_action(dt)
        end

        if timer.seconds <= 0 then
            -- The timer finished, so run its callback
            if timer.end_action then
                timer.end_action()
            end

            -- The timer callback may have updated the seconds field,
            -- so check again.
            if timer.seconds <= 0 then
                self.activeTimers[timer] = nil
            end
        end
    end
end

---Cancel a timer.
---
---@param handle util.TimerHandle The timer to cancel.
function timers:cancel(handle)
    if self.activeTimers[handle] then
        self.activeTimers[handle] = nil
    elseif self.toAdd[handle] then
        self.toAdd[handle] = nil
    end
end

---------------------------------------------------
--               TWEEN FUNCTIONS                 --
-- Based on the catalogue at https://easings.net --
---------------------------------------------------

---@class util.timers.ease
timers.ease = {}

function timers.ease.linear(x) return x end
function timers.ease.quadIn(x) return x*x end
function timers.ease.cubicIn(x) return x*x*x end
function timers.ease.quartIn(x) return x*x*x*x end
function timers.ease.quintIn(x) return x*x*x*x*x end
function timers.ease.circIn(x)
    ---@diagnostic disable-next-line:deprecated
    return 1 - math.sqrt(1 - math.pow(x, 2))
end
function timers.ease.expoIn(x)
    if x == 0 then
        return 0
    else
        ---@diagnostic disable-next-line:deprecated
        return math.pow(2, 10 * x - 10)
    end
end
function timers.ease.backIn(x)
    local c1 = 1.70158
    local c3 = c1 + 1
    return c3 * x * x * x - c1 * x * x
end
function timers.ease.elasticIn(x)
    local c4 = 2*math.pi/3
    if x == 0 then
        return 0
    elseif x == 1 then
        return 1
    else
        ---@diagnostic disable-next-line:deprecated
        return -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
    end
end
function timers.ease.bounceOut(x)
    local n1 = 7.5625
    local d1 = 2.75

    if x < 1 / d1 then
        return n1 * x * x
    elseif x < 2 / d1 then
        x = x - 1.5/d1
        return n1 * x * x + 0.75
    elseif x < 2.5 / d1 then
        x = x - 2.25 / d1
        return n1 * x * x + 0.9375
    else
        x = x - 2.625 / d1
        return n1 * x * x + 0.984375
    end
end

---Produces the "out" variant of an "in" ease function.
---
---@param ease_func fun(x:number):number
---@return fun(x:number):number
local function opposite(ease_func)
    return function(x)
        return 1 - ease_func(1 - x)
    end
end

timers.ease.quadOut = opposite(timers.ease.quadIn)
timers.ease.cubicOut = opposite(timers.ease.cubicIn)
timers.ease.quartOut = opposite(timers.ease.quartIn)
timers.ease.quintOut = opposite(timers.ease.quintIn)
timers.ease.circOut = opposite(timers.ease.circIn)
timers.ease.expoOut = opposite(timers.ease.expoIn)
timers.ease.backOut = opposite(timers.ease.backIn)
timers.ease.elasticOut = opposite(timers.ease.elasticIn)
timers.ease.bounceIn = opposite(timers.ease.bounceOut)

---Combines an "in" ease with an "out" ease for an overall smoother ease.
---
---@param in_ease_func fun(x:number):number
---@param out_ease_func fun(x:number):number
---@return fun(x:number):number
function timers.ease.inOut(in_ease_func, out_ease_func)
    return function(x)
        return (1 - x) * in_ease_func(x) + x * out_ease_func(x)
    end
end

---Tweens the fields of a table according to some ease function.
---
---@param obj table
---@param final_vals table
---@param duration number
---@param ease_func fun(x:number):number
---@param and_then fun(thisFun:function)?
function timers:tween(obj, final_vals, duration, ease_func, and_then)
    local time_spent = 0
    local initial_vals = {}

    for k,_ in pairs(final_vals) do
        initial_vals[k] = obj[k]
    end

    local handle = self:every_tick(duration, function(dt)
        time_spent = time_spent + dt
        local ease_result = ease_func(time_spent / duration)
        for k,fv in pairs(final_vals) do
            obj[k] = initial_vals[k] * (1 - ease_result) + fv * ease_result
        end
    end)

    handle.end_action = function()
        -- Set the fields to their final values.
        for k,fv in pairs(final_vals) do
            obj[k] = fv
        end
        if and_then then
            and_then(and_then)
        end
    end

    return handle
end

return timers.new()
