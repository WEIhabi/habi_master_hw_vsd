`include "Defines.svh"
`include "IDInstDef.svh"


//************************** maybe need to fix **************************

module ID_EX(clk, rst , ID_instruction, ID_WB, ID_M, ID_EX, ID_PCadd4_Out, ID_PC, ID_reg1Data, ID_reg2Data, ID_imm_value, Reg_rs1, Reg_rs2, 
    Reg_rd, EX_instruction, EX_WB, EX_M, EX_EX, EX_PCadd4_Out, EX_PC, EX_reg1Data, EX_reg2Data, EX_imm_value, Reg_rs1reg, Reg_rs2reg, Reg_rdreg);

input clk,rst;
input [1:0] ID_WB;
input [1:0] ID_M;
input [4:0] ID_EX;
input [4:0] Reg_rs1, Reg_rs2, Reg_rd;       // for forwarding
input [31:0] ID_reg1Data, ID_reg2Data, ID_imm_value, ID_PCadd4_Out , ID_PC, ID_instruction;

output  logic [1:0] EX_WB;
output  logic [1:0] EX_M;
output  logic [4:0] EX_EX;  //maybe change, because my ALUop(sel) is 3bit, plus ALUsrc1 ALUsrc2 = 5bit!!
output  logic [4:0] Reg_rs1reg, Reg_rs2reg, Reg_rdreg;
output  logic [31:0] EX_reg1Data, EX_reg2Data, EX_imm_value, EX_PCadd4_Out, EX_PC, EX_instruction;

always @(posedge clk or posedge rst) begin
    if(rst)begin
        EX_instruction <= `ZeroWord;
        EX_WB <= 2'b00;
        EX_M <= 2'b00;
        EX_EX <= 5'b00000;
        EX_PCadd4_Out <= `ZeroWord;
        EX_PC <= `ZeroWord;
        Reg_rs1reg <= 5'b00000;
        Reg_rs2reg <= 5'b00000;
        Reg_rdreg <= 5'b00000;
        EX_reg1Data <= `ZeroWord;
        EX_reg2Data <= `ZeroWord;
        EX_imm_value <= `ZeroWord;
    end
    else
    begin
        EX_instruction <= ID_instruction;
        EX_WB <= ID_WB;
        EX_M <= ID_M;
        EX_EX <= ID_EX;
        EX_PCadd4_Out <= ID_PCadd4_Out;
        EX_PC <= ID_PC;
        Reg_rs1reg <= Reg_rs1;
        Reg_rs2reg <= Reg_rs2;
        Reg_rdreg <= Reg_rd;
        EX_reg1Data <= ID_reg1Data;
        EX_reg2Data <= ID_reg2Data;
        EX_imm_value <= ID_imm_value;
    end
end


endmodule
