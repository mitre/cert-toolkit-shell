#!/bin/bash
#
# Convert documentation filenames to consistent case formatting
# Excludes README.md files

set -euo pipefail

# Find and rename files
find ../docs -type f -name '*[A-Z]*' \
    ! -name 'README.md' \
    -exec sh -c '
    for file do
      dir=$(dirname "$file")
      base=$(basename "$file")
      lower=$(echo "$base" | tr "[:upper:]" "[:lower:]")
      if [ "$base" != "$lower" ]; then
        echo "Renaming: $file → $dir/$lower"
        git mv "$file" "$dir/$lower"
      fi
    done
  ' sh {} +

# Commit changes if any files were renamed
if git status --porcelain | grep -q '^R'; then
    git commit -m "docs: standardize documentation filenames to lowercase

- Converted documentation filenames to lowercase
- Maintains consistent naming convention
- Preserves README.md files"
fi
