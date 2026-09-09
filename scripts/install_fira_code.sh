#!/bin/bash

VERSION="6.2"
TEMP_FILE="/tmp/fira-code.zip"
TEMP_DIR="/tmp/fira-code/"

if [ "$(uname)" = "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi

# Download fonts from GitHub
echo "Downloading Fira Code $VERSION font from GitHub"
if curl -sL "https://github.com/tonsky/FiraCode/releases/download/$VERSION/Fira_Code_v$VERSION.zip" -o "$TEMP_FILE"; then
    echo "Download completed."
else
    echo "Error: Failed to download the font." >&2
    exit 1
fi

mkdir -p "$FONT_DIR"

unzip -o "$TEMP_FILE" -d "$TEMP_DIR" > /dev/null

# ttf/ holds the static weights; variable_ttf/ and woff*/ are not wanted
find "$TEMP_DIR/ttf" -name '*.ttf' -exec mv {} "$FONT_DIR/" \;

# fontconfig is Linux-only; macOS indexes ~/Library/Fonts by itself
command -v fc-cache > /dev/null && fc-cache -f > /dev/null

rm -rf "$TEMP_FILE" "$TEMP_DIR"

echo "Fira Code installed to $FONT_DIR"
