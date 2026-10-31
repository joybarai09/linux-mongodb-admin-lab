#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

BACKUP_ROOT="${BACKUP_ROOT:-$HOME/mongodb-backups}"
CONFIG="${MONGODUMP_CONFIG:-$HOME/.config/mongodump.yml}"
RETENTION_DAYS="${RETENTION_DAYS:-56}"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/weekly"
LOG_DIR="$BACKUP_ROOT/logs"
ARCHIVE="$BACKUP_DIR/mongodb-rs0-$STAMP.archive.gz"
LOG="$LOG_DIR/backup-$STAMP.log"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"
chmod 700 "$BACKUP_ROOT" "$BACKUP_DIR" "$LOG_DIR"
exec >> "$LOG" 2>&1

log() { printf '[%s] %s\\n' "$(date --iso-8601=seconds)" "$*"; }
trap 'rc=$?; log "ERROR: backup failed (exit $rc)"; exit "$rc"' ERR

[[ -r "$CONFIG" ]] || { log "Missing/unreadable config: $CONFIG"; exit 1; }
command -v mongodump >/dev/null || { log "mongodump not found"; exit 1; }

exec 9>"$BACKUP_ROOT/backup.lock"
flock -n 9 || { log "Another backup is running; exiting."; exit 0; }

log "Starting replica-set backup: $ARCHIVE"
mongodump --config="$CONFIG" --archive="$ARCHIVE" --gzip --oplog
gzip -t "$ARCHIVE"
sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"
chmod 600 "$ARCHIVE" "$ARCHIVE.sha256"

find "$BACKUP_DIR" -type f \\
  \\( -name 'mongodb-rs0-*.archive.gz' -o -name 'mongodb-rs0-*.archive.gz.sha256' \\) \\
  -mtime "+$RETENTION_DAYS" -delete

log "Backup and gzip integrity check completed."
log "SHA-256: $(cut -d ' ' -f 1 "$ARCHIVE.sha256")"
log "Retention: $RETENTION_DAYS days."
