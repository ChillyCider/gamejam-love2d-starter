local GS = require "hump.gamestate"
local Timer = require "hump.timer"

function love.load()
    GS.registerEvents()
    GS.switch({})

    -- IMAGES
    do
        _G.images = {}

        local fileNames = love.filesystem.getDirectoryItems("assets/images/")
        for _, name in ipairs(fileNames) do
            if name:match("%.png$") then
                local img = love.graphics.newImage("assets/images/" .. name)
                _G.images[name:gsub("(%.%w+)$", "")] = img
            end
        end
    end

    -- SOUNDS
    do
        _G.sounds = {}

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
        _G.music = {}

        local fileNames = love.filesystem.getDirectoryItems("assets/music/")
        for _, name in ipairs(fileNames) do
            if name:match("%.ogg$") then
                local mus = love.audio.newSource("assets/music/" .. name, "stream")
                mus:setLooping(true)
                _G.music[name:gsub("(%.%w+)$", "")] = mus
            end
        end
    end
end

function love.update(dt)
    Timer.update(dt)
end
