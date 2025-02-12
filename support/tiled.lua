--see docs in docs/tiled.md

--[[ IMPLEMENTATION ]]

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

---@class TiledLayerCommon
---Stuff that is shared by all types of layers.
---
---@field tiledMap TiledMap
---@field layerDef any
local TiledLayerCommon = {}
local TiledLayerCommonMT = {__index=TiledLayerCommon}
do
    ---@return number
    function TiledLayerCommon:id() return self.layerDef.id end

    ---@return string
    function TiledLayerCommon:name() return self.layerDef.name end

    ---@return string?
    function TiledLayerCommon:class() return self.layerDef.class end

    ---@return number
    function TiledLayerCommon:width() return self.layerDef.width end

    ---@return number
    function TiledLayerCommon:height() return self.layerDef.height end

    ---@return number
    function TiledLayerCommon:offsetx() return self.layerDef.offsetx or 0 end

    ---@return number
    function TiledLayerCommon:offsety() return self.layerDef.offsety or 0 end

    ---@return number
    function TiledLayerCommon:parallaxx() return self.layerDef.parallaxx or 1 end

    ---@return number
    function TiledLayerCommon:parallaxy() return self.layerDef.parallaxy or 1 end

    ---@param name string
    ---@return any
    function TiledLayerCommon:resolveProperty(name)
        return self.tiledMap:resolvePropertyOnPlain(self.layerDef, name)
    end
end

---@class TiledTileLayer: TiledLayerCommon
---@field tiledMap TiledMap
---@field layerDef any
local TiledTileLayerBase = setmetatable({}, TiledLayerCommonMT)
local TiledTileLayerMT = {__index=TiledTileLayerBase}

---Returns a convenience wrapper around a TMJ tile layer.
---
---@param tiledMap any
---@param layerDef any
---@return TiledTileLayer
function TiledTileLayer(tiledMap, layerDef)
    return setmetatable({
        tiledMap=tiledMap,
        layerDef=layerDef,
    }, TiledTileLayerMT)
end

do
    function TiledTileLayerBase:isTileLayer() return true end
    function TiledTileLayerBase:isObjectGroup() return false end
    function TiledTileLayerBase:isImageLayer() return false end

    ---Return the tile GID at a given column and row.
    ---@param x number Column
    ---@param y number Row
    ---@return number
    function TiledTileLayerBase:gidAt(x, y)
        return self.layerDef.data[y*self.layerDef.width + x]
    end

    ---Loops through tiles on this tile layer.
    ---
    ---@param minx number Starting column
    ---@param miny number Starting row
    ---@param maxx number Ending column (exclusive)
    ---@param maxy number Ending row (exclusive)
    function TiledTileLayerBase:iterateTiles(minx, miny, maxx, maxy)
        -- Restrict the loop to only tiles that are actually within map bounds
        if minx < 0 then
            minx = 0
        elseif minx > self.layerDef.width then
            minx = self.layerDef.width
        end

        if miny < 0 then
            miny = 0
        elseif miny > self.layerDef.height then
            miny = self.layerDef.height
        end

        if maxx < 0 then
            maxx = 0
        elseif maxx > self.layerDef.width then
            maxx = self.layerDef.width
        end

        if maxy < 0 then
            maxy = 0
        elseif maxy > self.layerDef.height then
            maxy = self.layerDef.height
        end

        -- Return a closure that handles the loop
        local x = minx - 1
        local y = miny
        return function()
            x = x + 1
            while x >= maxx and y < maxy do
                x = minx
                y = y + 1
            end

            if y < maxy then
                print("x: " .. x .. ", y: " .. y)
                return x, y, self.layerDef.data[y*self.layerDef.width + x + 1]
            end
        end
    end
end

---@class TiledObjectGroup: TiledLayerCommon
---@field tiledMap TiledMap
---@field layerDef any
local TiledObjectGroupBase = setmetatable({}, TiledLayerCommonMT)
local TiledObjectGroupMT = {__index=TiledObjectGroupBase}

