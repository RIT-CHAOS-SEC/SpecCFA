# SpecCFA: Enhancing Control Flow Attestation via Application-Aware Sub-Path Speculation

Several modern systems rely on micro-controller units (MCUs) for cost- and energy-efficient sensing/actuation operations.
Since MCUs lack the security capabilities of general-purpose processors, Remote Attestation (RA) was proposed to enable a verifier (Vrf) to remotely assess the software integrity of a prover MCU (Prv). Unfortunately, although effective in verifying the integrity of the software image installed on Prv, RA cannot detect out-of-order execution attacks that do not modify Prv's binary (e.g., control flow hijacking and code re-use attacks).

Control Flow Attestation (CFA) augments RA by also providing Vrf with a log (CFLog) of all control flow transfers that occur during execution on Prv, enabling detection of out-of-order execution attacks. However, since CFLog can quickly fill Prv's memory, prior work has proposed CFLog management strategies and size reduction measures. For instance, some techniques transmit a series of fixed-size CFLog-s or ignore statically-determined control flow transfers (such as direct calls/jumps). Irrespective of their specifics, we note that prior approaches are context-insensitive, i.e., they do not support configurable program-specific optimizations. As components of a particular program may produce predictable control flow sub-paths, we argue that this program-specific predictability could be leveraged to further optimize CFA.

Based on this premise, we propose SpecCFA: an architecture to enable configurable sub-path speculation in CFA.
SpecCFA allows Vrf to speculate on likely control flow sub-paths for each attested operation. At runtime, when a sub-path in CFLog matches a pre-defined speculation, the entire sub-path is replaced by a reserved symbol of reduced size, resulting in significant savings. SpecCFA can be deployed atop existing CFA architectures to support simultaneous speculation on multiple variable-length control flow sub-paths. We implement an open-source prototype of SpecCFA atop an existing CFA architecture aimed at low-end MCUs (e.g, TI MSP430) and evaluate its cost-effectiveness.

## SpecCFA Directory Structure
    
    Todo when repo is stable

## Development Enviornment

We evaluated SpecCFA on a 64-bit Ubuntu 20.04.2 device with a 3.7Ghz CPU and 32Gb of RAM. SpecCFA's evaluation also relies on several python scripts. For this, we evaluated SpecCFA with python 3.8.10, however SpecCFA's scripts should be compatible with newer versions of python as well.

## Sub-path Selection

In this work, sub-paths refer to series of contigous control-flow transfers within CFLog. SpecCFA allows for the dynamic speculation of these sub-paths by Vrf and the replacment of these sub-paths with a reserved symbol in CFLog on the Prv. As such, SpecCFA's operation depends greatly on the selected sub-paths. For this reason, we implement multiple potential sub-path selection policies to demonstrate SpecCFA's behavior.

### Program Analysis

When previous CFLogs are unavailable, automated subpath selection can occur based on static analysis of the application code/binary. We describe this in our paper and implement this in the `static-analysis` directory. Within this directory are the following subdirectories:
- `app_lst`: the assembly of the applications produced by disassembling the binaries
- `c_files`: the C source code of the applications
- `objs`: objects produced by the static analysis
- `selections`: contains the text file with the subpath selections

To run the static analysis, the application source code and `lst` file produced through `objdump -d` must be provided as input. These inputs must be placed in the `c_files` and `app_lst` subdirectories, respectively.

After that, the static analysis can be executed by running the `run.sh` script from after changing into the `static-analysis` directory. Specifically, follow the following steps after adding your application inputs into `c_files` and `app_lst`:

1. `cd` into `static-analysis`
2. Execute `./run.sh <application>` replacing `<application>` with the name of your program. Note that the `.c` and `.lst` files must have the same name: (e.g., `app.c` and `app.lst`).
3. After running, the selected subpaths will appear in `selections/subpaths`. Pre-computed outputs for each of the example programs are also provided in this folder. 

### CFLog Analysis

We also implement three selection strategies based on prior recieved CFLogs. These strategies use these previous CFLogs to predict which sub-paths are most likely to occur during the applications execution. The three strategies are as follows:

