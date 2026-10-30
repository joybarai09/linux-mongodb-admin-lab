
#!/usr/bin/env bash
set -Eeuo pipefail

section() {
    printf '\n===== %s =====\n' "$1"
}

section "System Information"
hostname
date
uname -a
uptime

section "CPU and Memory"
getconf _NPROCESSORS_ONLN
free -h

section "Disk Usage"
df -hT

section "Block Devices"
lsblk

section "Failed Services"
if command -v systemctl >/dev/null 2>&1; then
    systemctl --failed --no-pager || true
else
    echo "systemctl is unavailable"
fi

section "Recent System Errors"
if command -v journalctl >/dev/null 2>&1; then
    journalctl -p err -n 20 --no-pager || true
else
    echo "journalctl is unavailable"
fi

section "Network Listening Ports"
if command -v ss >/dev/null 2>&1; then
    ss -tuln
else
    echo "ss is unavailable"
fi

section "Top Processes"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11

echo
echo "Linux health check completed."
