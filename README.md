# Parallel_Fibonacci_LFSR
This module can generate M RNG values in the same cycle, each of N-bits, utilizing XOR-based maximal Fibonacci LFSRs. The design was made during my FYP graduation project in 2023. I cleaned it a bit and uploaded it on GitHub, with its testbench. 


## Module Top View

![alt text](/custom_parallel_lfsr_io.drawio.png "Top View")


## Module I/O

| Name           | Mode  | Width | Discription |
|:-------------- |:-----:|:-----:|:------------------------------------------:|
| `i_clk`        |  in   |   1   | LFSR Clock                                 |
| `i_rst_n`      |  in   |   1   | Negative-edge Asynchronous Reset.          |
| `i_LFSR_enable`|  in   |   1   | Enable Signal for the whole module.        |
| `i_LFSR_load`  |  in   |   1   | Load signal to insert a seed for the LFSR. |
| `i_LFSR_seed`  |  in   |   N   | Seed to be loaded, if `i_LFSR_load` is high. |
| `o_LFSR_val`   |  out  |  M*N  | Every N bits represent an LFSR output value. Refer Note 1|


## Parameters

| Parameter      | #Bits  | Description                                                    | Range         |  Notes |
|:-------------- |:------:|:--------------------------------------------------------------:|:-------------:|:------:|
|`LFSR_N`        | -      |Number of bits of base LFSR.                                    |   N/A         |   -    | 
|`LFSR_M`        | -      |Number of output words each cycle.                              |$[1,2^{N}-1]$  | 2,3,4  |
|`LFSR_P`        |`LFSR_N`|Defines the feedback polynomial mask.                           |$[1,2^{N}-1]$  | 5      |
|`LFSR_R`        |`LFSR_N`|Reset Value; Cannot be 0 since XOR is being used in this design.| $!=0$         |   -    |


## Notes
1. Output pins are made as a vector instead of a 2D array due to Verilog Limitations.
2. Bigger values result in repetition.
3. This directly defines the number of combinational LFSRs.
4. For `LFSR_M` > 1, the base LFSR0's feedback is the (LFSR_M-1)'s value, i.e. the last LFSR.
5. Quick Reference: https://users.ece.cmu.edu/~koopman/lfsr/


## Module Internal View

![alt text](/custom_parallel_lfsr_internal.drawio.png "Internal View")


## References
1. All possible LFSR_P values for `LFSR_N` < 65 : https://users.ece.cmu.edu/~koopman/lfsr/
2. Number of possible LFSR_P  for `LFSR_N` < 37 : https://oeis.org/A011260
3. Other HW implementations   for `LFSR_N` < 168: https://docs.xilinx.com/v/u/en-US/xapp052

