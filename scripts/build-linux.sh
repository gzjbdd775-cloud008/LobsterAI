#!/usr/bin/env bash
set -euo pipefail

# LobsterAI Linux Builder
# ========================
# Builds .AppImage and .deb packages for Linux x64.
#
# Prerequisites:
#   - Node.js >= 24 (https://nodejs.org)
#   - git
#   - build-essential / base-devel
#
# Required libraries for Electron:
#   Debian/Ubuntu:
#     sudo apt install -y \
#       libgtk-3-dev libnss3-dev libasound2-dev \
#       libxss-dev libxtst-dev libdrm-dev libgbm-dev \
#       libnotify-dev libsecret-1-dev \
#       dpkg-dev rpm fakeroot
#
#   Fedora/RHEL:
#     sudo dnf install -y \
#       gtk3-devel nss-devel alsa-lib-devel \
#       libXScrnSaver-devel libXtst-devel libdrm-devel \
#       mesa-libgbm-devel libnotify-devel libsecret-devel \
#       dpkg-dev rpm-build
#
# Output: release/ directory containing:
#   - LobsterAI-*.AppImage
#   - lobsterai_*.deb

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== LobsterAI Linux Builder ==="
echo "Project: $PROJECT_DIR"
echo ""

cd "$PROJECT_DIR"

# Step 1: Install dependencies
echo "[1/6] Installing npm dependencies..."
npm install

# Step 2: Build skills
echo "[2/6] Building skills..."
npm run build:skills

# Step 3: Build frontend + Electron
echo "[3/6] Building frontend and Electron main process..."
npm run build
npm run compile:electron

# Step 4: Build OpenClaw runtime for Linux x64
echo "[4/6] Building OpenClaw runtime (Linux x64)..."
npm run openclaw:runtime:linux-x64

# Step 5: Package Linux targets
echo "[5/6] Packaging... (this may take a while)"
npm run dist:linux

# Step 6: Show results
echo ""
echo "=== Build Complete ==="
ls -lh "$PROJECT_DIR/release/" 2>/dev/null || echo "No output found in release/"

echo ""
echo "Install the .deb on Debian/Ubuntu:"
echo "  sudo dpkg -i release/*.deb"
echo "  sudo apt install -f"
echo ""
echo "Or run the .AppImage directly:"
echo "  chmod +x release/*.AppImage"
echo "  ./release/*.AppImage"
