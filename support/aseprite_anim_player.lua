---@class AsepriteAnimPlayer
local AsepriteAnimPlayer = {}
local MT = {__index=AsepriteAnimPlayer}

---Returns a new Aseprite sheet player.
---
---@param asepriteSheet AsepriteSheet
---@param tagName string?
---@return AsepriteAnimPlayer
function AsepriteAnimPlayer.new(asepriteSheet, tagName)
    local obj = setmetatable({}, MT)

    obj:play(asepriteSheet, tagName)

    return obj
end

---Sets the animation player to play a specific tag of the Aseprite sheet.
---
---@param asepriteSheet AsepriteSheet Aseprite sheet.
---@param tagName string? The tag to play.
---@param forceRestart boolean? Whether to restart the animation if it is already playing.
function AsepriteAnimPlayer:play(asepriteSheet, tagName, forceRestart)
    if self.asepriteSheet ~= asepriteSheet or self.tagName ~= tagName or forceRestart then
        self.asepriteSheet = asepriteSheet

        if tagName then
            local tag = asepriteSheet:tag(tagName)
            if tag then
                self.frameIndex = tag.from + 1
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
    self.frameTimer = self.frameTimer - dt
    if self.frameTimer <= 0.0 then
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

        if to > from then
            if direction == "forward" then
                self.frameIndex = self.frameIndex + 1
                if self.frameIndex > to then
                    self.frameIndex = from
                end
            elseif direction == "reverse" then
                self.frameIndex = self.frameIndex - 1
                if self.frameIndex < from then
                    self.frameIndex = to
                end
            elseif direction == "pingpong" then
                if self.pingpong == "forward" then
                    self.frameIndex = self.frameIndex + 1
                    if self.frameIndex == to then
                        self.pingpong = "reverse"
                    end
                elseif self.pingpong == "reverse" then
                    self.frameIndex = self.frameIndex - 1
                    if self.frameIndex == from then
                        self.pingpong = "forward"
                    end
                end
            end
        end

        self.frameTimer = self.asepriteSheet.data.frames[self.frameIndex].duration / 1000
    end
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

return AsepriteAnimPlayer
