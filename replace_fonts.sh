#!/bin/bash

# Universal script to replace font-family in CSS files (Linux tested)
# Usage: ./replace.sh [project_path]

# Project path, defaults to the current directory
PROJECT_PATH="${1:-.}"

# Array of font names to replace
FONTS=("Montserrat" "Manrope") # Add more fonts here if needed

# Loop through each font in the array
for FONT in "${FONTS[@]}"; do
    echo "Replacing font-family for: $FONT"

    # Replace font-family with double quotes
    find "$PROJECT_PATH" -type f -name '*.css' -exec sed -i "s/font-family: \"$FONT\", sans-serif;/font-family: var(--font-${FONT,,}), sans-serif;/g" {} +

    # Replace font-family with single quotes
    find "$PROJECT_PATH" -type f -name '*.css' -exec sed -i "s/font-family: '$FONT', sans-serif;/font-family: var(--font-${FONT,,}), sans-serif;/g" {} +
done

echo "Replacement completed!"
