-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local Widget = require "ui.r.Widget"

---@alias ui.r.HBoxAlignment "start"|"middle"|"end"|"fill"

---@class ui.r.HBox: ui.r.Widget
---@field gap number
---@field children ui.r.Widget[]
---@field private proportions number[]
---@field private alignments ui.r.HBoxAlignment[]
---@overload fun(gap:number?):ui.r.HBox
local HBox = {}
local MT = {__index=HBox}

---@param gap number?
function HBox:initialize(gap)
    Widget.initialize(self)
    self.gap = gap or 0
    self.children = {}
    self.proportions = {}
    self.alignments = {}
end

---@return number
function HBox:minWidth()
    if self.minWidthOverride then
        return self.minWidthOverride
    end

    local sum = 0
    for _, w in ipairs(self.children) do
        sum = sum + w:minWidth()
    end

    return sum + self.gap(#self.children - 1)
end

---@return number
function HBox:minHeight()
    if self.minHeightOverride then
        return self.minHeightOverride
    end

    local biggest = 0
    for _, w in ipairs(self.children) do
        local value = w:minHeight()
        if biggest < value then
            biggest = value
        end
    end

    return biggest
end

---@param x number
---@param y number
---@param width number
---@param height number
function HBox:layout(x, y, width, height)
    local fixedSpace = 0
    local proportionSum = 0

    for i, w in ipairs(self.children) do
        if i > 1 then
            fixedSpace = fixedSpace + self.gap
        end

        if self.proportions[i] == 0 then
            fixedSpace = fixedSpace + w:minWidth()
        end

        proportionSum = proportionSum + self.proportions[i]
    end

    local remainingSpace = width - fixedSpace

    local accumulated = x
    for i, c in ipairs(self.children) do
        local cx, cy, cwidth, cheight

        if i > 1 then
            accumulated = accumulated + self.gap
        end

        cx = accumulated

        if self.proportions[i] > 0 then
            cwidth = remainingSpace * self.proportions[i]/proportionSum
        else
            cwidth = c:minWidth()
        end

        if self.alignments[i] == "start" then
            cheight = c:minHeight()
            cy = y
        elseif self.alignments[i] == "middle" then
            cheight = c:minHeight()
            cy = y + height/2 - cheight/2
        elseif self.alignments[i] == "end" then
            cheight = c:minHeight()
            cy = y + height - cheight
        elseif self.alignments[i] == "fill" then
            cheight = height
            cy = y
        end

        self.children[i]:layout(cx, cy, cwidth, cheight)
        accumulated = accumulated + cwidth
    end
end

---@param proportion number
---@param alignment ui.r.HBoxAlignment
---@param widget ui.r.Widget
function HBox:add(proportion, alignment, widget)
    table.insert(self.children, widget)
    table.insert(self.proportions, proportion)
    table.insert(self.alignments, alignment)
end

function HBox:remove(index)
    table.remove(self.children, index)
    table.remove(self.proportions, index)
    table.remove(self.alignments, index)
end

function HBox:draw()
    for _, c in ipairs(self.children) do
        c:draw()
    end
end

---@diagnostic disable-next-line: param-type-mismatch
return setmetatable(HBox, {__index=Widget, __call=function(_, ...)
    local obj = setmetatable({}, MT)
    obj:initialize(...)
    return obj
end})
