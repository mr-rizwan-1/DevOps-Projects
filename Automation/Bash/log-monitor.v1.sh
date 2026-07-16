#!/bin/bash

LOGFILE="error_monitor_$(date +%Y%m%d).log"
LIVELOG="app.log"
PATTERNS=("ERROR" "CRITICAL")
RED="\033[31m"
GREEN="\033[32m"
BOLD="\033[1m"
RESET="\033[0m"

ERROR_COUNT=0
TOTAL_ERRORS=0
start_time=$(date +%s)
tmp_total=$(mktemp)   # To resolve subshell problem
echo 0 > "$tmp_total"

# Trap signals to handle graceful exit and logging
trap '
    TOTAL_ERRORS=$(cat "$tmp_total")
    echo "" | tee -a "$LOGFILE"
    echo -e "\t\t=== Monitor Stopped === $(date "+%F %T")" | tee -a "$LOGFILE"
    echo -e "\tTotal Errors: ${GREEN}${BOLD}${TOTAL_ERRORS}${RESET}" | tee -a "$LOGFILE"
    echo -e "\tError log saved: $LOGFILE"
    rm -f "$tmp_total"
    exit 0
' SIGINT SIGTERM

echo -e "\t\t=== Monitor Started === $(date "+%F %T")" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"

tail -f "$LIVELOG" | while read -r line; do

    # Pattern match — with array
    for pattern in "${PATTERNS[@]}"; do
        if echo "$line" | grep -q "$pattern"; then

            # Total update in tmp file
            TOTAL_ERRORS=$(cat "$tmp_total")
            TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
            echo "$TOTAL_ERRORS" > "$tmp_total"

            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo -e "${RED}[$(date '+%F %T')] $line${RESET}" | tee -a "$LOGFILE"

            # 60 second window check
            now=$(date +%s)
            diff=$((now - start_time))

            if (( diff >= 60 )); then
                if (( ERROR_COUNT >= 5 )); then
                    echo -e "${RED}${BOLD}HIGH ALERT: Too many errors in last 60 seconds!${RESET}" | tee -a "$LOGFILE"
                fi
                ERROR_COUNT=0
                start_time=$now
            fi

            break
        fi
    done

done