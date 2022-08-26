`include "Defines.svh"
`include "IDInstDef.svh"
module MEM_WB(clk, rst, stall, MEM_WB, MEM_ALU_out, MEM_Reg_rd, WB_WB, WB_ALUout, WB_Reg_rd, DM_data, DM_data_out);
input clk, rst, stall;
input [1:0] MEM_WB;
input [31:0] MEM_ALU_out;       
input [4:0] MEM_Reg_rd;
input [31:0] DM_data;
output logic [1:0] WB_WB;
output logic [31:0] WB_ALUout;  
output logic [4:0] WB_Reg_rd;
output logic [31:0] DM_data_out;
always @(posedge clk or posedge rst) begin
    if(rst)begin
        WB_WB <= 2'b00;
        WB_Reg_rd <= 5'b00000;
        WB_ALUout <= `ZeroWord;
        DM_data_out <= 32'b0;
    end
    else if(stall)
    begin
        WB_WB <= WB_WB;
        WB_Reg_rd <= WB_Reg_rd;
        WB_ALUout <= WB_ALUout;
        DM_data_out <= DM_data_out; 
    end
    else
    begin
        WB_WB <= MEM_WB;
        WB_Reg_rd <= MEM_Reg_rd;
        WB_ALUout <= MEM_ALU_out;
        DM_data_out <= DM_data; 
    end
end
endmodule
