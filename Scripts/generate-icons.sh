#!/usr/bin/env bash
set -euo pipefail

# Generates icon PNGs from AppIcon.icon SVG layers:
# - AboutIcon: all 3 layers composited (background + cards)
# - Pass icons/logos: foreground layers only (transparent background)
# Requires: rsvg-convert (librsvg), magick (ImageMagick)

# Add Homebrew to PATH for Xcode build phases
export PATH="/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

ICON_DIR="$PROJECT_ROOT/kartonche/AppIcon.icon/Assets"

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

# --- AboutIcon (all 3 layers, opaque) ---

ABOUT_OUTPUT_DIR="$PROJECT_ROOT/kartonche/Assets.xcassets/AboutIcon.imageset"
ABOUT_OUTPUT="$ABOUT_OUTPUT_DIR/AboutIcon.png"
ABOUT_SIZE=1024

ABOUT_UP_TO_DATE=false
if [[ -f "$ABOUT_OUTPUT" ]]; then
    newest_input=$(find "$ICON_DIR" -name "*.svg" -newer "$ABOUT_OUTPUT" 2>/dev/null | head -1)
    if [[ -z "$newest_input" ]]; then
        echo "AboutIcon.png is up to date"
        ABOUT_UP_TO_DATE=true
    fi
fi

if [[ "$ABOUT_UP_TO_DATE" == false ]]; then
    echo "Generating AboutIcon.png from SVG layers..."
    rsvg-convert -w "$ABOUT_SIZE" -h "$ABOUT_SIZE" "$ICON_DIR/0_background.svg" -o "$TEMP_DIR/layer0.png"
    rsvg-convert -w "$ABOUT_SIZE" -h "$ABOUT_SIZE" "$ICON_DIR/1_orange_card.svg" -o "$TEMP_DIR/layer1.png"
    rsvg-convert -w "$ABOUT_SIZE" -h "$ABOUT_SIZE" "$ICON_DIR/2_blue_card.svg" -o "$TEMP_DIR/layer2.png"
    magick "$TEMP_DIR/layer0.png" "$TEMP_DIR/layer1.png" -composite "$TEMP_DIR/composite1.png"
    magick "$TEMP_DIR/composite1.png" "$TEMP_DIR/layer2.png" -composite "$ABOUT_OUTPUT"
    echo "Generated: $ABOUT_OUTPUT"
fi

# --- Pass icons and logos (foreground layers only, transparent background) ---

PASS_OUTPUT_DIR="$PROJECT_ROOT/kartonche/Resources/PassAssets"

# Sizes: name prefix, base size (1x)
PASS_ASSETS=(
    "pass-icon:29"
    "pass-logo:50"
)

PASS_UP_TO_DATE=false
if [[ -f "$PASS_OUTPUT_DIR/pass-icon.png" ]]; then
    newest_input=$(find "$ICON_DIR" -name "*.svg" -newer "$PASS_OUTPUT_DIR/pass-icon.png" 2>/dev/null | head -1)
    if [[ -z "$newest_input" ]]; then
        echo "Pass icons are up to date"
        PASS_UP_TO_DATE=true
    fi
fi

if [[ "$PASS_UP_TO_DATE" == false ]]; then
    echo "Generating pass icons from foreground SVG layers..."

    for entry in "${PASS_ASSETS[@]}"; do
        IFS=':' read -r name base_size <<< "$entry"

        for scale in 1 2 3; do
            size=$((base_size * scale))

            rsvg-convert -w "$size" -h "$size" "$ICON_DIR/1_orange_card.svg" -o "$TEMP_DIR/fg1.png"
            rsvg-convert -w "$size" -h "$size" "$ICON_DIR/2_blue_card.svg" -o "$TEMP_DIR/fg2.png"

            magick -size "${size}x${size}" canvas:transparent \
                "$TEMP_DIR/fg1.png" -composite \
                "$TEMP_DIR/fg2.png" -composite \
                "PNG32:$TEMP_DIR/result.png"

            if [[ "$scale" -eq 1 ]]; then
                suffix=""
            else
                suffix="@${scale}x"
            fi
            output_file="$PASS_OUTPUT_DIR/${name}${suffix}.png"
            mv "$TEMP_DIR/result.png" "$output_file"
            echo "Generated: $output_file"
        done
    done
fi
