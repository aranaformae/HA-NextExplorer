#!/usr/bin/with-contenv bash
V_ROOT="${VOLUME_ROOT:-/storage}"
OPTIONS_FILE="/data/options.json"

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
            root)
                SOURCE_PATH="/"
                TARGET_NAME="root"
                ;;
            *)
                SOURCE_PATH="/$vol"
                TARGET_NAME="$vol"
                ;;
        esac

        TARGET_PATH="$V_ROOT/$TARGET_NAME"
        echo "$SOURCE_PATH -> $TARGET_PATH"

        if [ -d "$SOURCE_PATH" ]; then
            mkdir -p "$TARGET_PATH"
            if ! mountpoint -q "$TARGET_PATH"; then
                mount --bind "$SOURCE_PATH" "$TARGET_PATH"
            fi
        else
            echo "WARNING: source volume does not exist: $SOURCE_PATH"
        fi
    done
else
    echo "No root_volumes defined for setup"
fi

mkdir -p "${CONFIG_DIR:-/config}/extensions/icons" "${CONFIG_DIR:-/config}/extensions/brand" "${CACHE_DIR:-/cache}/thumbnails"
echo "Next Explorer Setup complete."
