`ifndef _DELAY_FF_32
`define _DELAY_FF_32
module delay_FF_32bit(
    input clk, rst,
    input [31:0] in,
    output logic [31:0] out

);
always_ff @(posedge clk or posedge rst) begin
    if(rst) out <= 32'b0;
    else out <= in;
end
endmodule
`endif
