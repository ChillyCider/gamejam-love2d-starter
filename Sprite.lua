-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@module 'GameObject'

---@class Sprite: GameObject
---@field x number
---@field y number
---@field w number
---@field h number
---@field rotation number
---@field scaleX number
---@field scaleY number
---@field originX number
---@field originY number
---@field image love.Image
---@field animPlayer support.AsepriteAnimPlayer?
---@field drawMode "img"|"anim"
local Sprite = {}

function Sprite:destroy()
end

function Sprite:update(dt)
    if self.drawMode == "anim" then self.animPlayer:update(dt) end
end

function Sprite:draw()
    if self.drawMode == "img" then
        love.graphics.draw(self.image, self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
    elseif self.drawMode == "anim" then
        self.animPlayer:draw(self.x, self.y, self.rotation, self.scaleX, self.scaleY, self.originX, self.originY)
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
    if self.drawMode == "img" and self.image then
        self.w = self.image:getWidth()
        self.h = self.image:getHeight()
    elseif self.drawMode == "anim" and self.animPlayer then
        self.w = self.animPlayer.asepriteSheet.data.frames[self.animPlayer.frameIndex].frame.w
        self.h = self.animPlayer.asepriteSheet.data.frames[self.animPlayer.frameIndex].frame.h
    end
    return self
end

---@param x? number
---@param y? number
---@param imgOrAnimSheet? love.Image|support.AsepriteSheet
---@param tag string?
---@param loops number?
function Sprite:new(x, y, imgOrAnimSheet, tag, loops)
    self.__index = self
    local img = nil
    local animPlayer = nil
    local drawMode
    if imgOrAnimSheet and imgOrAnimSheet.tag then
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
        x=x or 0,
        y=y or 0,
        w=0,
        h=0,
        visible=true,
        active=true,
        rotation=0,
        scaleX=1,
        scaleY=1,
        originX=0,
        originY=0,
        image=img,
        animPlayer=animPlayer,
        drawMode=drawMode
    }, self):setHitboxFromImage()
end

return Sprite
