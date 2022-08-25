`include "Defines.svh"
`include "IDInstDef.svh"
module MEM_WB(clk, rst, MEM_WB, MEM_ALU_out, MEM_Reg_rd, MEM_instruction, WB_WB, WB_ALUout, WB_Reg_rd, WB_instruction);
input clk, rst;
input [1:0] MEM_WB;
input [31:0] MEM_ALU_out;       //MEM_memout,
input [31:0] MEM_instruction;
input [4:0] MEM_Reg_rd;
output logic [1:0] WB_WB;
output logic [31:0] WB_ALUout;  //WB_memout, 
output logic [31:0] WB_instruction;
output logic [4:0] WB_Reg_rd;
always @(posedge clk or posedge rst) begin
    if(rst)begin
        WB_WB <= 2'b00;
        WB_Reg_rd <= 5'b00000;
        //WB_memout <= `ZeroWord;
        WB_ALUout <= `ZeroWord;
        WB_instruction <= `ZeroWord;
    end
    else
    begin
        WB_WB <= MEM_WB;
        WB_Reg_rd <= MEM_Reg_rd;
       // WB_memout <= MEM_memout;
        WB_ALUout <= MEM_ALU_out;
        WB_instruction <= MEM_instruction;
    end
end
endmodule
