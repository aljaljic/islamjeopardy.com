#!/bin/bash

set -e

echo "=== CI Post Clone Script ==="

# Navigate to the repository root
cd "$CI_PRIMARY_REPOSITORY_PATH"

echo "Current directory: $(pwd)"

# Install Node.js using Homebrew
echo "Installing Node.js..."
brew install node

# Install pnpm
echo "Installing pnpm..."
npm install -g pnpm

# Install dependencies
echo "Installing dependencies..."
pnpm install

# Build the web app for iOS
echo "Building web app..."
pnpm run build:ios

# Sync Capacitor to copy web assets and update native project
echo "Syncing Capacitor..."
npx cap sync ios

# Fix Package.swift paths - replace pnpm internal paths with resolved symlinks
echo "Fixing Package.swift paths for Xcode Cloud..."
PACKAGE_SWIFT="$CI_PRIMARY_REPOSITORY_PATH/ios/App/CapApp-SPM/Package.swift"
if [ -f "$PACKAGE_SWIFT" ]; then
    # Replace pnpm's .pnpm paths with the standard node_modules paths
    sed -i '' 's|node_modules/.pnpm/@capacitor+network@[^/]*/node_modules/@capacitor/network|node_modules/@capacitor/network|g' "$PACKAGE_SWIFT"
    echo "Package.swift paths updated"
    cat "$PACKAGE_SWIFT"
fi

echo "=== CI Post Clone Complete ==="
