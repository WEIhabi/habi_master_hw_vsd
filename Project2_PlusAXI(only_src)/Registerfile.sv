`include "Defines.svh"
`include "IDInstDef.svh"
module Registerfile(clk, rst, read_reg1, read_reg2, write_reg, write_data, read_data1, read_data2, regWrite);
//input
input clk, rst;
input [4:0] read_reg1, read_reg2;// 5bit
input [4:0] write_reg;
input regWrite;
input [31:0] write_data;
//output
output logic[31:0] read_data1, read_data2;// 32bit
logic [31:0] regFile [31:0]; //regfile size is 32 X 32 bit
//Don't let read data take a cycle!(use combination logic)
assign read_data1 = regFile[read_reg1]; // read 32-bit data
assign read_data2 = regFile[read_reg2]; // read 32-bit data
always @(posedge clk or posedge rst) begin
    if(rst)
    begin
        for (int i = 0; i<32; i++) 
        begin
            regFile[i] <= `ZeroWord; //setup all register = 32'h0
        end
    end
    else
    begin
        if((regWrite) && (write_reg != 5'h0)) begin            //may wrong!!
        //regWrite == 1, write data ,read is default ( Reading all the time )
        //can not write reg0 (because x0 reg always = 0)
            regFile[write_reg] <= write_data;
        end
        else
            regFile[0] <= 0;
    end 
end
endmodule