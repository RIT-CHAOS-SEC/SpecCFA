if [ $# -lt 1 ]; then
    echo "Error: provide app name (ultra, geiger, syringe, temp, gps, mouse)"
    exit 1
fi

app_name=$1

#!/bin/bash

# # Input C file
input_file="./c_files/"$app_name".c"

# # Output text file for function names
output_file="./c_files/funcs.txt"

# # Use grep to find lines with function calls and extract function names
grep -E '^\s*(\w+\s+)*\w+\s+\w+\s*\([^)]*\)|\w+\s+\w+\s*\([^)]*\)\s*\{' "$input_file" | awk -F'(' '{print $1}' | awk '{print $NF}' | sort | uniq > "$output_file"

## sometimes gets if
sed -i '/if/d' "$output_file"

# Build all
echo "Building app CFG..."
echo python3 generate_cfg.py --asmfile ./app_lst/${app_name}.lst --arch elf32-msp430 --cfgfile ./objs/${app_name}_cfg.bin
echo " "
python3 generate_cfg.py --asmfile ./app_lst/${app_name}.lst --arch elf32-msp430 --cfgfile ./objs/${app_name}_cfg.bin
echo " "

# # Run
echo "Running get_speculation_paths..."
echo python3 get_speculation_paths.py --cfg_file ./objs/${app_name}_cfg.bin --start_addr 0xe03e --end_addr 0xffff --func_file ./objs/${app_name}_asm_func.bin
echo " "
python3 get_speculation_paths.py --cfg_file ./objs/${app_name}_cfg.bin --start_addr 0xe03e --end_addr 0xffff --func_file ./objs/${app_name}_asm_func.bin
echo " "