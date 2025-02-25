-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@module 'GameObject'

---@class Group: GameObject
---@field capacity number
---@field members GameObject[]
local Group = {}

---@param capacity number?
function Group:new(capacity)
    capacity = capacity or 0
    self.__index = self
    return setmetatable({
        visible=true,
        active=true,
        exists=true,
        capacity=capacity,
        members={}
    }, self)
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

function Group:isFull()
    return self.capacity > 0 and #self.members == self.capacity
end

---@param factory fun():GameObject
---@return GameObject
function Group:recycle(factory)
    for _, memb in pairs(self.members) do
        if not memb.exists then
            memb.exists = true
            return memb
        end
    end

    if self.capacity > 0 and #self.members == self.capacity then
        -- We're at capacity, so recycle the oldest in the group
        local oldest = self.members[1]
        table.remove(self.members, 1)
        table.insert(self.members, oldest)
        return oldest
    end

    local newObj = factory()
    self:add(newObj)
    return newObj
end

---@param dt number
function Group:update(dt)
    for _, memb in ipairs(self.members) do
        if memb.exists and memb.active then
            memb:update(dt)
        end
    end
end

function Group:draw()
    for _, memb in ipairs(self.members) do
        if memb.exists and memb.visible then
            memb:draw()
        end
    end
end

return Group
