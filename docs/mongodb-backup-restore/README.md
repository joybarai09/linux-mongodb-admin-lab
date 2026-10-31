# MongoDB backup and restore runbook

## Prerequisites

On host01, install and verify:

- `mongosh`
- `mongodump`
- `mongorestore`
- `cron`

Ensure that host01 resolves mongo node names and can reach TCP 27017 over the private network.

## Configure credentials

Create the config directory:

```bash
mkdir -p ~/.config
chmod 700 ~/.config
```

Copy the examples and edit locally:

```bash
cp configs/mongodump.yml.example ~/.config/mongodump.yml
cp configs/mongorestore.yml.example ~/.config/mongorestore.yml
chmod 600 ~/.config/mongodump.yml ~/.config/mongorestore.yml
```

Replace each placeholder password locally. Never commit the real files or share their contents.

## Create backup directories

```bash
mkdir -p ~/mongodb-backups/{daily,weekly,monthly,logs,restore-tests}
chmod 700 ~/mongodb-backups
chmod 700 ~/mongodb-backups/{daily,weekly,monthly,logs,restore-tests}
```

## Manual backup

```bash
./scripts/mongodb-backup.sh
```

Inspect the latest backup and log:

```bash
ls -lh ~/mongodb-backups/weekly/
LATEST_LOG=$(ls -t ~/mongodb-backups/logs/backup-*.log | head -1)
tail -50 "$LATEST_LOG"
```

Verify a checksum:

```bash
cd ~/mongodb-backups/weekly
sha256sum -c mongodb-rs0-YYYYMMDD-HHMMSS.archive.gz.sha256
```

## Test restore

The test restore maps only `replication_lab.*` into `restore_test.*`. It does not use `--drop`.

```bash
./scripts/mongodb-restore-test.sh \
  ~/mongodb-backups/weekly/mongodb-rs0-YYYYMMDD-HHMMSS.archive.gz
```

Verify the restored data from mongosh on a MongoDB node:

```javascript
use restore_test
db.failover_test.find().pretty()
db.replication_test.find().pretty()
db.stats()
```

The lab test restored two documents across two collections with zero failures.

## Cron schedule

Edit the sysadmin user's crontab:

```bash
crontab -e
```

Add the weekly schedule, updating the absolute repository path if necessary:

```cron
CRON_TZ=Asia/Kolkata
30 7 * * 6 /home/sysadmin/linux-mongodb-admin-lab/scripts/mongodb-backup.sh
```

Verify:

```bash
crontab -l
timedatectl
systemctl is-active cron
```

This is a weekly Saturday backup, not a daily backup.

## Operational notes

- The full replica-set archive includes databases visible to the backup account, including the temporary `restore_test` database unless the backup scope is deliberately changed.
- `--oplog` is intended for a full replica-set dump. Do not add `--db` or `--collection` to this workflow.
- The namespace-mapped test restore does not replay the captured oplog. A complete disaster recovery restore is a separate procedure.
- A gzip test validates the compressed stream, not application-level recoverability. Run restore tests regularly.
- The local host01 disk used in this lab was 30 GB. Size separate backup storage based on measured data size, growth, and retention.
- Copy encrypted backups to independent off-host storage. A backup on the same VM is not sufficient for disaster recovery.
