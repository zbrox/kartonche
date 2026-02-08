#!/usr/bin/env bash
set -euo pipefail

# Generates MerchantTemplates.swift from Merchants/merchants.kdl at build time.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

MERCHANTS_FILE="$PROJECT_ROOT/Merchants/merchants.kdl"
OUTPUT_FILE="$PROJECT_ROOT/kartonche/Generated/MerchantTemplates.swift"

# Create Generated directory if missing
mkdir -p "$PROJECT_ROOT/kartonche/Generated"

# Skip if output already exists and is newer than input
if [[ -f "$OUTPUT_FILE" && "$OUTPUT_FILE" -nt "$MERCHANTS_FILE" ]]; then
    echo "MerchantTemplates.swift is up to date"
    exit 0
fi

echo "Generating merchant templates from $MERCHANTS_FILE..."
swift run --package-path "$PROJECT_ROOT/Scripts/generate-merchants" generate-merchants \
    --input "$MERCHANTS_FILE" \
    --output "$OUTPUT_FILE"

echo "Generated: $OUTPUT_FILE"
