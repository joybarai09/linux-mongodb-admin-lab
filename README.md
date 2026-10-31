# linux-mongodb-admin-lab

Linux and MongoDB administration lab with Bash automation, health checks, backup and recovery, and troubleshooting runbooks.

## Lab components

- Linux administration and health-check scripts
- MongoDB health checks
- Azure-hosted MongoDB replica set lab
- Dedicated backup and restore workflow on `host01`

## MongoDB replica set backup and restore

The backup/restore lab uses a dedicated Ubuntu 24.04 administration VM (`host01`) to protect a self-managed MongoDB replica set hosted on Azure.

### Architecture

| Host | Role | Private IP |
|---|---|---|
| host01 | Backup, restore and administration | 10.20.1.10 |
| mongo01 | Preferred primary | 10.20.1.11 |
| mongo02 | Secondary | 10.20.1.12 |
| mongo03 | Secondary | 10.20.1.13 |
| mongo04 | Arbiter | 10.20.1.14 |

Replica set name: `rs0`  
MongoDB version: `9.0.4`  
MongoDB Shell: `2.14.1`  
MongoDB Database Tools: `100.20.0`

MongoDB traffic is private to the virtual network on TCP 27017. Do not expose this port publicly.

### Backup and restore features

- Compressed full replica-set archives using `mongodump --archive --gzip --oplog`
- Separate MongoDB users: `backupAgent` with the `backup` role and `restoreAgent` with the `restore` role
- Protected credential configuration files outside the repository
- Gzip and SHA-256 integrity checks
- Test restores into a separate `restore_test` database
- Cron scheduling every Saturday at 07:30 Asia/Kolkata

### Backup schedule

The configured schedule is **weekly**, every Saturday at 07:30 IST. The host OS may remain on UTC because the crontab sets `CRON_TZ=Asia/Kolkata`.

```cron
CRON_TZ=Asia/Kolkata
30 7 * * 6 /home/sysadmin/linux-mongodb-admin-lab/scripts/mongodb-backup.sh
```

### Documentation

- [Backup and restore runbook](docs/mongodb-backup-restore/README.md)
- [Architecture](docs/mongodb-backup-restore/architecture.md)
- [Security notes](docs/mongodb-backup-restore/security.md)

### Scripts and examples

- `scripts/mongodb-backup.sh`: full replica set backup with oplog and checksum validation
- `scripts/mongodb-restore-test.sh`: restores selected lab collections into `restore_test`
- `configs/mongodump.yml.example` and `configs/mongorestore.yml.example`: credential-free configuration templates
- `cron/mongodb-backup.cron.example`: weekly cron entry

### Lab validation results

- Replica set failover tested successfully.
- Backup and restore accounts authenticated with their expected built-in roles.
- Compressed replica-set backup completed and passed gzip integrity validation.
- Two test collections and two documents were restored into `restore_test`, with zero restore failures.

> This is an educational lab. Local copies on host01 are not sufficient for disaster recovery. Use independent encrypted off-host storage, define recovery objectives, monitor failures, and periodically test full recovery before using a similar design in production.
