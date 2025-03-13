// SCROLL DOWN TO THE "ACTUAL MAP FORMAT STUFF" SECTION
// it is where you should make changes, when tuning this
// script for a new game

/*************************************/
/**           UTILITY FUNCS         **/
/*************************************/

const ARRAY_ITEM_PRETTIFY_THRESHOLD = 40;
const LUA_ARRAYS_WRAP_COLUMN = 50;

// prefix a string with copies of a character
function prefixChars(s, char, count) {
    var prefix = "";
    for (var i = 0; i < count; i++) {
        prefix += char;
    }
    return prefix + s;
}

function isSimpleKey(v) {
    if (typeof v !== 'string')
        return false;

    if (!v.match(/^[_A-Za-z][_A-Za-z0-9]*$/))
        return false;

    return true;
}

// take a value and turn it into a Lua-encoded form
function toLua(value, pretty=false, indent=1, indentChar=" ", currentIndent=0) {
    if (typeof value === "number" || typeof value === "string") {
        // numbers and strings, close enough to JSON so just use JSON
        return JSON.stringify(value);
    } else if (typeof value === "undefined" || value === null) {
        // nil is our answer to null and undefined
        return "nil";
    } else if (typeof value === "object") {
        if (Array.isArray(value)) {
            if (value.length > 0) {
                let arrayItems = [];

                for (let item of value) {
                    let luaizedItem = toLua(item);
                    if (luaizedItem.length >= ARRAY_ITEM_PRETTIFY_THRESHOLD) {
                        // It's long so let's use the pretty version of it
                        luaizedItem = toLua(item, true);
                    }
                    arrayItems.push(luaizedItem);
                }

                let accumulatedLines = [];
                let currentLine = "";
                while (arrayItems.length > 0) {
                    let item = arrayItems.shift();

                    if (currentLine === "") {
                        currentLine = item;
                    } else if ((currentLine + ", " + item).length >= LUA_ARRAYS_WRAP_COLUMN) {
                        // flush this line
                        accumulatedLines.push(currentLine + ",");
                        currentLine = "";
                    } else {
                        currentLine = currentLine + ", " + item;
                    }
                }
                if (currentLine !== "") {
                    accumulatedLines.push(currentLine);
                }

                // Arrays use curly braces in Lua
                return (pretty ? "{\n" : "{") +
                    accumulatedLines.map(line => prefixChars(line, indentChar, pretty ? currentIndent + indent : 0)).join(pretty ? "\n" : " ")  +
                    (pretty ? "\n" + prefixChars("}", indentChar, pretty ? currentIndent : 0) : "}");
            } else {
                // Arrays use curly braces in Lua
                return "{}";
            }
        } else {
            // Objects use equal sign instead of colon
            var a = [];
            for (let prop of Object.keys(value)) {
                let formattedKey = prop;
                if (!isSimpleKey(prop))
                    formattedKey = "[" + toLua(prop) + "]";
                a.push(prefixChars(formattedKey + "=" + toLua(value[prop], pretty, indent, indentChar, currentIndent + indent), indentChar, pretty ? currentIndent + indent : 0));
            }
            return (pretty ? "{\n" : "{") + a.join(pretty ? ",\n" : ",") + (pretty ? "\n" + prefixChars("}", indentChar, pretty ? currentIndent : 0) : "}");
        }
    }

    return "nil";
}

/**********************************************/
/**         ACTUAL MAP FORMAT STUFF          **/
/**  Modify below as needed for the specific **/
/**  love2d game you are working on. Every   **/
/**  game will probably differ here.         **/
/**********************************************/

var customMapFormat = {
    name: "Custom Lua map format",
    extension: "luamap",
    
    // API docs for the "map" variable are at
    // https://www.mapeditor.org/docs/scripting/classes/TileMap.html
    //
    // Cheatsheet:
    //  - map.layers is an Array of Layer
    //  - Useful fields/methods in Layer:
    //    - name
    //    - isTileLayer()
    //    - isObjectLayer()
    //    - isImageLayer()
    //  - TileLayer:
    //    - width      as in number of tiles
    //    - height     as in number of tiles
    //    - tileAt(x, y) returns a Tile or null if empty
    //    - flagsAt(x, y) returns a bitwise combination of Tile.FlippedHorizontally, etc.
    //  - ObjectGroup: << Note, "Group" not "Layer" unlike above method isObjectLayer()
    //    - objects is an Array of MapObject
    //  - MapObject:
    //    - name
    //    - resolvedProperty("blah")
    //    - x
    //    - y
    //    - tileFlippedHorizontally, tileFlippedVertically
    //    - rotation
    //    - shape      may be MapObject.Rectangle, MapObject.Polygon, MapObject.Polyline, MapObject.Ellipse, etc...
    //    - tile       If it is a "tile" object
    //    - polygon    an array of {x: ..., y: ...} if this is a polygon object
    //  - Tile:
    //    - tileset                   the Tileset that the tile belongs to
    //    - id                        is the ID of the tile within the tileset
    //    - resolvedProperty("blah")  obtains a property, which may even be inherited
    //  - ImageLayer:
    //    - imageFileName
    //    - opacity
    //    - repeatX    is a boolean
    //    - repeatY    is a boolean
    //    - parallaxFactor.x, parallaxFactor.y
    //    - tintColor
    //    - offset.x, offset.y
    //  
    write: function(map, fileName) {
        var f = new TextFile(fileName, TextFile.WriteOnly);
        f.write("-- This file is generated by another program. Don't edit this\n");
        f.write("-- directly or else your changes might get overwritten!\n");
        f.write("return ");
        f.write(toLua({
            a: 3,
            b: [1, 2, 4, "hello world", 50, 9013, 831, "double dragen", 818319, 0x03, 500, "cool", {a:3}],
            c: {a:3},
        }, true));
        f.write("\n");
        f.commit();
    },
    
    // read: function(fileName) {
    // },
    
    // Optional. Returns the list of files that will be written
    // upon export. Use this only if write() needs to write to several files.
    // outputFiles: function(map, fileName) {
    // }
};
tiled.registerMapFormat("customlua", customMapFormat);

let tmxFormat = tiled.mapFormatForFile(tiled.scriptArguments[0]);
let map = tmxFormat.read(tiled.scriptArguments[0]);
customMapFormat.write(map, tiled.scriptArguments[1]);
