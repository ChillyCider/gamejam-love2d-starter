-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class Sprite
---@field x number
---@field y number
---@field image love.Image
---@field animPlayer support.AsepriteAnimPlayer?
---@field drawMode "img"|"anim"
local Sprite = {}

function Sprite:update(dt)
    if self.drawMode == "anim" then self.animPlayer:update(dt) end
end

function Sprite:draw()
    if self.drawMode == "img" then
        love.graphics.draw(self.image, self.x, self.y)
    elseif self.drawMode == "anim" then
        self.animPlayer:draw(self.x, self.y)
    end
end

function Sprite:play(sheet, tag, loops, forceRestart)
    if sheet.tag then
        self.drawMode = "anim"
        if self.animPlayer then
            self.animPlayer:play(sheet, tag, loops, forceRestart)
        else
            self.animPlayer = support.AsepriteAnimPlayer(sheet, tag, loops)
        end
    else
        self.drawMode = "img"
        self.image = sheet
    end
end

function Sprite:setHitboxFromImage()
    if self.drawMode == "img" then
        self.w = self.image:getWidth()
        self.h = self.image:getHeight()
    elseif self.drawMode == "anim" then
        self.w = self.animPlayer.asepriteSheet.data.frames[self.animPlayer.frameIndex].frame.w
        self.h = self.animPlayer.asepriteSheet.data.frames[self.animPlayer.frameIndex].frame.h
    end
    return self
end

---@param x number
---@param y number
---@param imgOrAnimSheet love.Image|support.AsepriteSheet
function Sprite:new(x, y, imgOrAnimSheet, tag, loops)
    self.__index = self
    local img = nil
    local animPlayer = nil
    local drawMode
    if imgOrAnimSheet.tag then
        animPlayer = support.AsepriteAnimPlayer(
            imgOrAnimSheet --[[@as support.AsepriteSheet]],
            tag,
            loops
        )
        drawMode = "anim"
    else
        img = imgOrAnimSheet --[[@as love.Image]]
        drawMode = "img"
    end
    return setmetatable({
        x=x,
        y=y,
        w=0,
        h=0,
        image=img,
        animPlayer=animPlayer,
        drawMode=drawMode
    }, self):setHitboxFromImage()
end

return Sprite
