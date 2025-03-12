#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
OUTPUT_DIR="$1"
DEBUG_BUILD="$2"
if [ -z "$OUTPUT_DIR" -o -z "$DEBUG_BUILD" ]; then
    echo "usage: $0 output_dir debug_build" >&2
    exit 1
fi

echo "Running tasks..." >&2

#######################################
# GAME SPECIFIC ASSET STUFF GOES HERE #
#######################################

# for example, converting Tiled maps into Lua files
# ...

###################################
# COMMON ASSET STUFF FOR ANY GAME #
###################################

# PNG compression
if [ "$DEBUG_BUILD" != 1 ]; then # release builds only
    find "$SCRIPT_DIR/assets" -type f -name '*.png' -printf "%P\n" | while read PNG_PATH; do
        # Ensure the output folder exists
        FILE_DIR="$(dirname "$OUTPUT_DIR/assets/$PNG_PATH")"
        if [ ! -d "$FILE_DIR" ]; then
            mkdir -p "$FILE_DIR"
        fi

        # Perform the compression
        echo -n "PNGCRUSH assets/$PNG_PATH" >&2
        pngcrush -q "$SCRIPT_DIR/assets/$PNG_PATH" "$OUTPUT_DIR/assets/$PNG_PATH" 2>/dev/null

        # Report success or failure
        if [ "$?" = 0 ]; then
            echo " [ok]"
        else
            echo " [fail]"
        fi
    done
fi

# TODO: JPEG compression
