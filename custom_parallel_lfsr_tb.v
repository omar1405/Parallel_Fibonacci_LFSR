/*
Engineer        :   Omar Amgad Elsayed
Title           :   N-bits M-words parallel Fibonnacci LFSR
DUT             :   custom_parallel_LFSR
Date Updated    :   2023-MAY-20 (Original Finalized Version)
Date Uploaded   :   2024-MAR-09 (GitHub Version)
*/
`timescale 10ns/1ps
module custom_parallel_lfsr_tb ();
/* TB PARAMETERS */
parameter HALF_PERIOD   =   1;
parameter PERIOD        =   2*HALF_PERIOD;

/* DUT PARAMETERS */
parameter LFSR_N        =   8;
parameter LFSR_M        =   4;
parameter LFSR_P        =   'h8E;
parameter LFSR_R        =   8'hc3;

/* DU I/O */
reg                     tb_i_clk;
reg                     tb_i_rst_n;
reg                     tb_i_LFSR_enable;
reg                     tb_i_LFSR_load;
reg [LFSR_N-1:0]        tb_i_LFSR_seed;
wire[LFSR_M*LFSR_N-1:0] tb_o_LFSR_val;
/* CLOCK */ 
initial begin
    tb_i_clk = 1'b0;
end
always #(HALF_PERIOD) tb_i_clk = ~tb_i_clk;

/* DUT*/
custom_parallel_LFSR#(
    .LFSR_N        (LFSR_N),
    .LFSR_M        (LFSR_M),
    .LFSR_P        (LFSR_P),
    .LFSR_R        (LFSR_R)
)u_custom_parallel_LFSR(
    .i_clk         ( tb_i_clk         ),
    .i_rst_n       ( tb_i_rst_n       ),
    .i_LFSR_enable ( tb_i_LFSR_enable ),
    .i_LFSR_load   ( tb_i_LFSR_load   ),
    .i_LFSR_seed   ( tb_i_LFSR_seed   ),
    .o_LFSR_val    ( tb_o_LFSR_val    )
);


/* SIMULATE */
initial begin
    tb_i_rst_n          =   1'b0;
    tb_i_LFSR_enable    =   1'b0;
    tb_i_LFSR_load      =   1'b0;
    #(PERIOD*2);
    tb_i_rst_n          =   1'b1;
    #(PERIOD);
    tb_i_rst_n          =   1'b1;
    tb_i_LFSR_enable    =   1'b1;
    tb_i_LFSR_load      =   1'b0;
    #(4*PERIOD);
    tb_i_rst_n          =   1'b1;
    tb_i_LFSR_enable    =   1'b1;
    tb_i_LFSR_load      =   1'b1;
    #(1*PERIOD);
    tb_i_LFSR_load      =   1'b0;
    #(4*PERIOD);

    $stop;
end

/*EDA PLAYGROUND BLOCK*/
/*
initial begin
    $dumpfile("dump.vcd"); $dumpvars;
end
*/

endmodule
