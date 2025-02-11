function findFirst(array, pred)
    if type(pred) == "table" then
        for i, item in ipairs(array) do
            local isMatch = true

            for k, v in pairs(pred) do
                if item[k] ~= v then
                    isMatch = false
                    break
                end
            end

            if isMatch then
                return item, i
            end
        end
    else
        for i, item in ipairs(array) do
            if pred(item, i) then
                return item, i
            end
        end
    end

    return nil, nil
end

return {
    findFirst=findFirst,
}
