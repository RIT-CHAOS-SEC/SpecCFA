#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: provide name of sensor app"
    echo "Usage: ./count.sh <sensor_app>"
else

	if [ "$1" = "ultrasonic" ]; then
	    subpaths="6"
	else
	    subpaths="8"
	fi

	project=$1
	logs_dir="../logs/"$project"_baseline"
	sum=0

	echo "Total CFLog entries: "

	# Iterate over files in the logs directory
	for file in "$logs_dir"/*; do
	    if [ -f "$file" ]; then  
	        last_line=$(tail -n 1 "$file")
	        number=$(echo "$last_line" | tr -d '[:space:]')  
	        sum=$((sum + number))  
	    fi
	done

	echo "$logs_dir: $sum"

	sum=0
	logs_dir="../logs/"$project"_experiments/"$subpaths
	# Iterate over files in the logs directory
	for file in "$logs_dir"/*; do
	    if [ -f "$file" ]; then  
	        last_line=$(tail -n 1 "$file")
	        number=$(echo "$last_line" | tr -d '[:space:]')  
	        sum=$((sum + number))  
	    fi
	done

	echo "$logs_dir: $sum"

	logs_dir="../logs/"$project"_experiments/test_files_repeats/logs"
	sum=0

	# Iterate over files in the logs directory
	for file in "$logs_dir"/*; do
	    if [ -f "$file" ]; then  
	        last_line=$(tail -n 1 "$file")
	        number=$(echo "$last_line" | tr -d '[:space:]')  
	        sum=$((sum + number))  
	    fi
	done

	echo "$logs_dir: $sum"
fi