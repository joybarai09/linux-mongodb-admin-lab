#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/backup.archive.gz" >&2
  exit 2
fi

ARCHIVE="$1"
CONFIG="${MONGORESTORE_CONFIG:-$HOME/.config/mongorestore.yml}"

[[ -r "$ARCHIVE" ]] || { echo "Archive missing/unreadable: $ARCHIVE" >&2; exit 1; }
[[ -r "$CONFIG" ]] || { echo "Restore config missing/unreadable: $CONFIG" >&2; exit 1; }

gzip -t "$ARCHIVE"
echo "Restoring replication_lab.* into restore_test.*; original namespace is untouched."

mongorestore \\
  --config="$CONFIG" \\
  --archive="$ARCHIVE" \\
  --gzip \\
  --nsInclude="replication_lab.*" \\
  --nsFrom="replication_lab.*" \\
  --nsTo="restore_test.*"

echo "Restore command completed. Verify documents with mongosh."
