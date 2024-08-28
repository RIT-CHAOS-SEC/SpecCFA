project="SpecCFA-TZ"
projectDir="../prv/"
objectsDir="./objects/"
# projectDir=..//STM32_SECURITY_LAB/TEST_PROJECTS/${project}/

# windows
arm-none-eabi-objdump -marm -dz ${projectDir}Secure/Debug/${project}_Secure.elf > {objectsDir}Secure.asm.tmp

# linux
# objdump -dz ${projectDir}Secure/Debug/${project}_Secure.elf > ${objectsDir}Secure.asm.tmp

sed '/>:$/d' ${objectsDir}Secure.asm.tmp > ${objectsDir}Secure.tmp
python3 format_words.py ${objectsDir}Secure.tmp
sed -i 's/ //g' ${objectsDir}Secure.tmp2
awk '{print $2}' Secure.tmp2 > ${objectsDir}Secure.mem
sed -i 's/\(.\{2\}\)/\1\n/g' ${objectsDir}Secure.mem
sed -i '/^$/d' ${objectsDir}Secure.mem

# windows
arm-none-eabi-objdump -marm -dz ${projectDir}NonSecure/Debug/${project}_NonSecure.elf > {objectsDir}NonSecure.asm.tmp

# linux
# objdump -dz ${projectDir}NonSecure/Debug/${project}_NonSecure.elf > ${objectsDir}NonSecure.asm.tmp

sed '/>:$/d' ${objectsDir}NonSecure.asm.tmp > ${objectsDir}NonSecure.tmp
python3 format_words.py ${objectsDir}NonSecure.tmp
sed -i 's/ //g' ${objectsDir}NonSecure.tmp2
awk '{print $2}' ${objectsDir}NonSecure.tmp2 > ${objectsDir}NonSecure.mem
sed -i 's/\(.\{2\}\)/\1\n/g' ${objectsDir}NonSecure.mem
sed -i '/^$/d' ${objectsDir}NonSecure.mem

rm ${objectsDir}*.tmp*
