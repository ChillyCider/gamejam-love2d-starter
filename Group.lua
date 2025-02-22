-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class Group
---@field visible boolean
---@field active boolean
---@field members Sprite[]
local Group = {}

function Group:new()
    self.__index = self
    return setmetatable({visible=true, active=true, members={}}, self)
end

---@param sprite Sprite
function Group:add(sprite)
    table.insert(self.members, sprite)
end

---@param sprite Sprite
function Group:remove(sprite)
    for i, memb in ipairs(self.members) do
        if memb == sprite then
            table.remove(self.members, i)
            break
        end
    end
end

---@param dt number
function Group:update(dt)
    for _, memb in ipairs(self.members) do
        if memb.active then
            memb:update(dt)
        end
    end
end

function Group:draw()
    for _, memb in ipairs(self.members) do
        if memb.visible then
            memb:draw()
        end
    end
end

return Group
