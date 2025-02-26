-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local clock = {
    time=0.0,
    TIME_ROLLOVER=3600.0,
}

---@param dt number Number of seconds elapsed this frame
function clock.advance(dt)
    clock.time = clock.time + dt
    while clock.time >= clock.TIME_ROLLOVER do
        clock.time = clock.time - clock.TIME_ROLLOVER
    end
end

return clock
