#!/bin/bash
set -e

LOGFILE="error_monitor_$(date +%Y%m%d).log"
LIVELOG="app.log"
PETTERN=("ERROR" "CRITICAL")
COLOR=("\033[0;31m" "\033[0;33m")
COUNTER=0
HEADERS="=== Monitor Stopped ==="

echo "${COLOR[0"Monitoring log file:]}" $LIVELOG"