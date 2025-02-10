#!/bin/bash

if [ "x$1" = "x" -o "x$2" = "x" ]; then
    echo "usage: $0 {web|win64} dir-to-produce" >&2
    exit 1
fi

BUILD_TYPE="$1"
OUTPUT_DIR="$2"

GAME_WIDTH="$(cat conf.lua | gawk 'match($0, /\.width\s*=\s*([0-9]+)/, m) { print m[1] }')"
GAME_HEIGHT="$(cat conf.lua | gawk 'match($0, /\.height\s*=\s*([0-9]+)/, m) { print m[1] }')"
GAME_TITLE="$(cat conf.lua | gawk 'match($0, /\.title\s*=\s*"([^"]+)"/, m) { print m[1] }')"

echo "Game width detected in conf.lua as $GAME_WIDTH"
echo "Game height detected in conf.lua as $GAME_HEIGHT"
echo "Game title detected in conf.lua as $GAME_TITLE"

folder="$(mktemp -d "${TMPDIR:-/tmp/}$(basename $0).XXXXXXXXXXXX")"
trap "rm -rf $folder" EXIT

zip -q -r "$folder/game.love" assets/ hump/ states/ support/ main.lua

if [ "x$BUILD_TYPE" = "xweb" ]; then
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
elif [ "x$BUILD_TYPE" = "xwin64" ]; then
    cp -T -r "platform/win64" "$OUTPUT_DIR"
    cat "platform/win64/love.exe" "$folder/game.love" > "$OUTPUT_DIR/love.exe"
    mv "$OUTPUT_DIR/love.exe" "$OUTPUT_DIR/$GAME_TITLE.exe"
else
    echo "Unknown build type '$BUILD_TYPE'" >&2
    exit 1
fi
