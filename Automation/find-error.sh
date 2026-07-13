#!/bin/bash
# Script: Find error type with highest count in a time range
# Author: Rizwaan Khan

set -e
echo -n "Starting Hour (e.g. 14): "
read s_time
echo -n "Ending Hour (e.g. 15): "
read e_time

# Error types array
errors=("JO1" "JO2" "JO3" "JO4" "JO5" "JO6" "JO7")

max=0
max_error=""

# Count each error in time range
for err in "${errors[@]}"
do
    count=$(grep -E "$s_time:[2-5][0-9]|$e_time:[0-3][0-9]" conlogs.txt \
            | grep -ic "$err")

    echo "$err count: $count"

    if [ "$count" -gt "$max" ]; then
        max=$count
        max_error=$err
    fi
done

# Result
echo ""
echo "Largest error: $max_error with count: $max"
echo ""

# Log file name with timestamp
log_file="error_report_${max_error}_$(date +%Y%m%d_%H%M%S).log"

# Ask user what to do
echo "Choose an option:"
echo "  1) Print error list on screen"
echo "  2) Create error log file"
echo "  3) Both"
echo "  4) Exit"
echo -n "Enter choice (1/2/3/4): "
read choice

# Extract matching errors
extract_errors() {
    grep -E "$s_time:[2-5][0-9]|$e_time:[0-3][0-9]" conlogs.txt \
    | grep -i "$max_error"
}

case $choice in
    1)
        echo ""
        echo "--- Error List: $max_error ---"
        extract_errors
        ;;
    2)
        extract_errors > "$log_file"
        echo "Log file created: $log_file"
        ;;
    3)
        echo ""
        echo "--- Error List: $max_error ---"
        extract_errors | tee "$log_file"
        echo ""
        echo "Log file created: $log_file"
        ;;
    4)
        echo "Exiting."
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac