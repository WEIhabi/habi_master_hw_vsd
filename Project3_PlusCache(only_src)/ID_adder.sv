`include "Defines.svh"
`include "IDInstDef.svh"

// Calculate the destination address of the branch, 
// in1 = imm , in2 = pc 
module ID_adder(in1, in2, adderout);

input [31:0] in1, in2;
output[31:0] adderout;

assign adderout = in1 + in2;



endmodule


















