Project #3 (prj3) in Experiments of Computer Organization and Design (COD) in UCAS
=====
<changyisong@ict.ac.cn>
-----

## Basic MIPS CPU Benchmarks

In this project, we provide five basic benchmark suites for simulation and FPGA on-board evaluation 
of your own MIPS CPU core design. 
You can launch simulation or evaluation with a specified benchmark by explicitly setting 
parameters of benchmark suite name and serial number in MAKE command line.  

### Basic Benchmark Suite

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | memcpy | Simple memory copy function for 100 consecuitive 32-bit words |

*memcpy* benchmark in this suite is used during the 1st phase of this project in which 
implementation of 5 basic MIPS CPU instructions is required. 

### Medium Benchmark Suite

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 00 | --  | Deadlock simulation |
| 01 | sum | Calculate the summary of 1 to 100 |
| 02 | mov-c | Move data to an array |
| 03 | fib | Check fibonacci number of 2 to 40 |
| 04 | add | Check 64 additions with pre-calculated answers  |
| 05 | if-else | Check conditional jump using if-else statement |
| 06 | pascal | Calculate pascal numbers |
| 07 | quick-sort | Quick sort |
| 08 | select-sort | Selection sort |
| 09 | max | Decide the larger number |
| 10 | min3 | Decide the smallest number among the three |
| 11 | switch | Check jump instructions using switch-case statement |
| 12 | bubble-sort | Bubble sort |

Medium benchmark suite is used during the 2nd phase of this project which requires to implement 
12 more MIPS CPU instructions. 
The order of each benchmark in the above list is arranged according to the complexity and the number of leveraged instructions. 
From this point of view, benchmark *sum* is the simplest one in medium benchmark suite.   

If you want to check stability of memory datapath in your CPU design, 
please use *00* benchmark in this suite. 
In order to verify if your CPU would cause bus deadlock on real-world hardware platform, 
*sum* and *mov-c* would be launched to your CPU consecutively, with a small period to reset your CPU. 
You are encouraged to process deadlock simulation only after each benchmark in *basic*, *medium* and *advanced* 
has been seperately simulated.  

### Advanced Benchmark Suite

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | shuixianhua | Check the number of narcissistic numbers among 100 to 500 |
| 02 | sub-longlong | Check 64 subtractions on double word integers |
| 03 | bit | Simulate bit operations using shift and bit-logic operators |
| 04 | recursion | Test recursive calls |
| 05 | fact | Check factorials from 0 to 12 |
| 06 | add-longlong | Check additions on double word integers |
| 07 | shift | Test shift operations |
| 08 | wanshu | Check the perfect number from 1 to 30 |
| 09 | goldbach | Verify Goldbach's conjecture for 4 to 30 |
| 10 | leap-year | Check if it is a leap year from 1980 |
| 11 | prime | Test prime number using soft mod calculation |
| 12 | mul-longlong | Test multiplication on double word integers (soft mul) |
| 13 | load-store | Check laod and store, including unaligned memory access |
| 14 | to-lower-case | Convert ASCII character to lower case if possible |
| 15 | movsx | Check memory access on byte |
| 16 | matrix-mul | Calculate matrix multiplication (soft mul) |
| 17 | unalign | Unaligned memory access |

Advanced benchmark suite is used during the 3rd phase of this project which requires to implement 
31 more MIPS CPU instructions. 
The order of each benchmark in the above list is arranged according to the number instructions. 

## Evaluation of UART-based printf()

In this project, we provide an evaluation application running on MIPS CPU core
to leverage UART controller for the simple `printf()` function. 
All source files and scripts of this application locate in the directory of *benchmark/hello*
Students are required to implement a simple UART driver function named *puts()* located 
in *benchmark/hello/common/printf.c*. 

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | hello | Display strings on the UART console using custom designed printf() function |

## Microbench

In this project, we provide a group of large-scale benchmarks 
for evaluations with a series of custom performance counters.  

You can modify the simulation period declared 
in *benchmark/microbench/list* according to your debugging requirements.  

| **Serial Number** | **Benchmark Name** | **Description** |
| :---------------: | :----------------: | :-------------: |
| 01 | 15pz | 15-puzzle search |
| 02 | bf | Brain interpreter |
| 03 | dinic | Dinic's maxflow algorithm |
| 04 | fib | Fibonacci number |
| 05 | md5 | MD5 digest |
| 06 | qsort | Quick sort |
| 07 | Queen | Queen placement |
| 08 | sieve | Eratosthenes sieve |
| 09 | ssort | Suffix sort |

### Benchmark Compilation
Executing `make hello` or `make microbench` for cross-compilation of your specific benchmark suite. 
If you want to remove all generated files located in *benchmark/hello* or *benchmark/microbench, 
please launch `make hello_clean` or `make microbench_clean` respectively.   

## Hardware Design

### RTL Design

