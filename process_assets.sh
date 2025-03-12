#!/bin/bash

SCRIPT_DIR="$(basename "$0")"
OUTPUT_DIR="$1"
DEBUG_BUILD="$2"
if [ -z "$OUTPUT_DIR" -o -z "$DEBUG_BUILD" ]; then
    echo "usage: $0 output_dir debug_build" >&2
    exit 1
fi

#######################################
# GAME SPECIFIC ASSET STUFF GOES HERE #
#######################################

###################################
# COMMON ASSET STUFF FOR ANY GAME #
###################################

# PNG compression
if [ "$DEBUG_BUILD" != 1 ]; then # release builds only
    find "$SCRIPT_DIR/assets" -type f -name '*.png' -printf "%P\n" | while read PNG_PATH; do
        pngcrush "$SCRIPT_DIR/assets/$PNG_PATH" "$OUTPUT_DIR/assets/$PNG_PATH"
    done
fi

# TODO: JPEG compression