---Returns a convenience wrapper around a TMJ object group.
function TiledObjectGroup(tiledMap, layerDef)
    return setmetatable({
        tiledMap=tiledMap,
        layerDef=layerDef,
    }, TiledObjectGroupMT)
end

do
    function TiledObjectGroupBase:isTileLayer() return false end
    function TiledObjectGroupBase:isObjectGroup() return true end
    function TiledObjectGroupBase:isImageLayer() return false end

    ---@return any[]
    function TiledObjectGroupBase:objects()
        return self.layerDef.objects
    end
end

---@class TiledImageLayer: TiledLayerCommon
---@field tiledMap TiledMap
---@field layerDef any
local TiledImageLayerBase = setmetatable({}, TiledLayerCommonMT)
local TiledImageLayerMT = {__index=TiledImageLayerBase}

---Returns a convenience wrapper around a TMJ object group.
function TiledImageLayer(tiledMap, layerDef)
    return setmetatable({
        tiledMap=tiledMap,
        layerDef=layerDef,
    }, TiledImageLayerMT)
end

do
    function TiledImageLayerBase:isTileLayer() return false end
    function TiledImageLayerBase:isObjectGroup() return false end
    function TiledImageLayerBase:isImageLayer() return true end
end

---@alias TiledLayer TiledTileLayer|TiledObjectGroup|TiledImageLayer

---@class TiledTileset
---@field tiledMap TiledMap
---@field tilesetDef any
---@field private quads love.Quad[]
local TiledTilesetBase = {}
local TiledTilesetMT = {__index=TiledTilesetBase}

---@param tiledMap TiledMap
---@param tilesetDef any
---@return TiledTileset
function TiledTileset(tiledMap, tilesetDef)
    local quads = {}

    if tilesetDef.columns > 0 then
        for i=0,tilesetDef.tilecount - 1 do
            table.insert(quads, love.graphics.newQuad(
                (i % tilesetDef.columns) * tilesetDef.tilewidth,
                math.floor(i / tilesetDef.columns) * tilesetDef.tileheight,
                tilesetDef.tilewidth,
                tilesetDef.tileheight,
                tilesetDef.imagewidth,
                tilesetDef.imageheight
            ))
        end
    end

    return setmetatable({
        tiledMap=tiledMap,
        tilesetDef=tilesetDef,
        quads=quads,
    }, TiledTilesetMT)
end

do
    ---@return number
    function TiledTilesetBase:firstgid() return self.tilesetDef.firstgid end

    ---@return boolean
    function TiledTilesetBase:containsGid(gid)
        return gid >= self.tilesetDef.firstgid and gid < self.tilesetDef.firstgid + self.tilesetDef.tilecount
    end

    ---@return string?
    function TiledTilesetBase:class() return self.tilesetDef.class end

    ---@return string?
    function TiledTilesetBase:imagePath() return self.tilesetDef.image end

    ---@return number
    function TiledTilesetBase:tilewidth() return self.tilesetDef.tilewidth end

    ---@return number
    function TiledTilesetBase:tileheight() return self.tilesetDef.tileheight end

    ---@return number
    function TiledTilesetBase:tilecount() return self.tilesetDef.tilecount end

    ---@return any
    function TiledTilesetBase:tileData(gid)
        local internalId = gid - self.tilesetDef.firstgid

        for _, tileDef in ipairs(self.tilesetDef.tiles) do
            if tileDef.id == internalId then
                return tileDef
            end
        end

        return nil
    end

    ---@return love.Quad?
    function TiledTilesetBase:quad(gid)
        local internalId = gid - self.tilesetDef.firstgid
        return self.quads[internalId + 1]
    end

    function TiledTilesetBase:resolveProperty(name)
        return self.tiledMap:resolvePropertyOnPlain(self.tilesetDef, name)
    end
end

---@class TiledMap
---@field layers TiledLayer[]
---@field tilesets TiledTileset[]objDef
---@field tmj any
local TiledMapBase = {}
local TiledMapMT = {__index=TiledMapBase}

