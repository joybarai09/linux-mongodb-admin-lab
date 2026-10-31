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

log() {
    printf '[%s] %s\n' "$(date --iso-8601=seconds)" "$*"
}

on_error() {
    local exit_code=$?
    log "ERROR: backup failed (exit $exit_code)"
    rm -f "$ARCHIVE" "$ARCHIVE.sha256"
    exit "$exit_code"
}
trap on_error ERR

if [[ ! -r "$CONFIG" ]]; then
    log "ERROR: configuration file is missing or unreadable: $CONFIG"
    exit 1
fi

for required_command in mongodump flock gzip sha256sum; do
    if ! command -v "$required_command" >/dev/null 2>&1; then
        log "ERROR: required command not found: $required_command"
        exit 1
    fi
done

exec 9>"$BACKUP_ROOT/backup.lock"
if ! flock -n 9; then
    log "Another backup is already running; exiting."
    exit 0
fi

log "Starting MongoDB replica-set backup: $ARCHIVE"
mongodump --config="$CONFIG" --archive="$ARCHIVE" --gzip --oplog

if [[ ! -s "$ARCHIVE" ]]; then
    log "ERROR: mongodump did not create a non-empty archive."
    exit 1
fi

gzip -t "$ARCHIVE"
(
    cd "$BACKUP_DIR"
    sha256sum "$(basename "$ARCHIVE")" > "$(basename "$ARCHIVE").sha256"
)
chmod 600 "$ARCHIVE" "$ARCHIVE.sha256"

find "$BACKUP_DIR" -type f -name 'mongodb-rs0-*.archive.gz*' -mtime "+$RETENTION_DAYS" -delete

log "Backup and gzip integrity check completed successfully."
log "SHA-256: $(cut -d ' ' -f 1 "$ARCHIVE.sha256")"
log "Retention: removed matching files older than $RETENTION_DAYS days."
