-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

return setmetatable({
}, {__index=function(t, name)
    local m = require("com." .. name)
    rawset(t, name, m)
    return m
end})
