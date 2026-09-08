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
            all_addon_configs)
                SOURCE_PATH="/addon_configs"
                TARGET_NAME="addon_configs"
                ;;
            addons)
                SOURCE_PATH="/addons"
                TARGET_NAME="addons"
                ;;
            ssl)
                SOURCE_PATH="/ssl"
                TARGET_NAME="ssl"
                ;;
            *)
                echo "WARNING: unsupported root volume requested: $vol"
                continue
                ;;
        esac

        TARGET_PATH="$V_ROOT/$TARGET_NAME"
        echo "$SOURCE_PATH -> $TARGET_PATH"

        if [ -d "$SOURCE_PATH" ]; then
            rm -rf "$TARGET_PATH"
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
