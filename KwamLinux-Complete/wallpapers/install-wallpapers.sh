#!/bin/bash
# Install Kwamlinux wallpapers
set -e
OUT="$(dirname "$0")/output"
DEST="/usr/share/wallpapers/kwamlinux"
sudo mkdir -p "$DEST"
for svg in "$OUT"/*.svg; do
    name=$(basename "$svg" .svg)
    sudo cp "$svg" "$DEST/$name.svg"
    echo "  ✔ Installed $name"
done
# Set default wallpaper via plasma
plasma-apply-wallpaperimage "$DEST/kwamlinux-deep-space.svg" 2>/dev/null || true
echo "Wallpapers installed!"
