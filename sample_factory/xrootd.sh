#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
output_file="existing_files.txt"
xrootd_server="root://eoscms.cern.ch/"
timeout_duration=10

if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

total_lines=$(wc -l < "$input_file")
[[ $total_lines -eq 0 ]] && { echo "Error: Input file is empty."; exit 1; }

current_line=0
processed=0

cleanup() { echo -e "\nInterrupted. Partial results saved."; exit 1; }
trap cleanup SIGINT

while IFS= read -r filepath; do
    ((current_line++))
    percent=$(( current_line * 100 / total_lines ))
    printf "\r[%3d%%] Checking %d/%d" $percent $current_line $total_lines
    
    if timeout $timeout_duration xrdfs "$xrootd_server" stat "$filepath" &>/dev/null; then
        echo "$filepath" >> "$output_file"
        ((processed++))
    fi
done < "$input_file"

echo -e "\nFound $processed accessible files (timeout: ${timeout_duration}s). Output: $output_file"
