import os

SIM_FILE = "../openmsp430/simulation/tb_openMSP430_fpga.v"

def main():
    
    with open(SIM_FILE, "r") as ifp:
        template_file = ifp.read()

    os.chdir("..")
    working_dir = os.getcwd()
    os.chdir("scripts")
    
    log_files = ""
    for i in range(20):
        log_files += f'{i}: slicefile=$fopen("{working_dir}/logs/{i}.cflog", "w");\n        '
    log_files = log_files[:-9]

    template_file = template_file.replace("CFLOG_FILES", log_files)

    with open(SIM_FILE, "w") as ofp:
        ofp.write(template_file)


if __name__ == "__main__":
    main()
