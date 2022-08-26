module delay_FF(
    input clk, rst,
    input in,
    output logic out

);
always_ff @(posedge clk or posedge rst) begin
    if(rst)
    begin
        out <= 1'b0;
    end
    else
    begin
        out <= in;
    end
end
endmodule