`ifndef _DELAY_FF_stall_control
`define _DELAY_FF_stall_control
module delay_FF_stall_control(
    input clk, rst,stall,
    input in,
    output logic out

);
always_ff @(posedge clk or posedge rst) begin
    if(rst) out <= 1'b0;
    else if(stall) out <= out;
    else out <= in;
end
endmodule
`endif
