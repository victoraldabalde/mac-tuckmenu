#!/bin/bash
# Builds Tuck.app into ./build. Pass --install to also copy it to ~/Applications.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=build/Tuck.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/Tuck "$APP/Contents/MacOS/Tuck"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Tuck</string>
    <key>CFBundleDisplayName</key><string>Tuck</string>
    <key>CFBundleIdentifier</key><string>local.tuck.menubar</string>
    <key>CFBundleExecutable</key><string>Tuck</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
    mkdir -p "$HOME/Applications"
    rm -rf "$HOME/Applications/Tuck.app"
    cp -R "$APP" "$HOME/Applications/Tuck.app"
    echo "Installed to ~/Applications/Tuck.app"
fi
