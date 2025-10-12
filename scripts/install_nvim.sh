#!/bin/bash

INSTALL_DIR="$HOME/.local/bin/"
TEMP_FILE="/tmp/nvim.appimage"

echo "Downloading Nvim AppImage..."
if curl -sL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage -o "$TEMP_FILE"; then
    echo "Download completed."
else
    echo "Error: Failed to download Nvim AppImage." >&2
    exit 1
fi

chmod u+x "$TEMP_FILE"

mkdir -p "$INSTALL_DIR"
mv "$TEMP_FILE" "$INSTALL_DIR/nvim"

echo "Neovim installation completed!"
