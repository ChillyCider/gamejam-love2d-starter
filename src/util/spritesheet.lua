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

---@param cell_w integer
---@param cell_h integer
---@param cols integer
---@param rows integer
---@param image_width integer
---@param image_height integer
---@param x_off integer?
---@param y_off integer?
---@param x_gap integer?
---@param y_gap integer?
---@return util.spritesheet
return function(cell_w, cell_h, cols, rows, image_width, image_height, x_off, y_off, x_gap, y_gap)
    x_off = x_off or 0
    y_off = y_off or 0
    x_gap = x_gap or 0
    y_gap = y_gap or 0

    local quads_array = {}

    for r=0,rows - 1 do
        for c=0,cols - 1 do
            table.insert(quads_array, love.graphics.newQuad(
                x_off + c*(cell_w + x_gap),
                y_off + r*(cell_h + y_gap),
                cell_w,
                cell_h,
                image_width,
                image_height
            ))
        end
    end

    return setmetatable({
        quads_array=quads_array
    }, MT)
end
