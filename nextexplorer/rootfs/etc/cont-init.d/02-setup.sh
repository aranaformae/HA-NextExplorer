#!/usr/bin/with-contenv bashio
CONFIG_PATH="/etc/autofs/auto.cifs"
bashio::log.info "Generating autofs configuration..."
V_ROOT="${VOLUME_ROOT:-/storage}"
> "$CONFIG_PATH"
for mount in $(bashio::config 'mounts|keys'); do
    SERVER=$(bashio::config "mounts[${mount}].server")
    SERVER_CLEAN=$(echo "$SERVER" | sed 's|^//||')
    NAME=$(bashio::config "mounts[${mount}].name")
    USER=$(bashio::config "mounts[${mount}].username")
    PASS=$(bashio::config "mounts[${mount}].password")
    MOUNT_POINT="$V_ROOT/${NAME}"
    mkdir -p "$MOUNT_POINT"
    ENTRY="${MOUNT_POINT} -fstype=cifs,rw,username=${USER},password=${PASS},noserverino,iocharset=utf8 ://${SERVER_CLEAN}"
    echo "$ENTRY" >> "$CONFIG_PATH"
done
chmod 600 "$CONFIG_PATH"
bashio::log.info "Autofs configuration generated."
