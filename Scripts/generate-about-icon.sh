#!/usr/bin/env bash
set -euo pipefail

# Composites AppIcon.icon SVG layers into a PNG for the About screen.
# Requires: rsvg-convert (librsvg), magick (ImageMagick)

# Add Homebrew to PATH for Xcode build phases
export PATH="/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

ICON_DIR="$PROJECT_ROOT/kartonche/AppIcon.icon/Assets"
OUTPUT_DIR="$PROJECT_ROOT/kartonche/Assets.xcassets/AboutIcon.imageset"
OUTPUT="$OUTPUT_DIR/AboutIcon.png"
SIZE=1024

# Skip if output already exists and is newer than all inputs
if [[ -f "$OUTPUT" ]]; then
    newest_input=$(find "$ICON_DIR" -name "*.svg" -newer "$OUTPUT" 2>/dev/null | head -1)
    if [[ -z "$newest_input" ]]; then
        echo "AboutIcon.png is up to date"
        exit 0
    fi
fi

# Check for required tools
if ! command -v rsvg-convert &>/dev/null; then
    echo "Error: rsvg-convert not found. Install with: brew install librsvg" >&2
    exit 1
fi

if ! command -v magick &>/dev/null; then
    echo "Error: magick not found. Install with: brew install imagemagick" >&2
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Generating AboutIcon.png from SVG layers..."

# Convert each layer to PNG
rsvg-convert -w "$SIZE" -h "$SIZE" "$ICON_DIR/0_background.svg" -o "$TEMP_DIR/layer0.png"
rsvg-convert -w "$SIZE" -h "$SIZE" "$ICON_DIR/1_orange_card.svg" -o "$TEMP_DIR/layer1.png"
rsvg-convert -w "$SIZE" -h "$SIZE" "$ICON_DIR/2_blue_card.svg" -o "$TEMP_DIR/layer2.png"

# Composite layers
magick "$TEMP_DIR/layer0.png" "$TEMP_DIR/layer1.png" -composite "$TEMP_DIR/composite1.png"
magick "$TEMP_DIR/composite1.png" "$TEMP_DIR/layer2.png" -composite "$OUTPUT"

echo "Generated: $OUTPUT"
