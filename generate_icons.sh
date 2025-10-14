#!/bin/bash

# Script to generate app icons from zinus_logo.jpeg
# Run this after placing zinus_logo.jpeg in assets/ folder

echo "🎨 Generating app icons from zinus_logo.jpeg..."

# Check if zinus_logo.jpeg exists
if [ ! -f "assets/zinus_logo.jpeg" ]; then
    echo "❌ Error: assets/zinus_logo.jpeg not found!"
    echo "📝 Please place your Zinus logo in assets/zinus_logo.jpeg"
    echo "   Recommended size: 1024x1024 pixels"
    exit 1
fi

echo "✅ Found zinus_logo.jpeg"
echo "📦 Installing flutter_launcher_icons..."

# Install dependencies
flutter pub get

echo "🚀 Generating launcher icons..."

# Generate icons
flutter pub run flutter_launcher_icons

echo "✅ Icons generated successfully!"
echo ""
echo "📱 Generated icons for:"
echo "   - Android (all densities)"
echo "   - iOS (all sizes)"
echo "   - Web (favicon + PWA icons)"
echo "   - macOS"
echo "   - Windows"
echo ""
echo "🎉 Done! You can now build your app with the new Zinus logo."
