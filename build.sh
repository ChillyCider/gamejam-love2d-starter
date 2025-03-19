#!/bin/bash

# Argument check
if [ -z "$1" -o -z "$2" ]; then
    echo "usage 1: $0 run anything-just-padding" >&2
    echo "usage 2: $0 {love|web|win32|win64} dir-or-file-to-produce" >&2
    exit 1
fi
SOURCE_DIR="$(dirname "$0")"
BUILD_TYPE="$1"
OUTPUT_DIR="$2"

# Read conf.lua to find the game's resolution.
# This is used to correctly size the canvas in the web build.
# Scroll down for details.
GAME_WIDTH="$(cat "$SOURCE_DIR/conf.lua" | gawk 'match($0, /\.width\s*=\s*([0-9]+)/, m) { print m[1] }')"
GAME_HEIGHT="$(cat "$SOURCE_DIR/conf.lua" | gawk 'match($0, /\.height\s*=\s*([0-9]+)/, m) { print m[1] }')"
GAME_TITLE="$(cat "$SOURCE_DIR/conf.lua" | gawk 'match($0, /\.title\s*=\s*"([^"]+)"/, m) { print m[1] }')"

echo "Game width detected in conf.lua as $GAME_WIDTH"
echo "Game height detected in conf.lua as $GAME_HEIGHT"
echo "Game title detected in conf.lua as $GAME_TITLE"

# Create a temp directory for our constructed *.love file
folder="$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")"
trap "rm -rf $folder" EXIT

# We will prepare the *.love contents in a staging directory
mkdir "$folder/staging"
cp -r -t "$folder/staging" "$SOURCE_DIR/conf.lua" "$SOURCE_DIR/main.lua"

# Preprocess assets, putting them in the staging folder
IS_DEBUG_BUILD=0
if [ "$BUILD_TYPE" = "run" ]; then
    IS_DEBUG_BUILD=1
fi
bash "$SOURCE_DIR/process_assets.sh" "$folder/staging" "$IS_DEBUG_BUILD"

# Compress the staged files to produce the *.love artifact
(cd "$folder/staging" && zip -q -r "$folder/game.love" *)

# NOW we have a love file.
# It is time to do the secondary step that was specified by the user.
if [ "$BUILD_TYPE" = "run" ]; then
    #############
    #    RUN    #
    #############
    # The user just wants to playtest the game.
    love "$folder/game.love"
elif [ "$BUILD_TYPE" = "love" ]; then
    ##############
    #    LOVE    #
    ##############
    # The user wants the built *.love file.
    cp "$folder/game.love" "$OUTPUT_DIR"
elif [ "$BUILD_TYPE" = "web" ]; then
    #############
    #    WEB    #
    #############
    npx love.js -c "$folder/game.love" -t "$GAME_TITLE" "$OUTPUT_DIR"
    rm -rf "$OUTPUT_DIR/theme"
    cat <<EOF > "$OUTPUT_DIR/index.html"
