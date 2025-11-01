#!/bin/bash
# Development script to update version in TOC file
# Usage: ./scripts/update-version.sh 3.5.6

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 3.5.6"
    exit 1
fi

VERSION="$1"

# Update version in TOC file
sed -i "s/@project-version@/$VERSION/g" Name2Chat.toc

echo "Updated Name2Chat.toc version to: $VERSION"
echo "Updated line:"
grep "## Version:" Name2Chat.toc

# Verify the change
if grep -q "## Version: $VERSION" Name2Chat.toc; then
    echo "✅ Version successfully updated to $VERSION"
else
    echo "❌ Failed to update version. Current version line:"
    grep "## Version:" Name2Chat.toc
fi