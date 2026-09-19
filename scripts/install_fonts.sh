#!/bin/bash
#
# Installs every font referenced by these dotfiles, on Ubuntu or macOS.
#
#   FiraCode Nerd Font  alacritty     (the Nerd Font build, not upstream Fira
#                                      Code: alacritty.toml asks for the family
#                                      "FiraCode Nerd Font Mono")
#   Source Code Pro     i3, VS Code, gnome-terminal

set -euo pipefail
trap 'echo "Error: install failed (line $LINENO)." >&2' ERR

NERD_VERSION="${NERD_VERSION:-3.5.1}"
SCP_RELEASE="2.042R-u/1.062R-i/1.026R-vf"

# name|url
FONTS=(
    "FiraCode Nerd Font|https://github.com/ryanoasis/nerd-fonts/releases/download/v$NERD_VERSION/FiraCode.zip"
    "Source Code Pro|https://github.com/adobe-fonts/source-code-pro/releases/download/$SCP_RELEASE/TTF-source-code-pro-2.042R-u_1.062R-i.zip"
)

if ! command -v unzip > /dev/null; then
    echo "Error: unzip is required (apt-get install unzip / brew install unzip)." >&2
    exit 1
fi

if [ "$(uname -s)" = "Darwin" ]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi
mkdir -p "$FONT_DIR"

for entry in "${FONTS[@]}"; do
    name="${entry%%|*}"
    url="${entry#*|}"
    tmp="$(mktemp -d)"

    echo "Downloading $name..."
    curl -fsSL "$url" -o "$tmp/font.zip"
    unzip -q "$tmp/font.zip" -d "$tmp/extracted"
    find "$tmp/extracted" -name '*.ttf' -exec cp {} "$FONT_DIR/" \;

    rm -rf "$tmp"
    echo "$name installed."
done

# fontconfig is Linux-only; macOS indexes ~/Library/Fonts by itself.
if command -v fc-cache > /dev/null; then
    fc-cache -f > /dev/null
fi

echo "Fonts installed to $FONT_DIR"
