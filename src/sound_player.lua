-- (c) 2025 Charlie Murphy
-- This code is licensed under MIT license (see LICENSE.txt for details)

local R = require "R"

---A sound player that recycles Sources for new played instances of the same sounds.
local sound_player = {
    sources={}, ---@type table<love.SoundData, love.Source[]>
    requests={}, ---@type table<love.SoundData, number>
    currentMusicPath=nil, ---@type string?
    musicSource=nil, ---@type love.Source?
}

-- Hold only weak references to SoundData objects
setmetatable(sound_player.sources, {__mode="k"})
setmetatable(sound_player.requests, {__mode="k"})

---Must be called AFTER R.loadResources()
function sound_player.createInitialSources()
    assert(R.loaded)

    for _, soundData in pairs(R.sounds) do
        sound_player.sources[soundData] = {
            love.audio.newSource(soundData, "static")
        }
    end
end

---Must be called every frame to process play requests.
function sound_player.update()
    for soundData, volume in pairs(sound_player.requests) do
        sound_player.playDirect(soundData, volume)
        sound_player.requests[soundData] = nil
    end
end

---Returns whether a sound is playing.
---@return love.Source?
function sound_player.playing(soundData)
    for _, src in pairs(sound_player.sources[soundData]) do
        if src:isPlaying() then
            return src
        end
    end

    return nil
end

---Requests a sound to be played at next tick, overwriting quieter requests
---for the same sound. This means you won't blast the speakers if you play
---the same sound twice on the same frame.
---
---@param soundData love.SoundData
---@param volume number?
function sound_player.play(soundData, volume)
    volume = volume or 1

    if not sound_player.requests[soundData] or sound_player.requests[soundData] < volume then
        sound_player.requests[soundData] = volume
    end
end

---Plays a sound immediately, re-using an existing Source if there is one free.
---Sources are reclaimed when they finish playing. Prefer using play(), which
---only plays one copy of the sound per tick of the game.
---
---@param soundData love.SoundData
---@param volume number?
---@return love.Source? An audio source. DON'T keep a reference to this, because it will be reclaimed when it finishes.
function sound_player.playDirect(soundData, volume)
    volume = volume or 1

    if not sound_player.sources[soundData] then
        sound_player.sources[soundData] = {}
    end

    local sourcesForThisSound = sound_player.sources[soundData]

    -- First, try to reclaim a finished Source
    local source
    for _, s in pairs(sourcesForThisSound) do
        if not s:isPlaying() then
            -- Reclaim this source
            source = s
        end
    end

    -- If we couldn't reclaim a sound, we need to make a new one
    if not source then
        -- Try cloning one first
        local existingSource = sourcesForThisSound[1]
        if existingSource then
            source = existingSource:clone()
        else
            -- There was nothing to clone. I guess this was a brand new sound.
            -- Create a fresh source
            source = love.audio.newSource(soundData, "static")
        end

        table.insert(sourcesForThisSound, source)
    end

    -- Configure the source before playing
    source:seek(0)
    source:setVolume(volume)
    --source:setAirAbsorption(0)
    source:setPitch(1)
    source:play()

    return source
end

---Plays a music file, stopping whatever music was already playing, if any.
---
---@param path string
---@return love.Source
function sound_player.playMusic(path, volume)
    if path == nil or (path ~= nil and sound_player.currentMusicPath == path) then
        if volume then
            sound_player.musicSource:setVolume(volume)
        end
        sound_player.musicSource:play()
        return sound_player.musicSource
    end

    if sound_player.musicSource then
        sound_player.musicSource:stop()
        sound_player.musicSource:release()
    end

    sound_player.currentMusicPath = path
    sound_player.musicSource = love.audio.newSource(path, "stream")
    sound_player.musicSource:setVolume(volume or 1)
    sound_player.musicSource:setLooping(true)
    sound_player.musicSource:play()

    return sound_player.musicSource
end

---Pauses the currently playing music.
function sound_player.pauseMusic()
    if sound_player.musicSource then
        sound_player.musicSource:pause()
    end
end

---Stops the currently playing music.
function sound_player.stopMusic()
    if sound_player.musicSource then
        sound_player.musicSource:stop()
    end
end

return sound_player
