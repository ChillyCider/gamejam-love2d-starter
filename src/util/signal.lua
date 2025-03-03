-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class util.signal
local signal = {
    handlers={}, ---@type table<string, table<function, boolean?>>
}
local MT = {__index=signal}

function signal.new()
    return setmetatable({
        handlers={}
    }, MT)
end

function signal:connect(name, handler)
    if not self.handlers[name] then
        self.handlers[name] = {}
    end

    self.handlers[name][handler] = true

    return handler
end

function signal:emit(name, ...)
    if not self.handlers[name] then
        return
    end

    for handler, _ in pairs(self.handlers[name]) do
        handler(...)
    end
end

function signal:disconnect(name, handler)
    if not self.handlers[name] then
        return
    end

    self.handlers[name][handler] = nil
end

return signal
