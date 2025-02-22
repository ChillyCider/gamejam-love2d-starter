-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@module 'GameObject'

---@class Group: GameObject
---@field members GameObject[]
local Group = {}

function Group:new()
    self.__index = self
    return setmetatable({visible=true, active=true, members={}}, self)
end

function Group:destroy()
    for _, memb in pairs(self.members) do
        memb:destroy()
    end
end

---@param obj GameObject
function Group:add(obj)
    table.insert(self.members, obj)
end

---@param obj GameObject
function Group:remove(obj)
    for i, memb in pairs(self.members) do
        if memb == obj then
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
