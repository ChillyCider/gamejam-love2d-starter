local json = require "support.json"

---@class AsepriteSheet
---@field image love.Image
---@field data table
---@field quads love.Quad[]
local AsepriteSheet = {}
local MT = {__index=AsepriteSheet}

---Finds and returns a named tag in the sprite sheet.
---
---@param tagName string The name of the tag to find.
function AsepriteSheet:tag(tagName)
    for _, tag in ipairs(self.data.meta.frameTags or {}) do
        if tag.name == tagName then
            return tag
        end
    end

    return nil
end

---Returns a new Aseprite sprite sheet.
---
---@param imageOrImagePath love.Image|string The image for the sprite sheet.
---@param sheetDataOrPath any The decoded JSON Aseprite sprite sheet, or the path to that JSON file.
---@return AsepriteSheet
return function(imageOrImagePath, sheetDataOrPath)
    if type(imageOrImagePath) == "string" then
        imageOrImagePath = love.graphics.newImage(imageOrImagePath)
    end

    if type(sheetDataOrPath) == "string" then
        local contents, err = love.filesystem.read(sheetDataOrPath)
        if type(err) == "string" then
            error(err)
        end

        sheetDataOrPath = json.fromString(contents)
    end

    if not sheetDataOrPath.frames[1] then
        error("Try exporting the sheet from Aseprite with the JSON style set to Array, not Hash", 2)
    end

    local sheet = setmetatable({
        image=imageOrImagePath,
        data=sheetDataOrPath,
        quads={},
    }, MT)

    for _, frame in ipairs(sheetDataOrPath.frames) do
        table.insert(sheet.quads, love.graphics.newQuad(
            frame.frame.x,
            frame.frame.y,
            frame.frame.w,
            frame.frame.h,
            sheetDataOrPath.meta.size.w,
            sheetDataOrPath.meta.size.h
        ))
    end

    return sheet
end
