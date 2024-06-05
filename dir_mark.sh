#!/bin/bash

echo "# mark List" > marker.md

for dir in $(find . -maxdepth 1 -type d -not -path '*/\.*' | sed 's|^./||' | sort); do
    if [ "$dir" != "." ] && [ "$dir" != ".." ]; then
        echo "-[ ] [$dir](.$dir)" >> marker.md
    fi
done

echo "Generated marker.md file with directory list."
