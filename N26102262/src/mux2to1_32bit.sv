`ifndef _mux2to1_32bit
`define _mux2to1_32bit 
module mux2to1_32bit(
input [31:0] in1, in2,   
input sel,
output logic [31:0] out
);
assign out = (sel == 1'b0) ? in1 : in2;

endmodule`endif
