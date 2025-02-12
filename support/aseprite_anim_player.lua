-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class AsepriteAnimPlayer
---@field paused boolean Whether to pause the animation.
---@field speedFactor number Speed at which to play the animation. 1 means normal, 0 means frozen.
local AsepriteAnimPlayer = {}
local MT = {__index=AsepriteAnimPlayer}

---Sets the animation player to play a specific tag of the Aseprite sheet.
---
---@param asepriteSheet AsepriteSheet Aseprite sheet.
---@param tagName string? The tag to play.
---@param loops number? Number of times to play the animation, or 0 or nil to loop forever.
---@param forceRestart boolean? Whether to restart the animation if it is already playing.
function AsepriteAnimPlayer:play(asepriteSheet, tagName, loops, forceRestart)
    self.paused = false
    self.loops = loops or 0
    self.loopsDone = 0
    self.speedFactor = 1

    if self.asepriteSheet ~= asepriteSheet or self.tagName ~= tagName or forceRestart then
        self.asepriteSheet = asepriteSheet

        if tagName then
            local tag = asepriteSheet:tag(tagName)
            if tag then
                self.tagName = tagName

                if tag.direction == "reverse" then
                    self.frameIndex = tag.to + 1
                else
                    self.frameIndex = tag.from + 1
                end

                if tag.direction == "pingpong" then
                    self.pingpong = "forward"
                end
            else
                self.tagName = nil
                self.frameIndex = 1
            end
        else
            self.tagName = nil
            self.frameIndex = 1
        end

        self.frameTimer = asepriteSheet.data.frames[self.frameIndex].duration / 1000
    end
end

---Advance the animation player by a number of seconds which may be fractional.
---
---@param dt number Number of seconds.
function AsepriteAnimPlayer:update(dt)
    if not paused and (self.loops <= 0 or self.loopsDone < self.loops) then
        local from, to, direction

        local tag = nil
        if self.tagName then
            tag = self.asepriteSheet:tag(self.tagName)
        end

        if tag then
            from = tag.from + 1
            to = tag.to + 1
            direction = tag.direction
        else
            from = 1
            to = #self.asepriteSheet.data.frames
            direction = "forward"
        end

        self.frameTimer = self.frameTimer - dt*self.speedFactor

        while self.frameTimer <= 0.0 and not paused and (self.loops <= 0 or self.loopsDone < self.loops) do
            local oldFrame = self.frameIndex

            if direction == "forward" then
                self.frameIndex = self.frameIndex + 1
                if self.frameIndex > to then
                    if self.loops > 0 then
                        self.loopsDone = self.loopsDone + 1
                    end
                    self.frameIndex = from
                end
            elseif direction == "reverse" then
                self.frameIndex = self.frameIndex - 1
                if self.frameIndex < from then
                    if self.loops > 0 then
                        self.loopsDone = self.loopsDone + 1
                    end
                    self.frameIndex = to
                end
            elseif direction == "pingpong" then
                if self.pingpong == "forward" then
                    self.frameIndex = self.frameIndex + 1
                    if self.frameIndex == to then
                        if self.loops > 0 then
                            self.loopsDone = self.loopsDone + 1
                        end
                        self.pingpong = "reverse"
                    end
                elseif self.pingpong == "reverse" then
                    self.frameIndex = self.frameIndex - 1
                    if self.frameIndex == from then
                        if self.loops > 0 then
                            self.loopsDone = self.loopsDone + 1
                        end
                        self.pingpong = "forward"
                    end
                end
            end
            
            if self.loops > 0 and self.loopsDone == self.loops and direction ~= "pingpong" then
                self.frameIndex = oldFrame
            end

            self.frameTimer = self.frameTimer + self.asepriteSheet.data.frames[self.frameIndex].duration / 1000
        end
    end
end

---Returns whether the animation finished all its loops.
---@return boolean
function AsepriteAnimPlayer:finished()
    return self.loops > 0 and self.loopsDone == self.loops
end

---Calls love.graphics.draw(...) with the current visible animation frame.
---
---@param x number The X coordinate to draw at.
---@param y number The Y coordinate to draw at.
---@param r number? Rotation in radians.
---@param sx number? Scale factor for X.
---@param sy number? Scale factor for Y.
---@param ox number? Origin X offset.
---@param oy number? Origin Y offset.
function AsepriteAnimPlayer:draw(x, y, r, sx, sy, ox, oy)
    love.graphics.draw(self.asepriteSheet.image, self.asepriteSheet.quads[self.frameIndex], x, y, r, sx, sy, ox, oy)
end

---Returns a new Aseprite sheet player.
---
---@param asepriteSheet AsepriteSheet
---@param tagName string?
---@param loops number?
---@return AsepriteAnimPlayer
return function(asepriteSheet, tagName, loops)
    local obj = setmetatable({
        paused=false,
        loops=loops or 0,
        loopsDone=0,
        speedFactor=1
    }, MT)

    obj:play(asepriteSheet, tagName, loops)

    return obj
end
