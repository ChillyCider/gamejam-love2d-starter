local json = require "support.json"

---Returns the directory of a file path.
---@param path string
---@return string
local function dirName(path)
    if path == "" then
        return "."
    end

    local d, _ = path:gsub("[\\/]?[^\\/]*$", "")
    if d == "" then
        if string.find("\\/", path:sub(1, 1)) then
            return "/"
        else
            return "."
        end
    end

    return d
end

---Loops through tmx.tilesets and resolves any external tileset dependencies. Note
---that this function modifies tmx in place.
---
---@param tmxPath string Path so we can resolve relative dependencies.
---@param tmx any A decoded JSON tiled map.
---@return any The same tmx object that was passed in.
local function resolveExternalTilesets(tmxPath, tmx)
    local dir = dirName(tmxPath)

    for _, tileset in ipairs(tmx.tilesets) do
        if tileset.source then
            local externalPath = dir .. "/" .. tileset.source
            local j = json.load(externalPath)

            for k, v in pairs(j) do
                if k == "image" then
                    -- The image is currently relative to the tileset file
                    -- We need to get its path from the tmx's perspective
                    local tilesetDir = dirName(tileset.source)
                    tileset.image = tilesetDir .. "/" .. v
                elseif k ~= "tiledversion" and k ~= "version" then
                    tileset[k] = v
                end
            end

            tileset.source = nil
        end
    end

    return tmx
end

return {
    resolveExternalTilesets=resolveExternalTilesets
}
