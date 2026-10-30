
# Linux System Administration Runbook

## 1. System Information

Check Linux distribution and kernel:

```bash
cat /etc/os-release
uname -r
hostnamectl
uptime
```

## 2. CPU and Memory Monitoring

```bash
lscpu
free -h
top
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
```

## 3. Disk and Storage Management

```bash
lsblk
blkid
df -hT
du -sh /var/*
fdisk -l
```

### LVM Management

```bash
pvs
vgs
lvs
lvdisplay
vgdisplay
```

### Filesystem Management

```bash
findmnt
mount
cat /etc/fstab
```

## 4. Service Management

```bash
systemctl status ssh
systemctl list-units --type=service
systemctl --failed
systemctl restart ssh
systemctl enable ssh
```

## 5. Log Management

```bash
journalctl -xe
journalctl -p err
journalctl -u ssh
tail -f /var/log/syslog
```

On RHEL-based systems:

```bash
tail -f /var/log/messages
```

## 6. Network Administration

```bash
ip addr
ip route
ss -tulpn
ping -c 4 8.8.8.8
traceroute 8.8.8.8
nslookup google.com
```

## 7. User and Group Management

```bash
useradd sysadmin
passwd sysadmin
groupadd linuxadmins
usermod -aG linuxadmins sysadmin
id sysadmin
getent passwd
getent group
```

## 8. SSH Security

Recommended practices:

- Disable direct root SSH login.
- Prefer SSH public-key authentication.
- Restrict SSH access using firewall rules.
- Keep OpenSSH updated.
- Review authentication logs.

Validate SSH configuration:

```bash
sshd -t
systemctl reload sshd
```

Ubuntu commonly uses the service name `ssh`.

## 9. Scheduled Tasks

```bash
crontab -l
crontab -e
systemctl status cron
```

On RHEL:

```bash
systemctl status crond
```

## 10. Troubleshooting Checklist

| Problem | Diagnostic command |
|---|---|
| High CPU | top |
| High memory | free -h |
| Disk full | df -hT |
| Service failure | systemctl status |
| Network issue | ip route |
| Port issue | ss -tulpn |
| Authentication issue | journalctl |
| Filesystem issue | findmnt |

## 11. Best Practices

- Monitor system resources regularly.
- Maintain tested backups.
- Apply security updates.
- Use least-privilege access.
- Document configuration changes.
- Review system logs.
- Test recovery procedures.
