THE SOUND PLAYER MODULE
=======================

This is how you should play sound effects and music. It takes care of a few things
for you:

- Audio sources are reclaimed and recycled after they finish playing.
- As long as you use sound_player.play() and sound_player.update(), you won't blast
  the speakers by accidentally playing the same sound twice on different sources on
  the same frame. sound_player.play() only lets one instance of a sound start per
  frame. You can circumvent that with sound_player.playDirect().
- Music is controlled separately, and uses streamed audio sources.

SOUND EFFECT EXAMPLE
--------------------

```lua
function love.load()
    R.load_resources()

    -- creates an initial love.Source for each sound in R.sounds
    -- (optional)
    sound_player.init()
end

function love.update()
    -- processes all play requests
    sound_player.update()
end

function love.keypressed(key)
    if key == "g" then
        sound_player.play(R.sounds.announcer_saying_go, 1.0)
    end
end
```

MUSIC TUTORIAL
--------------

```lua
function love.load()
    R.load_resources()
    sound_player.play_music(R.music.foo)
end
```
