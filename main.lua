-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

-- src/ is where Lua files will now be searched for
love.filesystem.setRequirePath("src/?.lua;src/?/init.lua")

-- Jump immediately to entrypoint code in src/
require "entrypoint"
