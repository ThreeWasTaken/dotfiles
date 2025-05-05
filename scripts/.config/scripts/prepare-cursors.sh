#!/bin/bash

# Your source dir
SOURCE_DIR="$HOME/Téléchargements"
TARGET_DIR="$HOME/.icons"

mkdir -p "$TARGET_DIR"

for dir in "$SOURCE_DIR"/*_cursors; do
    [ -d "$dir" ] || continue

    echo "Processing: $(basename "$dir")"
    
    index_file="$dir/index.theme"

    # Create index.theme if missing
    if [ ! -f "$index_file" ]; then
        echo "[Icon Theme]" > "$index_file"
        echo "Name=$(basename "$dir")" >> "$index_file"
        echo "Comment=Auto-generated" >> "$index_file"
    fi

    # Add Inherits=Adwaita if not present
    if ! grep -q "^Inherits=" "$index_file"; then
        echo "Inherits=Adwaita" >> "$index_file"
        echo "→ Added Inherits=Adwaita"
    fi

    # Copy to ~/.icons/
    cp -r "$dir" "$TARGET_DIR/"
    echo "→ Copied to $TARGET_DIR"
    echo ""
done

echo "✅ All cursor themes processed!"
