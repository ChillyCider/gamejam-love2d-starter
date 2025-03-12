-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@alias util.anim.Direction "forward"|"reverse"|"pingpong"

---@class util.anim
---@field quads love.Quad[]
---@field durations number[]|number
---@field current_frame integer
---@field frame_time_spent number
---@field playback_speed number
---@field private direction util.anim.Direction
local anim = {}
local MT = {__index=anim}

---@return util.anim
function anim:clone()
    return anim(self.quads, self.durations)
end

---Draws the animation onto the screen or current Canvas.
---
---@param x number
---@param y number
---@param r number?
---@param sx number?
---@param sy number?
---@param ox number?
---@param oy number?
function anim:draw(image, x, y, r, sx, sy, ox, oy)
    love.graphics.draw(image, self.quads[self.current_frame], x, y, r, sx, sy, ox, oy)
end

local function get_frame_duration(durations, frame_number)
    if type(durations) == "number" then
        return durations
    else
        return durations[frame_number]
    end
end

---Advances the animation by an elapsed number of seconds (may be fractional).
---
---@param dt number
function anim:update(dt)
    if self.direction == "forward" then
        self.frame_time_spent = self.frame_time_spent + dt
        local frame_duration = get_frame_duration(self.durations, self.current_frame)
        while self.frame_time_spent >= frame_duration do
            self.frame_time_spent = self.frame_time_spent - frame_duration

            self.current_frame = self.current_frame + 1
            if self.current_frame > #self.quads then
                self.current_frame = 1
            end

            frame_duration = get_frame_duration(self.durations, self.current_frame)
        end
    elseif self.direction == "reverse" then
        error("Reverse animation playback not yet implemented")
    elseif self.direction == "pingpong" then
        error("Pingpong animation playback not yet implemented")
    end
end

---@param quads love.Quad[]
---@param durations number[]|number
---@return util.anim
return function(quads, durations)
    return setmetatable({
        quads=quads,
        durations=durations,
        current_frame=1,
        frame_time_spent=0,
        playback_speed=1,
        direction="forward",
    }, MT)
end
