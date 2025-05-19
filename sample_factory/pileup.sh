#!/bin/bash

# Check input parameters
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file.txt>"
    exit 1
fi

input_file="$1"
output_file="existing_files2.txt"
prefix="/eos/cms"

# Verify input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file $input_file not found!"
    exit 1
fi

# Initialize counters
total=0
existing=0

# Process file line by line
while IFS= read -r line; do
    ((total++))
    full_path="${prefix}${line}"
    if [ -e "$full_path" ]; then
        ((existing++))
        echo "$line" >> "$output_file"
    fi
done < "$input_file"

# Display summary
echo "Processing completed!"
echo "Total files checked: $total"
echo "Existing files found: $existing"
echo "Results saved to: $output_file"
