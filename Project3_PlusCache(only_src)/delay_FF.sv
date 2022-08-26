`ifndef _DELAY_FF
`define _DELAY_FF
module delay_FF(
    input clk, rst,
    input in,
    output logic out

);
always_ff @(posedge clk or posedge rst) begin
    if(rst) out <= 1'b0;
    else out <= in;
end
endmodule
`endif
