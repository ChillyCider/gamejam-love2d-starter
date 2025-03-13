-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---Find the first item in an array that matches a table.
---
---@param array table[] The array to search.
---@param t table The table to use as the matching predicate.
---@return any? The item that matches, or nil.
---@return number? The index of the item, or nil.
local function first_kv(array, t)
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
local function first_pred(array, pred)
    for i, item in ipairs(array) do
        if pred(item, i) then
            return item, i
        end
    end

    return nil, nil
end

return {
    first_kv=first_kv,
    first_pred=first_pred,
}
