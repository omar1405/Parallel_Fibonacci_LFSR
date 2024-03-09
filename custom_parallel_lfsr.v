/////////////////////////////////////////////////////////////////////
/*
Engineer        :   Omar Amgad Elsayed
Title           :   N-bits M-words parallel Fibonnacci LFSR
Module          :   custom_parallel_LFSR
Date Updated    :   2023-MAY-20 (Original Finalized Version)
Date Uploaded   :   2024-MAR-09 (GitHub Version)
Description     :   
    This module can generate M RNG values in the same cycle, each of 
    N-bits, utilizing XOR-based maximal Fibonacci LFSRs. The design was made 
    during my FYP graduation project. I cleaned it a bit for uploading on GitHub.
    *Parameters:-
        -LFSR_N     :   Number of bits of base LFSR.        Range:  [1, inf)
        
        -LFSR_M     :   Number of output words each cycle.  Range:  [1, 2^N-1] (bigger values result in repetition)
                        -Note1: 
                            This directly defines the number of combinational LFSRs.
                        -Note2: 
                            For LFSR_M > 1, the base LFSR0's feedback 
                            is the (LFSR_M-1)'s value, i.e. the last LFSR.
        -LFSR_P     :   Defines the feedback polynomial mask, Hexadecimal. 
                        Refer: https://users.ece.cmu.edu/~koopman/LFSR/index.html
        -LFSR_R     :   LFSR reset value; cannot be 'd0
    *Control Signals:-
        -i_LFSR_en    :   Enable Signal for the whole module
        -i_LFSR_load  :   Load signal to insert a seed for the LFSR
        -i_LFSR_seed  :   Seed to be loaded, if i_LFSR_load is high. Module is initialized during reset. Size:[N-1:0]
    *Input:-
        -i_clk      :   clock
        -i_rst_n    :   negative-edge asynchronous reset
    *Output:  
        -o_LFSR_val :   RNG values, each N-bits is an LFSR output word. Size:[M*N-1:0]
    *References: 
        -All possible LFSR_P values for LFSR_N < 65  : https://users.ece.cmu.edu/~koopman/lfsr/
        -Number of possible LFSR_P  for LFSR_N < 37  : https://oeis.org/A011260
        -Other HW implementations   for LFSR_N < 168 : https://docs.xilinx.com/v/u/en-US/xapp052
Instantiation   :
custom_parallel_LFSR#(
    .LFSR_N        ( 8 ),
    .LFSR_M        ( 4 ),
    .LFSR_P        ( 'h8E ), // no. of bits = LFSR_N
    .LFSR_R        ( 'hc3 ) // no. of bits = LFSR_N
)u_custom_parallel_LFSR(
    .i_clk         ( i_clk         ),
    .i_rst_n       ( i_rst_n       ),
    .i_LFSR_enable ( i_LFSR_enable ),
    .i_LFSR_load   ( i_LFSR_load   ),
    .i_LFSR_seed   ( i_LFSR_seed   ),
    .o_LFSR_val    ( o_LFSR_val    )
);
*/
/////////////////////////////////////////////////////////////////////


module custom_parallel_LFSR #(
    parameter LFSR_N    =   8,
    parameter LFSR_M    =   4,
    parameter LFSR_P    =   'h8E,
    parameter LFSR_R    =   'hc3  //cannot be 'd0
) (
    input                       i_clk,
    input                       i_rst_n,
    input                       i_LFSR_enable,
    input                       i_LFSR_load,
    input  [LFSR_N-1:0]         i_LFSR_seed,
    output [LFSR_M*LFSR_N-1:0]  o_LFSR_val
);
/* 
Polynomial bits are masked via XOR-ing LFSR values with LFSR_P directly.
This works becuase:
(1) A^b^0=A^B
(2) A^b^1=~(A^B)
*/
localparam LFSR_MASK = LFSR_P[LFSR_N-1:0];  //make sure mask is only LFSR_N-bits.
reg [LFSR_N-1:0]    LFSR0;
reg [LFSR_N-1:0]    r_LFSR_results  [0:LFSR_M-1];

wire[LFSR_N-1:0]    w_LFSR_next_val [0:LFSR_M-1];
wire                w_LFSR_next_0   [0:LFSR_M-1];
wire[LFSR_N-1:0]    w_LFSR0_next_val;


genvar i;
// Next values for the LFSRs
generate
    // for the first LFSR
    assign w_LFSR_next_0  [0]   =   ^(LFSR0 & LFSR_MASK);                      //xor mask for feedback
    assign w_LFSR_next_val[0]   =   {LFSR0[LFSR_N-2:0], w_LFSR_next_0[0]};  //shifting
    assign w_LFSR0_next_val     =   (i_LFSR_load)?(i_LFSR_seed):(w_LFSR_next_val[LFSR_M-1]);
    // for the rest of the LFSRs
    for (i = 1; i < LFSR_M; i = i + 1) begin
        assign w_LFSR_next_0  [i]   =   ^(w_LFSR_next_val[i-1] & LFSR_MASK);                        //xor mask for feedback
        assign w_LFSR_next_val[i]   =   {w_LFSR_next_val[i-1][LFSR_N-2:0], w_LFSR_next_0[i]};   //shifting
    end
endgenerate

integer k,m;
// Current values for LFSRs
always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
        for (k = 0; k < LFSR_M; k = k + 1) begin
            r_LFSR_results[k]  <=  LFSR_R;
        end
    end else begin
        if (i_LFSR_enable && !i_LFSR_load) begin
            for (m = 0; m < LFSR_M; m = m + 1) begin
                r_LFSR_results[m] <= w_LFSR_next_val[m];
            end
        end
    end
end

genvar j;
// Output 
//  -conversion from 2D-array to 1D-vector, due to Verilog limitations; unlike SystemVerilog.
generate
    for (j = 0; j < LFSR_M; j = j + 1) begin
        assign o_LFSR_val[j*LFSR_N +: LFSR_N] = r_LFSR_results[j];
    end
endgenerate



 assign w_feedback_bit =^(LFSR0 & LFSR_MASK); 
//  assign o_LFSR_val = LFSR0;
//Main LFSR
 always @(posedge i_clk, negedge i_rst_n) begin
     if (!i_rst_n) begin
         LFSR0 <= LFSR_R; //cannot be 0
     end else begin
         if (i_LFSR_enable == 1'b1) begin
            LFSR0   <=  w_LFSR0_next_val; //either last lfsr_val or new seed
         end else begin
            LFSR0 <= LFSR0;
         end
     end
 end

endmodule
