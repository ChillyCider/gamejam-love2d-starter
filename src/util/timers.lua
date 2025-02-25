-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class util.TimerHandle
---@field seconds number
---@field callback function

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

---Defers a function until a later time.
---
---@param seconds number The number of seconds to wait.
---@param callback function The callback to invoke when the timer is done.
---@return util.TimerHandle
function timers:delay(seconds, callback)
    local handle = {
        seconds=seconds,
        callback=function()
            callback(callback)
        end
    }
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
        if timer.seconds <= 0 then
            -- The timer finished, so run its callback
            timer.callback()

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

return timers.new()
