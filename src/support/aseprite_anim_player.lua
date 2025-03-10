-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class support.aseprite_anim_player
---@field paused boolean Whether to pause the animation.
---@field speedFactor number Speed at which to play the animation. 1 means normal, 0 means frozen.
local aseprite_anim_player = {}
local MT = {__index=aseprite_anim_player}

---Sets the animation player to play a specific tag of the Aseprite sheet.
---
---@param asepriteSheet support.aseprite_sheet Aseprite sheet.
---@param tagName string? The tag to play.
---@param loops number? Number of times to play the animation, or 0 or nil to loop forever.
---@param forceRestart boolean? Whether to restart the animation if it is already playing.
function aseprite_anim_player:play(asepriteSheet, tagName, loops, forceRestart)
    if asepriteSheet ~= nil and self.asepriteSheet ~= asepriteSheet then
        self.asepriteSheet = asepriteSheet
        forceRestart = true
    end

    self:playTag(tagName, loops, forceRestart)
end

function aseprite_anim_player:playTag(tagName, loops, forceRestart)
    self.paused = false
    self.loops = loops or 0
    self.loopsDone = 0

    if self.tagName ~= tagName or forceRestart then
        if tagName then
            local tag = self.asepriteSheet:tag(tagName)
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

        self.frameTimer = self.asepriteSheet.data.frames[self.frameIndex].duration / 1000
    end
end

---Advance the animation player by a number of seconds which may be fractional.
---
---@param dt number Number of seconds.
function aseprite_anim_player:update(dt)
    if not self.paused and (self.loops <= 0 or self.loopsDone < self.loops) then
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

        while self.frameTimer <= 0.0 and not self.paused and (self.loops <= 0 or self.loopsDone < self.loops) do
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
function aseprite_anim_player:finished()
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
function aseprite_anim_player:draw(x, y, r, sx, sy, ox, oy)
    love.graphics.draw(self.asepriteSheet.image, self.asepriteSheet.quads[self.frameIndex], x, y, r, sx, sy, ox, oy)
end

---Returns a new Aseprite sheet player.
---
---@param asepriteSheet support.aseprite_sheet
---@param tagName string?
---@param loops number?
---@return support.aseprite_anim_player
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