<!doctype html>
<html lang="en-us">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no, minimum-scale=1, maximum-scale=1">
    <title>$GAME_TITLE</title>

    <style type="text/css">
      html, body { margin: 0; padding: 0; }
      #canvas {
        padding-right: 0;
        display: block;
        border: 0px none;
        visibility: hidden;
      }
    </style>
  </head>
  <body>
    <canvas id="loadingCanvas" oncontextmenu="event.preventDefault()" width="$GAME_WIDTH" height="$GAME_HEIGHT"></canvas>
    <canvas id="canvas" oncontextmenu="event.preventDefault()"></canvas>

    <script type='text/javascript'>
      function goFullScreen(){
            var canvas = document.getElementById("canvas");
            if(canvas.requestFullScreen)
                canvas.requestFullScreen();
            else if(canvas.webkitRequestFullScreen)
                canvas.webkitRequestFullScreen();
            else if(canvas.mozRequestFullScreen)
                canvas.mozRequestFullScreen();
      }
      function FullScreenHook(){
        var canvas = document.getElementById("canvas");
        canvas.width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
        canvas.height = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      }
      var loadingContext = document.getElementById('loadingCanvas').getContext('2d');
      function drawLoadingText(text) {
        var canvas = loadingContext.canvas;

        loadingContext.fillStyle = "rgb(142, 195, 227)";
        loadingContext.fillRect(0, 0, canvas.scrollWidth, canvas.scrollHeight);

        loadingContext.font = '2em arial';
        loadingContext.textAlign = 'center'
        loadingContext.fillStyle = "rgb( 11, 86, 117 )";
        loadingContext.fillText(text, canvas.scrollWidth / 2, canvas.scrollHeight / 2);

        loadingContext.fillText("Powered By Emscripten.", canvas.scrollWidth / 2, canvas.scrollHeight / 4);
        loadingContext.fillText("Powered By LÖVE.", canvas.scrollWidth / 2, canvas.scrollHeight / 4 * 3);
      }

      window.onload = function () { window.focus(); };
      window.onclick = function () { window.focus(); };

      window.addEventListener("keydown", function(e) {
        // space and arrow keys
        if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
          e.preventDefault();
        }
      }, false);

      var Module = {
        arguments: ["./game.love"],
        INITIAL_MEMORY: 16777216,
        printErr: console.error.bind(console),
        canvas: (function() {
          var canvas = document.getElementById('canvas');

          // As a default initial behavior, pop up an alert when webgl context is lost. To make your
          // application robust, you may want to override this behavior before shipping!
          // See http://www.khronos.org/registry/webgl/specs/latest/1.0/#5.15.2
          canvas.addEventListener("webglcontextlost", function(e) { alert('WebGL context lost. You will need to reload the page.'); e.preventDefault(); }, false);

          return canvas;
        })(),
        setStatus: function(text) {
          if (text) {
            drawLoadingText(text);
          } else if (Module.remainingDependencies === 0) {
            document.getElementById('loadingCanvas').style.display = 'none';
            document.getElementById('canvas').style.visibility = 'visible';
          }
        },
        totalDependencies: 0,
        remainingDependencies: 0,
        monitorRunDependencies: function(left) {
          this.remainingDependencies = left;
          this.totalDependencies = Math.max(this.totalDependencies, left);
          Module.setStatus(left ? 'Preparing... (' + (this.totalDependencies-left) + '/' + this.totalDependencies + ')' : 'All downloads complete.');
        }
      };
      Module.setStatus('Downloading...');
      window.onerror = function(event) {
        // TODO: do not warn on ok events like simulating an infinite loop or exitStatus
        Module.setStatus('Exception thrown, see JavaScript console');
        Module.setStatus = function(text) {
          if (text) Module.printErr('[post-exception status] ' + text);
        };
      };

      var applicationLoad = function(e) {
        Love(Module);
      }
    </script>
    <script type="text/javascript" src="game.js"></script>
    <script async type="text/javascript" src="love.js" onload="applicationLoad(this)"></script>
  </body>
</html>
EOF
elif [ "$BUILD_TYPE" = "win64" ]; then
    #############
    #   WIN64   #
    #############
    cp -T -r "$SOURCE_DIR/platform/win64" "$OUTPUT_DIR"
    cat "$SOURCE_DIR/platform/win64/love.exe" "$folder/game.love" > "$OUTPUT_DIR/love.exe"
    mv "$OUTPUT_DIR/love.exe" "$OUTPUT_DIR/$GAME_TITLE.exe"
    echo "$OUTPUT_DIR/$GAME_TITLE.exe produced. Feel free to change the icon with Resource Hacker or something."
elif [ "$BUILD_TYPE" = "win32" ]; then
    #############
    #   WIN32   #
    #############
    cp -T -r "$SOURCE_DIR/platform/win32" "$OUTPUT_DIR"
    cat "$SOURCE_DIR/platform/win32/love.exe" "$folder/game.love" > "$OUTPUT_DIR/love.exe"
    mv "$OUTPUT_DIR/love.exe" "$OUTPUT_DIR/$GAME_TITLE.exe"
    echo "$OUTPUT_DIR/$GAME_TITLE.exe produced. Feel free to change the icon with Resource Hacker or something."
else
    #############
    #  UNKNOWN  #
    #############
    echo "Unknown build type '$BUILD_TYPE'" >&2
    exit 1
fi
