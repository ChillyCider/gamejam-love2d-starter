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
    
    local tileset, image
    local tileW = map:tilewidth()
    local tileH = map:tileheight()
    
    -- A GID uniquely identifies a tile regardless of what tileset it is from
    -- (i.e. "global tile ID")

    for col, row, gid in layer:iterateTiles(0, 0, 200, 100) do
        -- Does the last accessed tileset have this GID too?

        if not tileset or not tileset:containsGid(gid) then
            -- No it doesn't. Pull up the right tileset
            tileset = map:tilesetForGid(gid)

            -- The image key is the image filename with no extension
            local imageKey = tileset:imagePath():match("([^\\/]+)%.png$")
            image = _G.images[imageKey]
        end

        -- Draw the tile
        local quad = tileset:quad(gid)
        love.graphics.draw(image, quad, col * tileW, row * tileH)
    end
```

Wrapped structures such as maps, tilesets, and layers have a :resolveProperty() method
which you can use to access their properties. They also have methods to
access regular fields.

```lua
    local corruption = layer:resolveProperty("corruption")
    local class = layer:class()
    local width = layer:width()
```

However, unwrapped structures like game objects need to use a method on the TiledMap
called resolvePropertyOnPlain(), or for non-properties, resolveFieldOnPlain().
If you don't care about inheritance, you can access fields the normal way
too.

```lua
    local health = map:resolvePropertyOnPlain(player, "health")
    local type = map:resolveFieldOnPlain(player, "type")
    local x = player.x
```

When iterating over tiles, you can also access their properties, but you need to
use the tileset's tileData method first.

```lua
    for col, row, gid in layer:iterateTiles(0, 0, 5, 5) do
        local tileset = map:tilesetForGid(gid)

        local data = tileset:tileData(gid)
        local solid = map:resolvePropertyOnPlain(data, "solid")
    end
```
