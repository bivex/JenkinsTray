#!/bin/bash

# Build the app
echo "Building JenkinsTray..."
swift build

# Create app bundle structure
echo "Creating app bundle..."
rm -rf JenkinsTray.app
mkdir -p JenkinsTray.app/Contents/MacOS
mkdir -p JenkinsTray.app/Contents/Resources

# Copy executable
echo "Copying executable..."
cp .build/arm64-apple-macosx/debug/JenkinsTray JenkinsTray.app/Contents/MacOS/

# Create Info.plist
echo "Creating Info.plist..."
cat > JenkinsTray.app/Contents/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.bivex.jenkinstray</string>
    <key>CFBundleName</key>
    <string>JenkinsTray</string>
    <key>CFBundleDisplayName</key>
    <string>Jenkins Tray</string>
    <key>CFBundleExecutable</key>
    <string>JenkinsTray</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2026 Bivex</string>
</dict>
</plist>
PLIST

echo "✅ App bundle created: JenkinsTray.app"
echo ""
echo "To run with notifications:"
echo "  open JenkinsTray.app"
echo ""
echo "To install to Applications:"
echo "  cp -r JenkinsTray.app /Applications/"
