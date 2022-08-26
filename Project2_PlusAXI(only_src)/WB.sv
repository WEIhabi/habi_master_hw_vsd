`include "Defines.svh"
`include "IDInstDef.svh"
`include "mux2to1_32bit.sv"
`include "delay_FF_32bit.sv"



module WB(
    //AXU new add
    input clk, rst, /*stall,*/
    input [1:0] WB,                 //WB[1]=MemtoReg,WB[0]=regwrite 
    input [31:0] memout, aluout,
    output logic [31:0] writedata
    //output logic regwrite
);

//logic [31:0] FF_out_reg;
//logic [31:0] stall_mux_reg;
//assign regwrite = WB[0];
/*
delay_FF_32bit prepare_stall(
    .clk(clk),
    .rst(rst),
    .in(stall_mux_reg),
    .out(FF_out_reg)
);



mux2to1_32bit stall_ctrl(
    .in1(memout),
    .in2(FF_out_reg),
    .sel(stall),
    .out(stall_mux_reg)
);
*/
mux2to1_32bit WB_mux(
    .in1(memout/*stall_mux_reg*/),
    .in2(aluout),
    .sel(WB[1]),
    .out(writedata)
);

endmodule






