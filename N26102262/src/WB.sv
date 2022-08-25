`include "Defines.svh"
`include "IDInstDef.svh"
`include "mux2to1_32bit.sv"



module WB(
    input [1:0] WB,                 //WB[1]=MemtoReg,WB[0]=regwrite 
    input [31:0] memout, aluout,
    output logic [31:0] writedata
    //output logic regwrite
);

//assign regwrite = WB[0];


mux2to1_32bit WB_mux(
    .in1(memout),
    .in2(aluout),
    .sel(WB[1]),
    .out(writedata)
);

endmodule






