#!/bin/bash
# Script: Disk Space Alert
# Author: Rizwaan Khan

THRESHOLD=80
alert_count=0

df -P | grep -iv "filesystem" | awk '{print $1, $5}' | sed 's/%//' | while read DRIVE USAGE
do
    if [ "$USAGE" -ge "$THRESHOLD" ]; then
        echo "ALERT: $DRIVE is at ${USAGE}% usage!"
        alert_count=$((alert_count + 1))
    fi
done

if [ "$alert_count" -eq 0 ]; then
    echo "All drives are below ${THRESHOLD}% — No alerts."
fi