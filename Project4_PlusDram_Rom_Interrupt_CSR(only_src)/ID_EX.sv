`include "Defines.svh"
`include "IDInstDef.svh"


//************************** maybe need to fix **************************

module ID_EX(clk, rst, stall, ID_instruction, ID_WB, ID_M, ID_EX, ID_PCadd4_Out, ID_PC, ID_reg1Data, ID_reg2Data, 
    ID_imm_value, Reg_rs1, Reg_rs2, Reg_rd, EX_instruction, EX_WB, EX_M, EX_EX, EX_PCadd4_Out, EX_PC, 
    EX_reg1Data, EX_reg2Data, EX_imm_value, Reg_rs1reg, Reg_rs2reg, Reg_rdreg, HazardMuxControl, HazardMuxControl_EX,
    Imm_csr_ID, Imm_csr_EX, csr_wr_en_ID, csr_wr_en_EX, WFI, csr_addr_ID, csr_addr_EX, csr_rs_ID, csr_rs_EX, interrupt_pulse);

input clk,rst,stall, HazardMuxControl;
input [1:0] ID_WB;
input [1:0] ID_M;
input [4:0] ID_EX;
input [4:0] Reg_rs1, Reg_rs2, Reg_rd;       // for forwarding
input [31:0] ID_reg1Data, ID_reg2Data, ID_imm_value, ID_PCadd4_Out , ID_PC, ID_instruction;

//hw4 new add
input        WFI; 
input [31:0] Imm_csr_ID;
input        csr_wr_en_ID;
input [11:0] csr_addr_ID;
input [31:0] csr_rs_ID;
input interrupt_pulse;

output  logic HazardMuxControl_EX;
output  logic [1:0] EX_WB;
output  logic [1:0] EX_M;
output  logic [4:0] EX_EX;  //maybe change, because my ALUop(sel) is 3bit, plus ALUsrc1 ALUsrc2 = 5bit!!
output  logic [4:0] Reg_rs1reg, Reg_rs2reg, Reg_rdreg;
output  logic [31:0] EX_reg1Data, EX_reg2Data, EX_imm_value, EX_PCadd4_Out, EX_PC, EX_instruction;

//hw4 new add
output  logic [31:0] Imm_csr_EX;
output  logic        csr_wr_en_EX;
output  logic [11:0] csr_addr_EX;
output  logic [31:0] csr_rs_EX;



always @(posedge clk or posedge rst) begin
    if(rst)begin
        EX_instruction <= `ZeroWord;
        EX_WB               <= 2'b00;
        EX_M                <= 2'b00;
        EX_EX               <= 5'b00000;
        EX_PCadd4_Out       <= `ZeroWord;
        EX_PC               <= `ZeroWord;
        Reg_rs1reg          <= 5'b00000;
        Reg_rs2reg          <= 5'b00000;
        Reg_rdreg           <= 5'b00000;
        EX_reg1Data         <= `ZeroWord;
        EX_reg2Data         <= `ZeroWord;
        EX_imm_value        <= `ZeroWord;
        HazardMuxControl_EX <= 1'b0;
        Imm_csr_EX          <= 32'b0;
        csr_wr_en_EX        <= 1'b0;
        csr_addr_EX         <= 12'b0;
        csr_rs_EX           <= 32'b0;
    end
    else if(stall || WFI && !interrupt_pulse)
    begin
        EX_instruction <= EX_instruction;
        EX_WB               <= EX_WB;
        EX_M                <= EX_M;
        EX_EX               <= EX_EX;
        EX_PCadd4_Out       <= EX_PCadd4_Out;
        EX_PC               <= EX_PC;
        Reg_rs1reg          <= Reg_rs1reg;
        Reg_rs2reg          <= Reg_rs2reg;
        Reg_rdreg           <= Reg_rdreg;
        EX_reg1Data         <= EX_reg1Data;
        EX_reg2Data         <= EX_reg2Data;
        EX_imm_value        <= EX_imm_value;
        HazardMuxControl_EX <= HazardMuxControl_EX;
        Imm_csr_EX          <= Imm_csr_EX;
        csr_wr_en_EX        <= csr_wr_en_EX;
        csr_addr_EX         <= csr_addr_EX;
        csr_rs_EX           <= csr_rs_EX;
    end
    else
    begin
        EX_instruction      <= ID_instruction;
        EX_WB               <= ID_WB;
        EX_M                <= ID_M;
        EX_EX               <= ID_EX;
        EX_PCadd4_Out       <= ID_PCadd4_Out;
        EX_PC               <= ID_PC;
        Reg_rs1reg          <= Reg_rs1;
        Reg_rs2reg          <= Reg_rs2;
        Reg_rdreg           <= Reg_rd;
        EX_reg1Data         <= ID_reg1Data;
        EX_reg2Data         <= ID_reg2Data;
        EX_imm_value        <= ID_imm_value;
        HazardMuxControl_EX <= HazardMuxControl;
        Imm_csr_EX          <= Imm_csr_ID;
        csr_wr_en_EX        <= csr_wr_en_ID;
        csr_addr_EX         <= csr_addr_ID;
        csr_rs_EX           <= csr_rs_ID;
    end
end


endmodule
