#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

# Update version in script
sed -i "s/Version [0-9.]\+/Version $VERSION/" src/add_dod_certs.sh

# Create release commit
git add src/add_dod_certs.sh
git commit -m "Release version $VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"

# Push changes
git push origin main
git push origin "v$VERSION"
