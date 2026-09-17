#!/bin/bash

VERSION="0.74.4"
INSTALL_DIR="$HOME/.local/bin"
TEMP_FILE="/tmp/fzf.tar.gz"

case "$(uname -s)-$(uname -m)" in
    Linux-x86_64)  ARCHIVE="fzf-$VERSION-linux_amd64.tar.gz" ;;
    Linux-aarch64) ARCHIVE="fzf-$VERSION-linux_arm64.tar.gz" ;;
    Darwin-x86_64) ARCHIVE="fzf-$VERSION-darwin_amd64.tar.gz" ;;
    Darwin-arm64)  ARCHIVE="fzf-$VERSION-darwin_arm64.tar.gz" ;;
    *)
        echo "Error: unsupported platform $(uname -s)-$(uname -m)." >&2
        exit 1
        ;;
esac

echo "Downloading fzf $VERSION from GitHub..."
if curl -sL "https://github.com/junegunn/fzf/releases/download/v$VERSION/$ARCHIVE" -o "$TEMP_FILE"; then
    echo "Download completed."
else
    echo "Error: Failed to download fzf." >&2
    exit 1
fi

mkdir -p "$INSTALL_DIR"
tar -xzf "$TEMP_FILE" -C "$INSTALL_DIR" fzf
chmod u+x "$INSTALL_DIR/fzf"

rm -f "$TEMP_FILE"

echo "fzf installed to $INSTALL_DIR/fzf"
