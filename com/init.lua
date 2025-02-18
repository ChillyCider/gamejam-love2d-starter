return setmetatable({
}, {__index=function(t, name)
    local m = require("com." .. name)
    rawset(t, name, m)
    return m
end})
