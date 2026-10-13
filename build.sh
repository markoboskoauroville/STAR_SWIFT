#!/bin/sh
# build.sh: Star (Mantra).app, swiftc straight, no Xcode, signed "Mantra Apps" (MANTRA_MANIFEST mac-app-signing.md),
# installed in /Applications (swift-apps.md). The row table goes to ~/.config/star-rows.json, where the app reads it.
set -e
cd "$(dirname "$0")"
V=$(sed -n 's/^let VERSION = \([0-9]*\)/\1/p' app/main.swift)
APP="build/Star (Mantra).app"
rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -swift-version 5 -target arm64-apple-macosx13.0 -o "$APP/Contents/MacOS/Star" app/*.swift
cat > "$APP/Contents/Info.plist" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Star (Mantra)</string>
<key>CFBundleDisplayName</key><string>Star (Mantra)</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleIdentifier</key><string>community.auroville.star</string>
<key>CFBundleExecutable</key><string>Star</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$V</string>
<key>CFBundleVersion</key><string>$V</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PL
cp icon/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
cp rows.json "$APP/Contents/Resources/rows.json"
codesign --force -s "Mantra Apps" "$APP"
mkdir -p "$HOME/.config"; cp rows.json "$HOME/.config/star-rows.json"
rm -rf "/Applications/Star (Mantra).app"; cp -R "$APP" /Applications/
echo "built $APP (v$V), installed in /Applications, rows in ~/.config/star-rows.json"
