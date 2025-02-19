-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local Widget = require "ui.r.Widget"

---@alias ui.r.VBoxAlignment "start"|"middle"|"end"|"fill"

---@class ui.r.VBox: ui.r.Widget
---@field gap number
---@field children ui.r.Widget[]
---@field private proportions number[]
---@field private alignments ui.r.VBoxAlignment[]
---@overload fun(gap:number?):ui.r.VBox
local VBox = {}
local MT = {__index=VBox}

---@param gap number?
function VBox:initialize(gap)
    Widget.initialize(self)
    self.gap = gap or 0
    self.children = {}
    self.proportions = {}
    self.alignments = {}
end

---@return number
function VBox:minWidth()
    if self.minWidthOverride then
        return self.minWidthOverride
    end

    local biggest = 0
    for _, w in ipairs(self.children) do
        local value = w:minWidth()
        if biggest < value then
            biggest = value
        end
    end

    return biggest
end

---@return number
function VBox:minHeight()
    if self.minHeightOverride then
        return self.minHeightOverride
    end

    local sum = 0
    for _, w in ipairs(self.children) do
        sum = sum + w:minHeight()
    end

    return sum + self.gap(#self.children - 1)
end

---@param x number
---@param y number
---@param width number
---@param height number
function VBox:layout(x, y, width, height)
    local fixedSpace = 0
    local proportionSum = 0

    for i, w in ipairs(self.children) do
        if i > 1 then
            fixedSpace = fixedSpace + self.gap
        end

        if self.proportions[i] == 0 then
            fixedSpace = fixedSpace + w:minHeight()
        end

        proportionSum = proportionSum + self.proportions[i]
    end

    local remainingSpace = height - fixedSpace

    local accumulated = y
    for i, c in ipairs(self.children) do
        local cx, cy, cwidth, cheight

        if i > 1 then
            accumulated = accumulated + self.gap
        end

        cy = accumulated

        if self.proportions[i] > 0 then
            cheight = remainingSpace * self.proportions[i]/proportionSum
        else
            cheight = c:minHeight()
        end

        if self.alignments[i] == "start" then
            cwidth = c:minWidth()
            cx = x
        elseif self.alignments[i] == "middle" then
            cwidth = c:minWidth()
            cx = x + width/2 - cwidth/2
        elseif self.alignments[i] == "end" then
            cwidth = c:minWidth()
            cx = x + width - cwidth
        elseif self.alignments[i] == "fill" then
            cwidth = width
            cx = x
        end

        self.children[i]:layout(cx, cy, cwidth, cheight)
        accumulated = accumulated + cheight
    end
end

---@param proportion number
---@param alignment ui.r.VBoxAlignment
---@param widget ui.r.Widget
function VBox:add(proportion, alignment, widget)
    table.insert(self.children, widget)
    table.insert(self.proportions, proportion)
    table.insert(self.alignments, alignment)
end

function VBox:remove(index)
    table.remove(self.children, index)
    table.remove(self.proportions, index)
    table.remove(self.alignments, index)
end

function VBox:draw()
    for _, c in ipairs(self.children) do
        c:draw()
    end
end

---@diagnostic disable-next-line: param-type-mismatch
return setmetatable(VBox, {__index=Widget, __call=function(_, ...)
    local obj = setmetatable({}, MT)
    obj:initialize(...)
    return obj
end})
