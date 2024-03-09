# Parallel_Fibonacci_LFSR
This module can generate M RNG values in the same cycle, each of N-bits, utilizing XOR-based maximal Fibonacci LFSRs. The design was made during my FYP graduation project. I cleaned it a bit for uploading on GitHub.

**Parameters:-**

        -LFSR_N       :   Number of bits of base LFSR.        Range:  [1, inf)
        
        -LFSR_M       :   Number of output words each cycle.  Range:  [1, 2^N-1] (bigger values result in repetition)
                        -Note 1: This directly defines the number of combinational LFSRs.
                        -Note 2: For LFSR_M > 1, the base LFSR0's feedback is the (LFSR_M-1)'s value, i.e. the last LFSR.
        
        -LFSR_P       :   Defines the feedback polynomial mask, Hexadecimal. 
                        Refer: https://users.ece.cmu.edu/~koopman/LFSR/index.html
        
        -LFSR_R       :   LFSR reset value; cannot be 'd0

**Control Signals:-**

        -i_LFSR_en    :   Enable Signal for the whole module
        
        -i_LFSR_load  :   Load signal to insert a seed for the LFSR
        
        -i_LFSR_seed  :   Seed to be loaded, if i_LFSR_load is high. Module is initialized during reset. Size:[N-1:0]

**Input:-**

        -i_clk        :   clock
        
        -i_rst_n      :   negative-edge asynchronous reset

**Output:-**

        -o_LFSR_val   :   RNG values, each N-bits is an LFSR output word. Size:[M*N-1:0]

**References:-**
1. All possible LFSR_P values for LFSR_N < 65 : https://users.ece.cmu.edu/~koopman/lfsr/
2. Number of possible LFSR_P  for LFSR_N < 37 : https://oeis.org/A011260
3. Other HW implementations   for LFSR_N < 168: https://docs.xilinx.com/v/u/en-US/xapp052
