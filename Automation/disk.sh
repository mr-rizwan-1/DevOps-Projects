#!/bin/bash

set -e
THRESHOLD=80

df -hP | grep -iv "filesystem" | awk '{print $1, $5}' | sed 's/%//' | while read DRIVE USAGE
do
    if [ "$USAGE" -ge "$THRESHOLD" ]
    then
        echo "ALERT: $DRIVE is at $USAGE usage!"
    fi
done

echo "All other drives are fine."