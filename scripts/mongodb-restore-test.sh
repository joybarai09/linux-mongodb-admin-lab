#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 /path/to/backup.archive.gz" >&2
    exit 2
fi

ARCHIVE="$1"
CONFIG="${MONGORESTORE_CONFIG:-$HOME/.config/mongorestore.yml}"

if [[ ! -r "$ARCHIVE" ]]; then
    echo "ERROR: archive is missing or unreadable: $ARCHIVE" >&2
    exit 1
fi

if [[ ! -r "$CONFIG" ]]; then
    echo "ERROR: restore configuration is missing or unreadable: $CONFIG" >&2
    exit 1
fi

gzip -t "$ARCHIVE"

if [[ -f "$ARCHIVE.sha256" ]]; then
    (cd "$(dirname "$ARCHIVE")" && sha256sum -c "$(basename "$ARCHIVE").sha256")
fi

echo "Restoring replication_lab.* into restore_test.*."
echo "The original replication_lab namespace will not be overwritten."

mongorestore --config="$CONFIG" --archive="$ARCHIVE" --gzip --nsInclude="replication_lab.*" --nsFrom="replication_lab.*" --nsTo="restore_test.*"

echo "Restore command completed. Verify the restored documents with mongosh."
