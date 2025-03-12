-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class util.spritesheet
---@field private quads_array love.Quad[]
local spritesheet = {}
local MT = {__index=spritesheet}

---@param indices integer[] The frame numbers to return quads for
---@return love.Quad[]
function spritesheet:quads(indices)
    local ret = {}

    for _, idx in ipairs(indices) do
        table.insert(ret, self.quads_array[idx])
    end

    return ret
end

---@param cols integer
---@param rows integer
---@param width integer
---@param height integer
---@return util.spritesheet
return function(cols, rows, width, height)
    local quads_array = {}

    local cell_w = width / cols
    local cell_h = height / rows

    for r=0,rows - 1 do
        for c=0,cols - 1 do
            table.insert(quads_array, love.graphics.newQuad(
                c * cell_w,
                r * cell_h,
                cell_w,
                cell_h,
                width,
                height
            ))
        end
    end

    return setmetatable({
        quads_array=quads_array
    }, MT)
end
