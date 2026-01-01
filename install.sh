#!/bin/bash

set -e

echo "🔨 Building JenkinsTray (Release)..."
swift build -c release

echo ""
echo "📦 Creating app bundle..."

# Clean up old bundle
rm -rf JenkinsTray.app

# Create bundle structure
mkdir -p JenkinsTray.app/Contents/MacOS
mkdir -p JenkinsTray.app/Contents/Resources

# Copy executable
cp .build/release/JenkinsTray JenkinsTray.app/Contents/MacOS/

# Create Info.plist
cat > JenkinsTray.app/Contents/Info.plist << 'EOF'
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
EOF

echo "✅ App bundle created: JenkinsTray.app"
echo ""

# Install to Applications
echo "📲 Installing to /Applications/..."
sudo rm -rf /Applications/JenkinsTray.app
sudo cp -r JenkinsTray.app /Applications/

echo "✅ Installed to /Applications/JenkinsTray.app"
echo ""

# Create LaunchAgent plist for autorun
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/com.bivex.jenkinstray.plist"

echo "🚀 Setting up autorun..."
mkdir -p "$LAUNCH_AGENT_DIR"

cat > "$LAUNCH_AGENT_PLIST" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.bivex.jenkinstray</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Applications/JenkinsTray.app/Contents/MacOS/JenkinsTray</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>/tmp/jenkinstray.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/jenkinstray.err.log</string>
</dict>
</plist>
EOF

# Unload if already loaded
launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true

# Load LaunchAgent
launchctl load "$LAUNCH_AGENT_PLIST"

echo "✅ Autorun configured: $LAUNCH_AGENT_PLIST"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Installation complete!"
echo ""
echo "JenkinsTray has been installed to /Applications/"
echo "and configured to start automatically at login."
echo ""
echo "To start now:"
echo "  open /Applications/JenkinsTray.app"
echo ""
echo "To remove from autorun:"
echo "  launchctl unload ~/Library/LaunchAgents/com.bivex.jenkinstray.plist"
echo "  rm ~/Library/LaunchAgents/com.bivex.jenkinstray.plist"
echo ""
echo "To uninstall:"
echo "  sudo rm -rf /Applications/JenkinsTray.app"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