**Top** selects the most frequent non-overlapping sub-paths from prior CFLogs. This strategy ignores the selected sub-paths size and associated overhead.

**Minimize** selects the N most frequent smallest sub-paths, then iterates over the remaining sub-paths. These remianing sub-paths are compared agaist the least-frequent selected path and replaces it if the candidate path occurs significantly more than the prior selected path. This strategy aims to minimize the overhead associated with the selected sub-paths.

**Select** selects the most frequent sub-path that fits within the remaining memory availiable. This strategy aims to maximize CFLog savings while having a fixed sub-path overhead.

To use the selection strategies, we provide a python script (`path_selection.py`) with the `inspector` directory. This script takes a directory of prior CFLogs as input, parses the logs, and outputs the desired sub-path selections. To run the script, navigate to the `inspector` directory and run:

        python3 path_selection.py -d path/to/logs -a arch selection_strategy selection_strategy_options

Along with the path to the prior CFLogs, the script also requires you specify the architecture of device (either MSP or ARM) and the selection strategy. Certain strategies also require strategy specific command line arguments as well. For more information on the `path_selection.py`'s required and optional arguments run: 

        python3 path_selection.py -h
    
### Manual Inspection

You can also manually select sub-paths from prior CFLogs if desired. To do this simply add the desired sub-paths to a text file where each sub-path is on a new line and transfers with each sub-path are seperated by a space. 

Example:

        transfer1 transfer2 transfer3 transfer4
        transerf1 transfer2 transfer3 transfer4 transfer5 transfer6
        etc.

## SpecCFA Custom Hardware (ACFA) Variant

SpecCFA's custom hardware prototype is built atop the open-source Control-Flow Auditing architecture ACFA. ACFA is a hybrid design that logs all control-flow transfers of an attested binary and guarentees the eventual delivery of these logs as well as remediation in the case of a compromise. More information about ACFA can be found on its [open-source repository](https://github.com/RIT-CHAOS-SEC/ACFA)

### SpecCFA/ACFA Dependencies 

