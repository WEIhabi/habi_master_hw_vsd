`include "Defines.svh"
`include "IDInstDef.svh"
`include "PC.sv"
`include "PCadd4.sv"
`include "mux4to1.sv"
`include "IF_flush.sv"
module IF(
    input clk,
    input rst,
    input PC_write,
    input branch,
    input jump,
    input IF_ID_write,
    input [31:0] branch_target,
    input [31:0] jarl_target,
    output logic [13:0] IM_address,
    output logic [31:0] PCadd4_out,
    output logic [31:0] PC_out,
    output logic IF_flush
);
logic flush_control;
logic [31:0] PC_in_reg;        //wire
PC PC(
    .clk(clk),
    .rst(rst),
    .IM_address(IM_address),
    .PC_out(PC_out),
    .PC_write(PC_write),
    .PC_in(PC_in_reg)
);
PCadd4 PCadd4(
    .PC_out(PC_out),
    .PCadd4_Out(PCadd4_out)
);
mux4to1 mux4to1(
    .in0(PCadd4_out),
    .in1(branch_target),
    .in2(jarl_target),
    .in3(jarl_target),//I am afraid that JARL will be judged to output branch = 1 in the branch function, which will affect the output of mux.
    .out(PC_in_reg),
    .sel0(branch),
    .sel1(jump)
);
IF_flush flush(
    .branch(branch),
    .jump(jump),
    .flush(flush_control)
);
assign IF_flush = IF_ID_write & flush_control;
endmodule