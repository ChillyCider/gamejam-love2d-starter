-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@alias Rect {x:number, y:number, w:number, h:number}

---Pythagorean distance calculator.
---
---@param x1 number First point's X coordinate.
---@param y1 number First point's Y coordinate.
---@param x2 number Second point's X coordinate.
---@param y2 number Second point's Y coordinate.
local function distance(x1, y1, x2, y2)
    local xDist = x2 - x1
    local yDist = y2 - y1
    return math.sqrt(xDist*xDist + yDist*yDist)
end

---Returns whether a point is inside a rectangle {x=X, y=Y, w=W, h=H}.
---
---@param x number
---@param y number
---@param r Rect
local function pointXrect(x, y, r)
    return x >= r.x and y >= r.y and x < r.x+r.w and y < r.y+r.h
end

---Returns whether two rectangles overlap.
---
---@param a Rect
---@param b Rect
local function rectXrect(a, b)
    return a.x < b.x+b.w and
        a.y < b.y+b.h and
        b.x < a.x+a.w and
        b.y < a.y+a.h
end

---Clamps a number to an interval [min, max].
---
---@param x number The value.
---@param min number The lower end of the interval.
---@param max number The higher end of the interval.
local function clamp(x, min, max)
    if x < min then
        return min
    elseif x > max then
        return max
    else
        return x
    end
end

---Wraps a number to an interval [min, max)
---
---@param x number The value.
---@param min number The lower end of the interval.
---@param max number The higher end of the interval.
local function wrap(x, min, max)
    return (x - min) % (max - min) + min
end

---Interpolate from one number to another.
---
---@param a number Starting value.
---@param b number Ending value
---@param progress number Progress from the start to the end.
local function lerp(a, b, progress)
    if progress <= 0 then
        return a
    elseif progress >= 1 then
        return b
    end

    return a*(1-progress) + b*progress
end

---Interpolate one angle to another, wrapping over 0 or 2*math.pi. The values
---a and b MUST already be in the interval [0, 2*math.pi).
---
---@param a number Starting value.
---@param b number Ending value.
---@param progress number Progress from the start to the end.
local function lerpAngle(a, b, progress)
    local diff = b - a

    if diff > 0 then
        if diff > math.pi then
            -- counterclockwise
            b = b - 2*math.pi
        end
    else
        if diff < -math.pi then
            -- clockwise
            b = b + 2*math.pi
        end
    end

    return clamp(lerp(a, b, progress), 0, 2*math.pi)
end

return {
    distance=distance,
    pointXrect=pointXrect,
    rectXrect=rectXrect,
    clamp=clamp,
    wrap=wrap,
    lerp=lerp,
    lerpAngle=lerpAngle,
}
