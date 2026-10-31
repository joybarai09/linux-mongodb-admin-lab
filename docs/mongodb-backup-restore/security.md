# MongoDB backup security notes

- Keep real configuration files under `~/.config`, outside Git.
- Use mode 700 for the config directory and mode 600 for credential files.
- Use separate MongoDB users: `backupAgent` with the built-in `backup` role and `restoreAgent` with the built-in `restore` role.
- Never place passwords in scripts, crontab entries, shell history, commits, screenshots, or issue reports.
- Keep the replica-set keyfile private to the database nodes.
- Do not expose TCP 27017 publicly. Restrict SSH ingress to trusted source addresses.
- Rotate any credential that has been exposed.
- Local backups on host01 are not enough for disaster recovery. Copy encrypted backups to independent off-host storage and test recovery.
