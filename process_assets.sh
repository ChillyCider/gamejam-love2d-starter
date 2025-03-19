#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="$1"
DEBUG_BUILD="$2"
if [ -z "$OUTPUT_DIR" -o -z "$DEBUG_BUILD" ]; then
    echo "usage: $0 output_dir debug_build" >&2
    exit 1
fi

echo "Running tasks..." >&2

find "$SCRIPT_DIR" -type f \( -path "$SCRIPT_DIR/src"/'*' -o -path "$SCRIPT_DIR/assets"/'*' \) -printf "%P\n" | while read ASSET; do
    case "$ASSET" in
        #######################################
        # GAME SPECIFIC ASSET STUFF GOES HERE #
        #######################################
        *.tmx)
            TMX_LUA_PATH="$(basename "$ASSET" .tmx).lua"
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/$ASSET")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi

            echo -n "TILED $ASSET " >&2
            tiled -e "$SCRIPT_DIR/tools/tiled_to_lua.js" "$SCRIPT_DIR/$ASSET" "$OUTPUT_SUB_DIR/$TMX_LUA_PATH"
            if [ "$?" = 0 ]; then
                echo "[ok]"
            else
                echo "[fail]"
            fi
        ;;

        ###################################
        # COMMON ASSET STUFF FOR ANY GAME #
        ###################################
        *.lua)
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/$ASSET")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi

            if [ "$DEBUG_BUILD" != 1 ]; then # release builds only
                echo -n "STRIP-ANNOTATIONS $ASSET " >&2
                sed \
                    -e '/^\s*---@/d' \
                    -e 's/\s*---@.*$//' \
                    "$SCRIPT_DIR/$ASSET" | \
                    awk '!NF {if (++n < 2) print; next}; {n=0;print}' > "$OUTPUT_DIR/$ASSET"
            else
                echo -n "COPY $ASSET " >&2
                cp -t "$OUTPUT_SUB_DIR" "$SCRIPT_DIR/$ASSET"
            fi

            if [ "$?" = 0 ]; then
                echo "[ok]"
            else
                echo "[fail"]
            fi
        ;;

        *.png)
            # Ensure the output folder exists
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/$ASSET")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi

            if [ "$DEBUG_BUILD" != 1 ]; then # release builds only
                # Perform the compression
                echo -n "PNGCRUSH $ASSET " >&2
                pngcrush -q "$SCRIPT_DIR/$ASSET" "$OUTPUT_DIR/$ASSET" 2>/dev/null
            else
                echo -n "COPY $ASSET " >&2
                cp -t "$OUTPUT_SUB_DIR" "$SCRIPT_DIR/$ASSET"
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
            OUTPUT_SUB_DIR="$(dirname "$OUTPUT_DIR/$ASSET")"
            if [ ! -d "$OUTPUT_SUB_DIR" ]; then
                mkdir -p "$OUTPUT_SUB_DIR"
            fi
            
            echo -n "COPY $ASSET " >&2
            cp -t "$OUTPUT_SUB_DIR" "$SCRIPT_DIR/$ASSET"
            if [ "$?" = 0 ]; then
                echo "[ok]"
            else
                echo "[fail]"
            fi
        ;;
    esac
done
