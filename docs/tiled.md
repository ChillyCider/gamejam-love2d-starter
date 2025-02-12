THE TILED SUPPORT MODULE
========================

This is a rough module designed to let you access Tiled maps in a flexible way.
It works by taking a decoded JSON Tiled map and wrapping it with a thin OOP facade.

This "wrapping" is only done for maps, tilesets, and layers since there are
so few of those things in a map. Individual game objects and tiles are kept
as plain old data and must be treated as normal JSON-decoded tables.

(This is one of the compromises we make to avoid inflating memory requirements
on constrained environments like WebAssembly).

INSTRUCTIONS FOR USE
--------------------

This module can be imported like so:

```lua
    local tiled = require("support.tiled")
```

Now create a TiledMap object. Its constructor takes a JSON loader, because it has
to retrieve the map data and also its external dependencies.

```lua
    local map = tiled.TiledMap("assets/maps/mymap.tmj", json.load)
```

Now you can access a majority of the information associated with that Tiled map.
For example, you can loop over all layers:

```lua
    for _, layer in ipairs( map.layers ) do
        if layer:isObjectGroup() then
             -- blah
        end
    end
```

Alternatively, get a layer by name:

```lua
    local layer = map:layerByName("Object Layer 1")
```

Loop through objects in a layer:

```lua
    assert(layer:isObjectGroup())

    for _, obj in ipairs( layer:objects() ) do
         NOTE: obj is plain old data
        if obj.type == "player" then
             FOUND IT!
            print(obj.x .. " " .. obj.y)
        end
    end
```

Loop through tiles in a tile layer and draw them:

```lua
    assert(layer:isTileLayer())
    
    -- helps to avoid expensive calls to map:tilesetForGid() and string.match
    local ts = nil
    local image = nil

    -- loop through the tiles
    for col, row, gid in layer:iterateTiles(0, 0, 200, 100) do
        if gid ~= 0 then
            -- Reuse last tileset and image if it's the same
            if not ts or not ts:containsGid(gid) then
                ts = map:tilesetForGid(gid)
                image = _G.images[ts:imagePath():match("([^\\/]+)%.png$")]
            end

            -- DRAW the tile.
            local quad = ts:quad(gid)
            love.draw(image, quad, col * map:tilewidth(), row * map:tileheight())
        end
    end
```

Wrapped structures such as maps, tilesets, and layers have a :resolveProperty() method
which you can use to access their properties.

```lua
    local corruption = layer:resolveProperty("corruption")
```

However, unwrapped structures like game objects need to use a method on the TiledMap
called resolvePropertyRaw().

```lua
    local health = map:resolvePropertyOnPlain(player, "health")
    local strength = map:resolvePropertyOnPlain(map:objectById(5), "strength")
```
