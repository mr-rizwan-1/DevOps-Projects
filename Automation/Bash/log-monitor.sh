#!/bin/bash
set -e

LOGFILE="error_monitor_$(date +%Y%m%d).log"
LIVELOG="app.log"
PETTERN=("ERROR" "CRITICAL")
COLOR=("\033[31m" "\033[32m" "\033[0m" "\033[1m")

ERROR_COUNT=0
TOTAL_ERRORS=0
HEADERS=("=== Monitor Stopped ===" "=== Monitor Started ===")
current_start_time=$(date +%s)

    echo -e "\t\t\t${HEADERS[1]} $(date '+%F %T')" | tee -a "$LOGFILE"
    echo "" | tee -a "$LOGFILE"

    tail -f "$LIVELOG" | while read -r line; do
        if echo "$line" | grep -Eq "ERROR | CRITICAL" ; then
            ERROR_COUNT=$((ERROR_COUNT + 1))
            TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
            echo -e "${COLOR[0]}$line${COLOR[2]}" | tee -a "$LOGFILE"
        fi

        trap 'echo "" | tee -a "$LOGFILE";
        echo -e "\t\t\t${HEADERS[0]} $(date "+%F %T")" | tee -a "$LOGFILE";
        echo -e "\tTotal Errors: ${COLOR[1]}${COLOR[3]}$TOTAL_ERRORS${COLOR[2]}" | tee -a "$LOGFILE";
        echo -e "\tError log saved: $LOGFILE" | tee -a "$LOGFILE";

            if (( current_start_time >= 60 ))
            then
                if (( ERROR_COUNT >= 5 ))
                then
                    echo -e "${COLOR[0]}${COLOR[3]}HIGH ALERT:${COLOR[2]} Too many errors detected in last 60 seconds!" | tee -a "$LOGFILE"
                    ERROR_COUNT=0
                    start_time=$current
                fi
            fi

        exit 0' SIGINT SIGTERM
    done