Please finish your RTL coding for ALU, register file and MIPS CPU first 
by editing *alu.v*, *reg_file.v* and *mips_cpu.v* respectively in the directory of 
*hardware/sources/ip_catalog/mips_core* according to 
functional requirements as described in lecture slides of this project. 
If an additional module is necessary in your design, please edit a new source file 
designated with the name of this module in *hardware/sources/ip_catalog/mips_core*
and suppliment instantiation of this module in *mips_cpu.v*.    

1. Using `make HW_ACT=rtl_chk vivado_prj`  
to recursively check syntax and synthesizability of 
all your RTL source files from the top module *mips_cpu*. 
Please carefully modify and optimize your RTL code according to 
errors and warnings you would meet in this step.  

2. If there are no errors or warnings occurring in Step 1, 
please use `make HW_ACT=sch_gen HW_VAL=<check_target> vivado_prj`  
to re-launch RTL checking in Vivado GUI mode and 
generate RTL schematics of your specified module name 
by replacing *<check_target>* to a module name located in *hardware/sources/ip_catalog/mips_core*. 
For example, if you want to generate a schematic of reg_file.v, please use  
`make HW_ACT=sch_gen HW_VAL=reg_file vivado_prj`  
The generated schematics in PDF version named *<check_target>_sch.pdf* 
are located in the directory of *hardware/vivado_out/rtl_chk*. 
You can check the generated schematics via a PDF viewer.  

### Behavioral Simulation

1. Executing `make HW_ACT=bhv_sim HW_VAL=<benchmark_suite_name>:<benchmark_serial_nubmer> vivado_prj`  
to run behavioral simulation for your MIPS CPU design using a specified benchmark. 
The valid string of *<benchmark_suite_name>* should be among *basic*, *medium*, *advanced*, *hello* and *microbench*. 
*<benchmark_serial_number>* must be a valid value according to the list of each benchmark suite.
For example, you can launch behavioral simulation of *memcpy* in *basic* benchmark suite via  
`make HW_ACT=bhv_sim HW_VAL=basic:01 vivado_prj`  
**Please note that only one valid serial number of benchmark should be used in this command**.  

2. After simulation, please use  
`make HW_ACT=wav_chk HW_VAL=bhv vivado_prj`  
to check the waveform of behavioral simulation in Vivado GUI mode. 
You can change (add or remove signals to be observed) 
the waveform configuration file (.wcfg) and save it under Vivado GUI 
when running this step. 
If you want to observe the modified waveform, please re-launch 
behavioral simulation (*HW_ACT=bhv_sim*) and waveform checking (*HW_ACT=wav_chk*). 
If you modify RTL source code to solve problems in logical design, 
please return to RTL checking (*HW_ACT=rtl_chk*) first and walk through the following steps.  

### Post-synthesis Timing Simulation

1. Executing `make HW_ACT=pst_sim HW_VAL=<benchmark_suite_name>:<benchmark_serial_nubmer> vivado_prj`  
to run post-synthesis timing simulation for your MIPS CPU design using a specified benchmark. 
The valid string of *<benchmark_suite_name>* should be among *basic*, *medium* and *advanced*. 
*<benchmark_serial_number>* must be a valid value according to the list of each benchmark suite.
For example, you can launch timing simulation of *memcpy* in *basic* benchmark suite via  
`make HW_ACT=pst_sim HW_VAL=basic:01 vivado_prj`  
**Please note that only one valid serial number of benchmark should be used in this command**. 
Please note that post-synthesis timing simulation is **NOT** supported for *hello* and *microbench* suite.  

2. After simulation, please use  
`make HW_ACT=wav_chk HW_VAL=pst vivado_prj`  
to check the waveform of timing simulation in Vivado GUI mode. 
You can change (add or remove signals to be observed) 
the waveform configuration file (.wcfg) and save it under Vivado GUI 
when running this step. 
If you want to observe the modified waveform, please re-launch 
timing simulation (*HW_ACT=pst_sim*) and waveform checking (*HW_ACT=wav_chk*). 
If you meet problems in timing simulation, please perform static timing analysis via timing report 
to optimize your RTL design and return back to the steps of RTL checking (*HW_ACT=rtl_chk*).   

### Bitstream Generation

1. If you fix logical functions of your RTL code via 
recursive execution from RTL design to post-synthesis timing simulation, 
please launch  
`make HW_ACT=bit_gen vivado_prj`  
to generate system.bit in the top-level *hw_plat* directory via automatic 
synthesis, optimization, placement and routing.  

2. Launching `make bit_bin`  
to generate the binary bitstream file (system.bit.bin) used for FPGA on-board 
evaluation later in the top-level *hw_plat* directory.   

## FPGA Evaluation

We provide an FPGA cloud infrastructure as well as a set of 
local FPGA boards for evaluation of this project, 
both of which use the same set of commands for 
hardware-software co-verification. 

1. In order to launch evaluation, please use either  
`make USER=<user_name> HW_VAL=<bench_suite_name> cloud_run`  
to connect to the FPGA cloud.  
*<bench_suite_name>* must be a valid string among *basic*, *medium*, *advanced*, *hello* and *microbench*.  

