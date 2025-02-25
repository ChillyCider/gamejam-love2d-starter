THE R (resources) MODULE
========================

The R module is our central storage for all loaded game assets. Its organization is
very intuitive, so just look at R.lua.

Load all game assets in `R.loadResources`. That function is directly invoked
by love.load.

The biggest exception to this is Tiled maps. Tiled maps can be HUGE, so we only want
to load a Tiled maps that are actually ABOUT TO BE PLAYED. Use the tiled module for
that.
