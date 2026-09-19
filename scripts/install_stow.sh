#!/bin/bash
#
# Builds GNU Stow from source into $HOME/.local, so no sudo is needed.
# Set VERSION to build a release other than the default.

set -euo pipefail
trap 'echo "Error: install failed (line $LINENO)." >&2' ERR

VERSION="${VERSION:-2.4.1}"
PREFIX="$HOME/.local"
TEMP_FILE="/tmp/stow-$VERSION.tar.gz"
SRC_DIR="/tmp/stow-$VERSION"

case "$(uname -s)" in
    Linux)  OS="ubuntu" ;;
    Darwin) OS="macos" ;;
    *)
        echo "Error: unsupported platform $(uname -s)." >&2
        exit 1
        ;;
esac

# Stow is pure Perl; it only needs perl and make to build. Test::Output is
# used solely by the test suite, but configure warns loudly without it.
if [ "$OS" = "ubuntu" ]; then
    echo "Installing build dependencies..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y perl make libtest-output-perl
elif ! xcode-select -p > /dev/null 2>&1; then
    echo "Error: run 'xcode-select --install' first." >&2
    exit 1
fi

echo "Downloading Stow $VERSION source..."
curl -fsSL "https://ftp.gnu.org/gnu/stow/stow-$VERSION.tar.gz" -o "$TEMP_FILE"
rm -rf "$SRC_DIR"
tar -xzf "$TEMP_FILE" -C /tmp
cd "$SRC_DIR"

# On macOS configure may warn that Test::Output is missing; it is test-only,
# so the install is unaffected.
echo "Building Stow..."
./configure --prefix="$PREFIX" > /dev/null
make install > /dev/null

cd /tmp
rm -rf "$TEMP_FILE" "$SRC_DIR"

echo "Stow $VERSION installed to $PREFIX/bin/stow"
case ":$PATH:" in
    *":$PREFIX/bin:"*) ;;
    *) echo "Note: $PREFIX/bin is not on your PATH." ;;
esac
