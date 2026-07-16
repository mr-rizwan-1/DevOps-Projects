#!/bin/bash
# Script: CPU Process Monitor
# Author: Rizwaan Khan

THRESHOLD=50
alert_count=0
LOGFILE="cpu_report_$(date +%Y%m%d_%H%M%S).log"
HEADER="===== CPU Monitor Report - $(date '+%Y-%m-%d %H:%M:%S') ====="

echo "$HEADER" | tee "$LOGFILE"
echo "" | tee -a "$LOGFILE"
echo -e "PID\tCPU%\tPROCESS" | tee -a "$LOGFILE"

# Top 5 processes (header skip)
TOP5=$(ps aux --no-headers | sort -rk3 | awk '{print $2, $3, $11}' | head -5)

echo "$TOP5" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

# Alert check
while read PID CPU_USAGE COMMAND; do
    CPU_INT=${CPU_USAGE%.*}
    if [ "$CPU_INT" -ge "$THRESHOLD" ]; then
        msg="HIGH CPU ALERT: $COMMAND (PID: $PID) is at ${CPU_USAGE}% CPU!"
        echo "$msg" | tee -a "$LOGFILE"
        alert_count=$((alert_count + 1))
    fi
done <<< "$TOP5"

echo "" | tee -a "$LOGFILE"

# Summary
if [ "$alert_count" -gt 0 ]; then
    echo "Total Alerts: $alert_count" | tee -a "$LOGFILE"
else
    echo "No high CPU processes found." | tee -a "$LOGFILE"
fi

echo "Log saved: $LOGFILE"