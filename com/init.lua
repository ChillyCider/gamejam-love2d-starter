return setmetatable({
    Pos=require "com.Pos",
    Sprite=require "com.Sprite",
}, {__index=function(t, name)
    local m = require(name)
    rawset(t, name, m)
    return m
end})
