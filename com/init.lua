return setmetatable({
    Pos=require "Pos",
    Sprite=require "Sprite",
}, {__index=function(t, name)
    local m = require(name)
    rawset(t, name, m)
    return m
end})
