module mux2to1_forID(sel, in1, in2, muxout);
input [8:0] in1, in2;   //control 9-bit
input sel;
output logic [8:0] muxout;
assign muxout = (sel == 1'b0) ? in1 : in2;
endmodule