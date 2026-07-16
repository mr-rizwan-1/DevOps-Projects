#!/bin/bash
# Script: Log Simulation
while true; do
    echo "2026-07-10 $(date +%H:%M:%S) ERROR New error occurred" >> app.log
    sleep 2
    echo "2026-07-10 $(date +%H:%M:%S) INFO Normal log line" >> app.log
    sleep 1
    echo "2026-07-10 $(date +%H:%M:%S) CRITICAL Critical issue found" >> app.log
    sleep 3
done