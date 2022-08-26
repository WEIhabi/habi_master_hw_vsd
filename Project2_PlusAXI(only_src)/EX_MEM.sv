`include "Defines.svh"
`include "IDInstDef.svh"
module EX_MEM(clk, rst, stall, EX_WB, EX_M, EX_instruction, EX_ALU_out, EX_WriteDatain, EX_Reg_rd, MEM_WB, MEM_M, MEM_ALU_out, MEM_WriteDatain, MEM_Reg_rd, MEM_instruction , HazardMuxControl, HazardMuxControl_MEM);
input clk, rst, stall,HazardMuxControl;
input [1:0] EX_WB;
input [1:0] EX_M;
input [4:0] EX_Reg_rd;
input [31:0] EX_ALU_out, EX_WriteDatain, EX_instruction;
output logic [1:0] MEM_WB;
output logic [1:0] MEM_M;
output logic [4:0] MEM_Reg_rd;
output logic [31:0] MEM_ALU_out, MEM_WriteDatain, MEM_instruction;
output logic HazardMuxControl_MEM;
always @(posedge clk or posedge rst)begin
    if(rst)begin
        MEM_WB <= 2'b00;
        MEM_M <= 2'b00;
        MEM_Reg_rd <= 5'b00000;
        MEM_ALU_out <= `ZeroWord;
        MEM_WriteDatain <= `ZeroWord;
        MEM_instruction <= `ZeroWord;
        HazardMuxControl_MEM <= 1'b0;
    end
    else if(stall)
    begin
        MEM_WB <= MEM_WB;
        MEM_M <= MEM_M;
        MEM_Reg_rd <= MEM_Reg_rd;
        MEM_ALU_out <= MEM_ALU_out;
        MEM_WriteDatain <= MEM_WriteDatain;
        MEM_instruction <= MEM_instruction;
        HazardMuxControl_MEM <= HazardMuxControl_MEM;
    end
    else
    begin
        MEM_WB <= EX_WB;
        MEM_M <= EX_M;
        MEM_Reg_rd <= EX_Reg_rd;
        MEM_ALU_out <= EX_ALU_out;
        MEM_WriteDatain <= EX_WriteDatain;
        MEM_instruction <= EX_instruction;
        HazardMuxControl_MEM <= HazardMuxControl;
    end
end
endmodule
