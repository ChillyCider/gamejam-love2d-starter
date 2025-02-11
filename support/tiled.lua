-- Helper functions for dealing with Tiled *.tmj files

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

---Loops through tmx.tilesets and reads any external tilesets and places their
---definitions into the tmx table. Note that this MODIFIES tmx in place.
---
---@param tmxPath string Path so we can resolve relative dependencies.
---@param tmx any A decoded JSON tiled map.
---@return any The same tmx object that was passed in.
local function embedExternalTilesets(tmxPath, tmx)
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

---Searches a list of tilesets, checking their firstgid to find
---a given Global Tile ID.
---
---@param tmx any A decoded JSON tiled map WITH external tilesets resolved.
---@param gid number A Global Tile ID.
---@return any The tileset for the given gid, if found.
---@return number? The id of the tile within the tileset.
---@return any The tile data, if it has any in particular.
local function lookupTile(tmx, gid)
    local candidateTileset = nil

    for _, tileset in ipairs(tmx.tilesets) do
        if gid >= tileset.firstgid and (not candidateTileset or tileset.firstgid > candidateTileset.firstgid) then
            candidateTileset = tileset
        end
    end

    if not candidateTileset then
        return nil, nil, nil
    end

    local internalId = gid - candidateTileset.firstgid
    local tileData = nil
    for _, tile in ipairs(candidateTileset.tiles) do
        if tile.id == internalId then
            tileData = tile
        end
    end

    return candidateTileset, internalId, tileData
end

---Iterator for tile GIDs in a tile layer
local function eachTile(tmx, layer)
    local x = -1
    local y = 0
    return function()
        x = x + 1
        if x >= layer.width then
            x = 0
            y = y + 1
        end

        if x < layer.width and y < layer.height then
            local gid = layer.data[y*layer.width + x]
            local tileset, internalId, tileData = lookupTile(tmx, gid)
            return x, y, gid, tileData, tileset, internalId
        end
    end
end

---@param tmx any
---@param id number
---@return any?
local function lookupObject(tmx, id)
    for _, layer in ipairs(tmx.layers) do
        if layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                if obj.id == id then
                    return obj
                end
            end
        end
    end

    return nil
end

---@param tmx any
---@param p any
---@return any
local function evaluateProperty(tmx, p)
    if p.type == "string" or p.type == "number" or p.type == "boolean" then
        return p.value
    elseif p.type == "object" then
        return lookupObject(tmx, p.value)
    end
end

---Read the properties of an object. If a property is missing but a gid is present,
---the function will look up the gid and check properties there.
---
---@param tmx any
---@param obj any
---@param name string
---@return any?
local function property(tmx, obj, name)
    for _,p in ipairs(obj.properties or {}) do
        if p.name == name then
            return evaluateProperty(p)
        end
    end

    if obj.gid then
        local _, _, tileData = lookupTile(tmx, obj.gid)
        for _,p in ipairs(tileData.properties or {}) do
            if p.name == name then
                return evaluateProperty(tmx, p)
            end
        end
    end

    return nil
end

return {
    GID_FLIP_X=0x80000000,
    GID_FLIP_Y=0x40000000,
    GID_FLIP_3=0x20000000,
    GID_FLIP_4=0x10000000,
    embedExternalTilesets=embedExternalTilesets,
    eachTile=eachTile,
    lookupObject=lookupObject,
    lookupTile=lookupTile,
    property=property
}
