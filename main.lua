local GS = require "hump.gamestate"
local Timer = require "hump.timer"
local AsepriteSheet = require "support.aseprite_sheet"

_G.images = {} ---@type table<string, love.Image>
_G.sheets = {} ---@type table<string, AsepriteSheet>
_G.fonts = {} ---@type table<string, love.Font>
_G.sounds = {} ---@type table<string, love.Source>
_G.music = {} ---@type table<string, love.Source>
_G.states = {} ---@type table<string, table>

function love.load()
    -- IMAGES
    do
        local fileNames = love.filesystem.getDirectoryItems("assets/images/")
        for _, name in ipairs(fileNames) do
            if name:match("%.png$") or name:match("%.jpg$") then
                local img = love.graphics.newImage("assets/images/" .. name)
                local withoutExt = name:gsub("(%.%w+)$", "")
                _G.images[withoutExt] = img

                -- Try to load asesprite animation too if possible
                local jsonPath = "assets/images/" .. withoutExt .. ".json"
                if love.filesystem.getInfo(jsonPath, "file") then
                    _G.sheets[withoutExt] = AsepriteSheet.new(img, jsonPath)
                end
            end
        end
    end

    -- FONTS
    do
        local fileNames = love.filesystem.getDirectoryItems("assets/fonts/")
        for _, name in ipairs(fileNames) do
            if name:match("%.fnt$") or name:match("%.ttf$") then
                local fnt = love.graphics.newFont("assets/fonts/" .. name)
                _G.fonts[name:gsub("(%.%w+)$", "")] = fnt
            end
        end
    end

    -- SOUNDS
    do
        local fileNames = love.filesystem.getDirectoryItems("assets/sounds/")
        for _, name in ipairs(fileNames) do
            if name:match("%.wav$") then
                local snd = love.audio.newSource("assets/sounds/" .. name, "static")
                _G.sounds[name:gsub("(%.%w+)$", "")] = snd
            end
        end
    end

    -- MUSIC
    do
        local fileNames = love.filesystem.getDirectoryItems("assets/music/")
        for _, name in ipairs(fileNames) do
            if name:match("%.ogg$") then
                local mus = love.audio.newSource("assets/music/" .. name, "stream")
                mus:setLooping(true)
                _G.music[name:gsub("(%.%w+)$", "")] = mus
            end
        end
    end

    -- GAME STATES
    do
        local fileNames = love.filesystem.getDirectoryItems("states/")
        for _, name in ipairs(fileNames) do
            local moduleName = name:match("([^%.]+)%.lua$")
            if moduleName then
                _G.states[moduleName] = require("states." .. moduleName)
            end
        end
    end

    GS.registerEvents()

    -- Switch to the first state
    local firstState, err = love.filesystem.read("states/first_state.txt")
    if type(err) == "string" then
        error(err)
    end
    firstState = firstState:gsub("^%s*([^%s]+)%s*$", "%1")
    GS.switch(_G.states[firstState])
end

function love.update(dt)
    Timer.update(dt)
end

function love.draw()
end
