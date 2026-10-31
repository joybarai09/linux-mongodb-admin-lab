# MongoDB backup and restore architecture

```text
Azure Virtual Network (10.20.0.0/16)
|
+-- host01  10.20.1.10  Backup / restore / cron
|
+-- mongo01 10.20.1.11  Preferred primary
+-- mongo02 10.20.1.12  Secondary
+-- mongo03 10.20.1.13  Secondary
+-- mongo04 10.20.1.14  Arbiter
```

MongoDB listens on loopback and private interfaces. TCP 27017 is allowed only within the virtual network. SSH access to host01 should be restricted to a trusted source address.

## Backup flow

1. Cron invokes the backup script on host01.
2. A lock prevents overlapping runs.
3. `mongodump` connects to replica set `rs0` using `backupAgent`.
4. A gzip archive is created with oplog capture.
5. The archive is checked and a SHA-256 checksum is written.
6. Old archives are removed according to the configured retention period.
