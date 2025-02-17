---@class ecs.System
local SystemClass = {}
local SystemMT = {__index=SystemClass}

local function System(obj)
    return setmetatable(obj or {}, SystemMT)
end

local function systemSortComparison(sys1, sys2)
    return (sys1.priority or 0) < (sys2.priority or 0)
end

---@class ecs.World
---@field entities table[]
---@field entitiesToRemove table<table, boolean>
---@field updateSystems System[]
---@field drawSystems System[]
---@field systems System[]
local WorldClass = {}
local WorldMT = {__index=WorldClass}

local function World()
    return setmetatable({
        entities={},
        entitiesToRemove={},
        updateSystems={},
        drawSystems={},
        notifySystems={},
    }, WorldMT)
end

---@param entity table
function WorldClass:add(entity)
    table.insert(self.entities, entity)
    return self
end

function WorldClass:wipe()
    self.entities = {}
    self.entitiesToRemove = {}
end

---@param entity table
function WorldClass:scheduleRemoval(entity)
    self.entitiesToRemove[entity] = true
    return self
end

function WorldClass:flushRemovalQueue()
    for i=#self.entities,1,-1 do
        local ent = self.entities[i]
        if self.entitiesToRemove[ent] then
            table.remove(self.entities, i)
            self.entitiesToRemove[ent] = nil
        end
    end
end

---@param system System
function WorldClass:registerSystems(systems)
    for _, sys in ipairs(systems) do
        if sys.update then
            table.insert(self.updateSystems, sys)
            table.sort(self.updateSystems, systemSortComparison)
        end

        if sys.draw then
            table.insert(self.drawSystems, sys)
            table.sort(self.drawSystems, systemSortComparison)
        end

        if sys.notify then
            table.insert(self.notifySystems, sys)
            table.sort(self.notifySystems, systemSortComparison)
        end
    end

    return self
end

---@param dir The directory to load systems from, WITHOUT a trailing slash.
function WorldClass:registerSystemsFromDir(dir)
    local systems = {}

    for _, fname in ipairs(love.filesystem.getDirectoryItems(dir)) do
        if fname:match("%.lua$") then
            table.insert(systems, assert(love.filesystem.load(dir .. "/" .. fname))())
        end
    end

    self:registerSystems(systems)

    return self
end

function WorldClass:unregisterSystems(systems)
    for _, sys in ipairs(systems) do
        for i=#self.updateSystems,1,-1 do
            if sys == self.updateSystems[i] then
                table.remove(self.updateSystems, i)
            end
        end

        for i=#self.drawSystems,1,-1 do
            if sys == self.drawSystems[i] then
                table.remove(self.drawSystems, i)
            end
        end

        for i=#self.notifySystems,1,-1 do
            if sys == self.notifySystems[i] then
                table.remove(self.notifySystems, i)
            end
        end
    end
end

---Iterates over all entities with the requested components.
---@param ... string
---@return function
function WorldClass:entitiesWith(...)
    local i = 0
    local filter = {...}
    local entities = self.entities
    local lastIndex = #self.entities
    return function()
        while i < lastIndex do
            i = i + 1

            local ent = entities[i]
            local matches = true

            for _, component in ipairs(filter) do
                if not ent[component] then
                    matches = false
                    break
                end
            end

            if matches then
                return ent
            end
        end
    end
end

function WorldClass:notify(...)
    for _, sys in ipairs(self.notifySystems) do
        sys:notify(...)
    end
end

---@param dt number
function WorldClass:update(dt)
    for _, us in ipairs(self.updateSystems) do
        if not us.disabled then
            -- Loop through entities and pass them to the system
            -- if they match
            for _, ent in ipairs(self.entities) do
                local matches = true

                if us.filter then
                    for _, component in ipairs(us.filter or {}) do
                        if not ent[component] then
                            matches = false
                            break
                        end
                    end
                end

                if matches then
                    us:update(self, ent, dt)
                end
            end
        end
    end

    self:flushRemovalQueue()
end

function WorldClass:draw()
    for _, ds in ipairs(self.drawSystems) do
        if not ds.disabled then
            -- Loop through entities and pass them to the system
            -- if they match
            for _, ent in ipairs(self.entities) do
                local matches = true

                if ds.filter then
                    for _, component in ipairs(ds.filter) do
                        if not ent[component] then
                            matches = false
                            break
                        end
                    end
                end

                if matches then
                    ds:draw(self, ent)
                end
            end
        end
    end
end

return {
    System=System,
    World=World
}
