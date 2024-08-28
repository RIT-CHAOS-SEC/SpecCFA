#!/bin/bash

# Check if a directory name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

# Check if the provided directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist."
    exit 1
fi

# Initialize a variable to store the total line count
total_lines=0

# Iterate over files with the naming convention "0.txt" to "999.txt"
for i in {0..250}; do
    file="$directory/$i.cflog"
    if [ -f "$file" ]; then
        # Count the lines in each file and add to the total
        lines_in_file=$(wc -l < "$file")
        total_lines=$((total_lines + lines_in_file))
        # echo "File: $file, Line Count: $lines_in_file"
    fi
done

# Print the total line count for all files in the directory
echo "Total Line Count: $total_lines"
