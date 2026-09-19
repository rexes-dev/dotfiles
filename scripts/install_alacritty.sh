#!/bin/bash
#
# Builds Alacritty from source on Ubuntu or macOS.
# Set VERSION to build a release other than the default.

set -euo pipefail
trap 'echo "Error: install failed (line $LINENO)." >&2' ERR

VERSION="${VERSION:-0.17.0}"
INSTALL_DIR="$HOME/.local/bin"
TEMP_FILE="/tmp/alacritty-$VERSION.tar.gz"
SRC_DIR="/tmp/alacritty-$VERSION"

case "$(uname -s)" in
    Linux)  OS="ubuntu" ;;
    Darwin) OS="macos" ;;
    *)
        echo "Error: unsupported platform $(uname -s)." >&2
        exit 1
        ;;
esac

echo "Installing build dependencies..."
if [ "$OS" = "ubuntu" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cmake g++ pkg-config \
        libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
else
    if ! xcode-select -p > /dev/null 2>&1; then
        echo "Error: run 'xcode-select --install' first." >&2
        exit 1
    fi
    # scdoc renders the man pages bundled into Alacritty.app.
    command -v scdoc > /dev/null || brew install scdoc
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
if command -v rustup > /dev/null; then
    rustup update stable
else
    echo "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
fi

echo "Downloading Alacritty $VERSION source..."
curl -fsSL "https://github.com/alacritty/alacritty/archive/refs/tags/v$VERSION.tar.gz" -o "$TEMP_FILE"
rm -rf "$SRC_DIR"
tar -xzf "$TEMP_FILE" -C /tmp
cd "$SRC_DIR"

echo "Building Alacritty (this takes a few minutes)..."
if [ "$OS" = "macos" ]; then
    make app
else
    cargo build --release
fi

mkdir -p "$INSTALL_DIR"
install -m 755 target/release/alacritty "$INSTALL_DIR/alacritty"
tic -xe alacritty,alacritty-direct -o "$HOME/.terminfo" extra/alacritty.info

if [ "$OS" = "macos" ]; then
    mkdir -p "$HOME/Applications"
    rm -rf "$HOME/Applications/Alacritty.app"
    cp -R target/release/osx/Alacritty.app "$HOME/Applications/"
else
    ICONS="$HOME/.local/share/icons/hicolor/scalable/apps"
    mkdir -p "$HOME/.local/share/applications" "$ICONS"
    cp extra/linux/Alacritty.desktop "$HOME/.local/share/applications/"
    cp extra/logo/alacritty-term.svg "$ICONS/Alacritty.svg"
fi

cd /tmp
rm -rf "$TEMP_FILE" "$SRC_DIR"

echo "Alacritty $VERSION installed to $INSTALL_DIR/alacritty"
case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *) echo "Note: $INSTALL_DIR is not on your PATH." ;;
esac
echo "Run 'stow -t ~ alacritty' from the repo root to link the config."
