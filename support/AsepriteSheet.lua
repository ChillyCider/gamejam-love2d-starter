-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

---@class support.AsepriteSheet
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
---@param sheetData any The decoded JSON Aseprite sprite sheet, or the path to that JSON file.
---@return support.AsepriteSheet
return function(imageOrImagePath, sheetData)
    if type(imageOrImagePath) == "string" then
        imageOrImagePath = love.graphics.newImage(imageOrImagePath)
    end

    if not sheetData.frames[1] then
        error("Try exporting the sheet from Aseprite with the JSON style set to Array, not Hash", 2)
    end

    local sheet = setmetatable({
        image=imageOrImagePath,
        data=sheetData,
        quads={},
    }, MT)

    for _, frame in ipairs(sheetData.frames) do
        table.insert(sheet.quads, love.graphics.newQuad(
            frame.frame.x,
            frame.frame.y,
            frame.frame.w,
            frame.frame.h,
            sheetData.meta.size.w,
            sheetData.meta.size.h
        ))
    end

    return sheet
end