Of course to use vivado you need to clone this repository. Along with that, we use Xilinx Vivado v2022.1 to build and test SpecCFA's custom hardware design, however newer versions of Vivado should also be fine. Vivado an be downloaded for free from the following [Xilinx/AMD's website](https://www.xilinx.com/support/download.html) though you will need an AMD account to access it. As a precaution, prior to installing Vivado run the following command:

        apt-get install libtinfo5 libncurses5

These packages may already be present on your, however without them Vivado's installation would hang indefinitly. Once these packages are intalled (or verified to already be present) simply run the installer to install Vivado. 

Along with Vivado, SpecCFA has several software dependncies. To install the remianing dependencies run the following command:

        apt-get install bison pkg-config gawk clang flex gcc-msp430 iverilog tcl-dev python3-serial

SpecCFA's scripts also rely on the `time`. `hmac`, `hashlib`, `argparse`, `pickle`, `dataclasses`, `os`, and `collections` python packages.

Similarly when using the custom hardware variant of SpecCFA you will need to initialize its files. To perform this setup, navigate to the `sccipts` directorty and run :

        make install
        
Finally we deploy SpecCFA's custom hardware design on a Basys3 Prototyping board. Basys3's documentation can be found [here](https://digilent.com/reference/basys3/refmanual)
 
### Creating a Vivado Project

1. Start Vivado. Once loaded, on the upper left select: File -> New Project

2. Follow the wizard, select a project name, and select a location. In project type, select "RTL Project" and click "Next" 

3. In the "Add Sources" window, select "Add Files" and add all the `*.v` and `*.mem` files contained in the following repository directories:
        
        /acfa-hw/*
        /msp_bin
        /openmsp430/fpga
        /openmsp430/msp_core
        /openmsp430/msp_memory
        /openmsp430/msp_periph
        /spec-cfa

    then select "Next".  

4. In the "Add Constraints" window, select "Add Files" and add the file:

        /openmsp430/constraints_fpga/Basys-3-Master.xdc
    
    then select "Next"

    **Note:** This file needs to be modified if you are running SpecCFA on a different FPGA

5. In the "Default Part" window, select "Boards", search for Basys3, select it, and click 'Next"

    **Note:** If you do not see Basys3 as an option you may need to refresh the board catalogue. To do this, click the refresh button in the bottom left of the window. Once the process finishes, the board should be visible. Next press the download icon in the Basys3 board's entry to download the part. When download, select the board and continue as normal.

6. Select "Finish". This will conclude the creation of your Vivado Project

Next you need to configure the project for sythesis

7. In the PROJECT MANAGER "Sources" window, search for the openMSP430_fpga (`openMSP430_fpgra.v`) file, right-click it, and select "Set as TOp". This will make `openMSP430_fpga.v` the top module in the project hierarchy. When set, the file's name should appear in bold.

8. In the same "Sources" window, search for the `openMSP430_defines.v` file. Right-click the file, select "Set File Type", and then select "Verilog Header" form the dropdown menu.

Now you are ready to synthesize SpecCFA's hardware.

### Synthesizing SpecCFA

While the project is ready for synthesis, SpecCFA's configuration depends on the application being tested/used. As such, before synthesizing the hardware you will need to generate the necessary memory and hardware file. 

To generate correct memory configuration, navigate to the `scripts` directory and use the provide makefile to build the desired application as follows:

        make application_name

The available applications are: app, gieger, gps, mouse, syringe_pump, temperature_sensor, and utrasonic_sensor. More information about each app can be found in the [Test Application](#test-applications) section. Running this command will update the `pmem.mem` and `smem.mem ` files found in the `/msp_bin` directory with the correct memory configurations. 

To generate the correct hardware configuration, navigate to the `generator` directory and run the provided `generator.py` python script. `generator.py` takes a file of sub-path definitions, the application they came from, and the sub-path selection strategy as input and updates all the neceassry files to both synthesize and simulate SpecCFA's hardware. For information on how to generate the expected subpath file refer to the previous section: [Sub-Path Selection](#sub-path-selection). YOu can run `generator.py` as follows:

        python3 generator.py -f subpath_definition_file -a test_application selection_strategy

`generator.py` also allows you to change the default CFLog size using the optional `--size` arguement. For more information on the scripts command line arguement run the following command

        python3 generator.py -h

After running both script, all the necessary files for synthesis will have been generated. These changes will be automatically reflected in your Vivado project. Now to synthesize SpecCFA, switch back to your Vivado project. Then:

1. On the left menuof the PROJECT MANAGER click "Run SYnthesis". In the Resulting window customize your execution parameters (e.g., number of CPUs used) as desired and start the synthesis. 

    **Note:** Synthesizing the hardware can take several minutes

2. If/When the synthesis succeeds, you will be prompted "Run Implmentation. For now just close this window. The implementation files are not needed to simulate SpecCFA's behavior for simple testing. Instead the implemntation is only needed for testing the CFLog transmission/total run-time overhead of the system. We discuss how to implement the hardware in a later [section]()

***TODO*** add link

### Run Simulation

After completeing the steps discussed in [Creating a Vivado Project](#creating-a-vivado-project) and [Synthsizing SpecCFA](#synthesizing-speccfa) you can now simulate SpecCFA's behavior in Vivado. To do this:

1. In Vivado, click "Add Sources" (Alt-A), select "Add or create simulation sources", select "Add Files", and select everything inside the `/openmsp430/simulation` directory

2. Next, in the "Sources" window of Vivado, search for `tb_openMSP430_fpga` in the `Simulation Sources` collapsable menu. Once found, right-click the file and select "Set as Top"

3. Then go back to the Vivado window and in the "Flow Navigator" tab (left-most menu in the Vivado window) click "Run Simulation" then "Run Behavioral Simulation"

4. Once the simulation window opens you are ready to simulate SpecCFA's behavior. When running the simulation all CFLog slices will be saved to the ***TODO*** put somewhere

To run the simulation use either of the blue play buttons found at the top of the window. The center (and larger) button will run the simulation indefintely until paused (by pressing the same button). The second play button will execute the simulation for a specified (the input field next to the button) amount of time. The latter can also be triggered by pressing "Shift+2"

While the simulation is running and after its paused, you can view SpecCFA's behavior using the green waveform window on the right of the screen. This window contains several signals and displays their values thoughout the execution. Along with the existing signals, you can add new signals to the window by selecting a hardware component in the "Scope" window, right-clicking an object in the "Objects" window, and clicking "Add to Wave window".

### Run Implementation & Deploy SpecCFA on Basys3 FPGA

1- After Synthesis succeeds, select "Run Implementation" and wait until this process completes (typically takes around 45 minutes to 1 hour).

2- If implementation succeeds, you will be prompted with another window, select option "Generate Bitstream" in this window. This will generate the bitstream that is used to set up the FPGA according to SpecCFA+ACFA hardware and MCU software.

3- After the bitstream is generated, select "Open Hardware Manager", connect the FPGA to you computer's USB port and click "Auto-Connect".
Your FPGA should be now displayed on the hardware manager menu.

        Note: if you don't see your FPGA after auto-connect you might need to download Basys3 drivers to your computer.

4- Right-click your FPGA and select "Program Device" to program the FPGA.

**Note** because this process takes a long time, we have pre-generated bitstreams in the `bitstreams`. Bitstream filenames are of the notation `<total_subpaths>-<application>.bit` for the total number of subpaths configured (either 0 or 2) and the application. To use these, use the bitstream window to select the filepath for the bitstream.

## SpecCFA TEE (TrustZone) Variant 

***TODO***

## Test Applications

Along with SpecCFA's prototypes, we also provide 7 sample embedded applications for testing (and their simulation time in Vivado): 

Ultrasonic Sensor (\~8 ms)
Ultrasonic sensor is ported from [Seeed-Studio](https://github.com/Seeed-Studio/LaunchPad_Kit/tree/master/Grove_Modules/ultrasonic_ranger), and implements a simple ultrasonic sensor using delay and sensor loops.

Temperature Sensor (\~3 ms)
This program implements a temperature and humidity sensor. It was ported from [Seeed-Studio](https://github.com/Seeed-Studio/LaunchPad_Kit/tree/master/Grove_Modules/temp_humi_sensor). It implements such sensors similarly to ultrasonic, using delay loops and sensing loops.

Syringe Pump (\~55 ms)
This program simulates a remotely operated Syringe Pump that receives input to control dosages. It was ported to our platforms from [OpenSyringePump](https://github.com/manimino/OpenSyringePump).

GPS (\~30 ms)
This program simulates an input stream from a GPS peripheral module, and performs the processing of the strings. This source code came from [TinyGPS](http://arduiniana.org/libraries/tinygpsplus/) and was modified to be compatible with our platform, mock its behavior, and to simulate inputs.

Geiger Counter (\~4 ms)
This program comes from [ArduinoPocketGeiger](https://github.com/MonsieurV/ArduinoPocketGeiger) and was modified/ported to run on our platform and to mock inputs/behavior. It implements a Geiger Counter, which is used to measure radiation.

## CFLog

### Log Structure

CFLog records the control flow transfers for the attested execution. While both prototype achieve the same goals, the structure of their logs vary. This variation is due to the underlying CFA scheme SpecCFA is implemented on. 

The custom hardware prototype is implmented a top ACFA. At the time, ACFA logged both the source and destination address of control-flow transfers to CFLog. As such each CFLog entry contains two addresses with the first 4 hex characters representing the source and the last 4 charaters representing the destination of the transfer.

The TEE based version of SpecCFA is implemented ontop of TRACES. Unlike ACFA, TRACES only logs the destination address of each control-flow transfer. Due to this, each entry in these logs represents a single memory address.

### Precomputed Logs

We also include all logs we generated to evaluate SpecCFA with the ***TODO*** which directories

***TODO*** figure out which logs are good and which are bad

***TODO*** Describe log directory structure
