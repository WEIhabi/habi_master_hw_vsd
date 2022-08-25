`ifndef _mux4to1
`define _mux4to1

module mux4to1(out, in0, in1, in2, in3, sel1, sel0);
input [31:0] in0, in1, in2, in3;
input sel1, sel0;
output logic [31:0] out;
always_comb begin
    case({sel1,sel0})
        2'b00: out = in0;
        2'b01: out = in1;
        2'b10: out = in2;
        2'b11: out = in3;
    endcase
end
endmodule
`endif
