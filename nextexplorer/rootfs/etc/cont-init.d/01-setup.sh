#!/usr/bin/with-contenv bash
set -e

V_ROOT="${VOLUME_ROOT:-/storage}"
OPTIONS_FILE="/data/options.json"

mkdir -p "$V_ROOT"

if jq -e '.root_volumes and (.root_volumes | length > 0)' "$OPTIONS_FILE" > /dev/null; then
    for vol in $(jq -r '.root_volumes[]' "$OPTIONS_FILE"); do
        case "$vol" in
            homeassistant_config)
                SOURCE_PATH="/homeassistant"
                TARGET_NAME="homeassistant_config"
                ;;
            share)
                SOURCE_PATH="/share"
                TARGET_NAME="shared"
                ;;
            media)
                SOURCE_PATH="/media"
                TARGET_NAME="media"
                ;;
            backup)
                SOURCE_PATH="/backup"
                TARGET_NAME="backup"
                ;;
            *)
                echo "WARNING: unsupported root volume requested: $vol"
                continue
                ;;
        esac

        TARGET_PATH="$V_ROOT/$TARGET_NAME"
        echo "$SOURCE_PATH -> $TARGET_PATH"

        if [ -L "$TARGET_PATH" ]; then
            rm -f "$TARGET_PATH"
        elif [ -e "$TARGET_PATH" ]; then
            echo "ERROR: refusing to replace non-symlink path: $TARGET_PATH"
            continue
        fi

        if [ -d "$SOURCE_PATH" ]; then
            ln -s "$SOURCE_PATH" "$TARGET_PATH"
        else
            echo "WARNING: source volume does not exist: $SOURCE_PATH"
        fi
    done
else
    echo "No root_volumes defined for setup"
fi

mkdir -p "${CONFIG_DIR:-/config}/extensions/icons" \
         "${CONFIG_DIR:-/config}/extensions/brand" \
         "${CACHE_DIR:-/cache}/thumbnails"

echo "Next Explorer Setup complete."
