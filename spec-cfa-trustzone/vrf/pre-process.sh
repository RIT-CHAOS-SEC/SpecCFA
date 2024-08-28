# --------------- READ FILENAMES AS INPUTS

# Check if two input parameters are provided
if [ "$#" -lt 2 ]; then
    echo "Error: Two input files (without their extensions) are required"
    echo " --- "
    echo "Example usage: $0 application instrumented"
    echo " --- application: reads from file 'application.c' "
    echo " --- instrumented: creates file 'instrumented.s' "
    exit 1
fi

filename="$1"
instrumented="$2"

# --------------- DEFINES ----------------------

# --------------- PATH TO NonSecure directory within STM Project ----------------------
# HOME=../../tmp/STM32L5_HAL_TRUSTZONE/NonSecure/ # windows
PROJ=../prv/
HOME=$PROJ"NonSecure/" # ubuntu

APP_SOURCE_PATH=$HOME"Core/Src/"
echo "APP_SOURCE_PATH=" $APP_SOURCE_PATH
echo "    "

DRIVER_SOURCE_PATH=$HOME"Drivers/STM32L5xx_HAL_Driver/Src/"
echo "DRIVER_SOURCE_PATH=" $DRIVER_SOURCE_PATH
echo "    "

DRIVER_OBJ_PATH=$HOME"Drivers/STM32L5xx_HAL_Driver/"
APP_OBJ_PATH=$HOME"Debug/Core/Src/"

# --------------- GET APP ASM ----------------------
full_file_path="${filename}.c"

echo arm-none-eabi-gcc "$full_file_path" -mcpu=cortex-m33 -std=gnu11  $DEBUG -DUSE_HAL_DRIVER -DSTM32L552xx -c -I$HOME""Core/Inc -I$HOME""Secure_nsclib -I$PROJ""Drivers/STM32L5xx_HAL_Driver/Inc -I$PROJ""Drivers/CMSIS/Device/ST/STM32L5xx/Include -I$PROJ""Drivers/STM32L5xx_HAL_Driver/Inc/Legacy -I$PROJ""Drivers/STM32L5xx_HAL_Driver/Inc/ -I$PROJ""Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF"Drivers/STM32L5xx_HAL_Driver/$filename.d" -MT"Drivers/STM32L5xx_HAL_Driver/$filename.o" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb  -S -o $APP_SOURCE_PATH"$filename.s"
echo "    "
arm-none-eabi-gcc "$full_file_path" -mcpu=cortex-m33 -std=gnu11 -O0 -fno-jump-tables $DEBUG -DUSE_HAL_DRIVER -DSTM32L552xx -c -I. -I$HOME""Core/Inc -I$HOME""Secure_nsclib -I$PROJ""Drivers/STM32L5xx_HAL_Driver/Inc -I$PROJ""Drivers/CMSIS/Device/ST/STM32L5xx/Include -I$PROJ""Drivers/STM32L5xx_HAL_Driver/Inc/Legacy -I$PROJ""Drivers/STM32L5xx_HAL_Driver/Inc/ -I$PROJ""Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -MMD -MP -MF""$APP_OBJ_PATH""$filename".d" -MT""$APP_OBJ_PATH""$filename".o" --specs=nano.specs -mfpu=fpv5-sp-d16 -mfloat-abi=hard -mthumb  -S -o $filename".s"

sed -i '/SECURE_new_log_entry/c\' application.s 

# --------------- INSTRUMENT & MOVE TO PROJ ----------------------

# use instrumented app
python3 instrument.py --dir ./ --infile $filename.s --outfile $instrumented.s
cp $instrumented".s" $APP_SOURCE_PATH""$filename".s"

# use uninstrumented app
# cp $filename".s" $APP_SOURCE_PATH""$filename".s"

# remove old CFlog files
rm -f ../cflogs/*.cflog
