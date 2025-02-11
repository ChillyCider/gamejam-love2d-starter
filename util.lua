---Find the first item in an array that matches a table.
---
---@param array any[] The array to search.
---@param t table The table to use as the matching predicate.
---@return any? The item that matches, or nil.
---@return number? The index of the item, or nil.
local function findTableMatch(array, t)
    for i, item in ipairs(array) do
        local isMatch = true

        for k, v in pairs(t) do
            if item[k] ~= v then
                isMatch = false
                break
            end
        end

        if isMatch then
            return item, i
        end
    end

    return nil, nil
end

---Find the first item in an array that matches a predicate function.
---
---@param array any[] The array to search.
---@param pred function The predicate function.
---@return any? The item that matches, or nil.
---@return number? The index of the item, or nil.
local function findPredMatch(array, pred)
    for i, item in ipairs(array) do
        if pred(item, i) then
            return item, i
        end
    end

    return nil, nil
end

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
    findTableMatch=findTableMatch,
    findPredMatch=findPredMatch,
    distance=distance,
    clamp=clamp,
    wrap=wrap,
    lerp=lerp,
    lerpAngle=lerpAngle,
}