---@param tmjPath string The path to the TMJ file, used for resolving tileset paths
---@param jsonLoader fun(path:string):any A JSON loader
---@return TiledMap
function TiledMap(tmjPath, jsonLoader)
    local decodedTMJ = jsonLoader(tmjPath)

    ---@type TiledLayer[]
    local layers = {}
    ---@type TiledTileset[]
    local tilesets = {}
    local o = {
        layers=layers,
        tilesets=tilesets,
        tmj=decodedTMJ,
    }

    for _, layerDef in ipairs(decodedTMJ.layers) do
        if layerDef.type == "tilelayer" then
            table.insert(layers, TiledTileLayer(o, layerDef))
        elseif layerDef.type == "objectgroup" then
            table.insert(layers, TiledObjectGroup(o, layerDef))
        elseif layerDef.type == "imagelayer" then
            table.insert(layers, TiledImageLayer(o, layerDef))
        end
    end

    local tmjDir = dirName(tmjPath)
    for _, tilesetDef in ipairs(decodedTMJ.tilesets) do
        if tilesetDef.source then
            -- External tileset
            local tilesetPath = tmjDir .. "/" .. tilesetDef.source
            local tsj = jsonLoader(tilesetPath)

            -- Apply stuff from the embedded stub to the loaded tsj
            for k, v in pairs(tilesetDef) do
                tsj[k] = v
            end

            table.insert(tilesets, TiledTileset(o --[[@as TiledMap]], tsj))
        else
            -- Embedded tileset
            table.insert(tilesets, TiledTileset(o --[[@as TiledMap]], tilesetDef))
        end
    end

    return setmetatable(o, TiledMapMT)
end

do
    ---@return string?
    function TiledMapBase:class() return self.tmj.class end

    ---@return number
    function TiledMapBase:tilewidth() return self.tmj.tilewidth end

    ---@return number
    function TiledMapBase:tileheight() return self.tmj.tileheight end

    ---Finds and returns a layer by name.
    ---@param name string The name of the layer
    ---@return TiledLayer?
    function TiledMapBase:layerByName(name)
        for _, layer in ipairs(self.layers) do
            if layer.layerDef.name == name then
                return layer
            end
        end

        return nil
    end

    function TiledMapBase:layerById(id)
        for _, layer in ipairs(self.layers) do
            if layer.layerDef.id == id then
                return layer
            end
        end
    end

    function TiledMapBase:objectById(id)
        for _, layerDef in ipairs(self.tmj.layers) do
            if layerDef.type == "objectgroup" then
                for _, objectDef in ipairs(layerDef.objects) do
                    if objectDef.id == id then
                        return objectDef
                    end
                end
            end
        end
    end

    function TiledMapBase:resolvePropertyOnPlain(def, name)
        for _,p in ipairs(def.properties or {}) do
            if p.name == name then
                if p.type == "string" or p.type == "int" or p.type == "bool" or p.type == "float" or p.type == "file" then
                    return p.value
                elseif p.type == "object" then
                    return self:objectById(p.value)
                end
            end
        end

        -- If the item inherits from a tile, look up the property there
        if def.gid then
            local tileset = self:tilesetForGid(def.gid)
            if tileset then
                local tileData = tileset:tileData(def.gid)
                if tileData then
                    return self:resolvePropertyOnPlain(tileData, name)
                end
            end
        end
    end

    function TiledMapBase:resolveProperty(name)
        return self:resolvePropertyOnPlain(self.tmj, name)
    end

    function TiledMapBase:tilesetForGid(gid)
        for _, tileset in ipairs(self.tilesets) do
            if gid >= tileset.tilesetDef.firstgid and gid < tileset.tilesetDef.firstgid + tileset.tilesetDef.tilecount then
                return tileset
            end
        end

        return nil
    end
end

return {
    GID_FLIP_X=0x80000000,
    GID_FLIP_Y=0x40000000,
    GID_FLIP_3=0x20000000,
    GID_FLIP_4=0x10000000,
    TiledMap=TiledMap,
}
