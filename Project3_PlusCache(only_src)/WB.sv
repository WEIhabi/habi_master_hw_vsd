`include "Defines.svh"
`include "IDInstDef.svh"
`include "mux2to1_32bit.sv"
`include "delay_FF_32bit.sv"



module WB(
    //AXU new add
    input clk, rst,
    input [1:0] WB,                 //WB[1]=MemtoReg,WB[0]=regwrite 
    input [31:0] memout, aluout,
    output logic [31:0] writedata
    //output logic regwrite
);

mux2to1_32bit WB_mux(
    .in1(memout),
    .in2(aluout),
    .sel(WB[1]),
    .out(writedata)
);

endmodule






