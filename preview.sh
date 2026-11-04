#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

export QML_XHR_ALLOW_FILE_READ=1

echo "=================================================="
echo "       Previewing Caelestia SDDM Theme"
echo "=================================================="
echo "Theme directory: $SCRIPT_DIR"
echo "Note: Close the window or press Ctrl+C to exit."
echo ""

if command -v sddm-greeter-qt6 &> /dev/null; then
    exec sddm-greeter-qt6 --test-mode --theme "$SCRIPT_DIR"
elif command -v sddm-greeter &> /dev/null; then
    exec sddm-greeter --test-mode --theme "$SCRIPT_DIR"
else
    echo "Error: Neither sddm-greeter-qt6 nor sddm-greeter found."
    echo "Please ensure SDDM is installed."
    exit 1
fi
