`include "Defines.svh"
`include "IDInstDef.svh"
module PC(IM_address, stall, PC_out, clk, rst, PC_write, PC_in);
//input
input clk, rst, PC_write, stall;
input [`PC_addr] PC_in;
//output
output logic [31:0] IM_address; // address 14 bit
output logic [`PC_addr] PC_out; // 32-bit
always @(posedge clk or posedge rst) begin
    if (rst)        PC_out <= `ZeroWord;
    else if(stall)  PC_out <= PC_out;
    else    PC_out <= (PC_write == `WriteEnable)? PC_in : PC_out;
    /*begin
        if (PC_write == `WriteEnable)
            PC_out <= PC_in;
        else// when PC_write = 0, load data hazard stall the value
            // How to write when PC_write = 0 to keep the data
            PC_out <= PC_out;//PC_in - 32'h0000_0004;   // *******not sure*******
    end*/
end
assign IM_address = PC_out/* [15:2]*/;  
// IM_address pull out cpu module and connect with IM module input!
endmodule















