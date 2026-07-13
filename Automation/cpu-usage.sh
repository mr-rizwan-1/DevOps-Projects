#!/bin/bash

echo "===== CPU Monitor Report - $(date '+%Y-%m-%d %H:%M:%S') ====="
echo ""

CPU_PS=$(ps aux | sort -rk3 | awk '{print $2, $3, $11}' | head -6)

echo "$CPU_PS"
echo ""
CPU_PSS=$(echo "$CPU_PS" | tail -5)

THRESHOLD=1
alert_count=0
LOGFILE="cpu_report_$(date +%Y%m%d_%H%M%S).log"

while read PID CPU_USAGE COMMAND; do
    CPU_INT=${CPU_USAGE%.*}
    if [ $CPU_INT -ge $THRESHOLD ] ; then
        echo "HIGH CPU ALERT: $COMMAND (PID: $PID) is at ${CPU_USAGE}% CPU!" >> "$LOGFILE"
        alert_count=$((alert_count + 1))
    fi
done <<< "$CPU_PSS"

if [ "$alert_count" -ne 0 ]; then
    echo "Total Alerts: $alert_count"
    echo "Log saved: $LOGFILE"
fi


