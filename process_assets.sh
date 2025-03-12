#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="$1"
DEBUG_BUILD="$2"
if [ -z "$OUTPUT_DIR" -o -z "$DEBUG_BUILD" ]; then
    echo "usage: $0 output_dir debug_build" >&2
    exit 1
fi

echo "Running tasks..." >&2


# for example, converting Tiled maps into Lua files
find "$SCRIPT_DIR/assets" -type f -printf "%P\n" | while read ASSET; do
    case "$ASSET" in
        #######################################
        # GAME SPECIFIC ASSET STUFF GOES HERE #
        #######################################
        *.tmx)
            TMX_LUA_PATH="$(basename "$ASSET" .tmx).lua"
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/assets/$TMX_LUA_PATH")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi

            echo -n "TILED assets/$ASSET " >&2
            tiled -e "$SCRIPT_DIR/tools/tiled_to_lua.js" "$SCRIPT_DIR/assets/$ASSET" "$OUTPUT_DIR/assets/$TMX_LUA_PATH"
            if [ "$?" = 0 ]; then
                echo "[ok]"
            else
                echo "[fail]"
            fi
        ;;

        ###################################
        # COMMON ASSET STUFF FOR ANY GAME #
        ###################################
        *.png)
            # Ensure the output folder exists
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/assets/$ASSET")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi

            if [ "$DEBUG_BUILD" != 1 ]; then # release builds only
                # Perform the compression
                echo -n "PNGCRUSH assets/$ASSET " >&2
                pngcrush -q "$SCRIPT_DIR/assets/$ASSET" "$OUTPUT_DIR/assets/$ASSET" 2>/dev/null
            else
                echo -n "COPY assets/$ASSET " >&2
                cp -t "$OUTPUT_SUB_DIR" "$SCRIPT_DIR/assets/$ASSET"
            fi

            # Report success or failure
            if [ "$?" = 0 ]; then
                echo "[ok]"
            else
                echo "[fail]"
            fi
        ;;

        *)
            # Copy anything that wasn't considered above
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/assets/$ASSET")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi
            
            echo -n "COPY assets/$ASSET " >&2
            cp -t "$OUTPUT_SUB_DIR" "$SCRIPT_DIR/assets/$ASSET"
            if [ "$?" = 0 ]; then
                echo "[ok]"
            else
                echo "[fail]"
            fi
        ;;
    esac
done
