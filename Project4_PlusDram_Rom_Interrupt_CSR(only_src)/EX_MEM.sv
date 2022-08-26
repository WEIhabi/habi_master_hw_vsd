`include "Defines.svh"
`include "IDInstDef.svh"
module EX_MEM(clk, rst, stall, EX_WB, EX_M, EX_instruction, EX_ALU_out, EX_WriteDatain, 
    EX_Reg_rd, MEM_WB, MEM_M, MEM_ALU_out, MEM_WriteDatain, MEM_Reg_rd, MEM_instruction,
    HazardMuxControl, HazardMuxControl_MEM, WFI, csr_wr_en_EX, csr_wr_en_MEM,
    csr_result_EX, csr_result_MEM, csr_addr_EX, csr_addr_MEM, interrupt_pulse, csr_forward12_EX, csr_forward12_MEM);

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

//hw4 new add
input WFI;
input               csr_wr_en_EX;
input [31:0]        csr_result_EX;
input [11:0]        csr_addr_EX;
input               interrupt_pulse;
input               csr_forward12_EX;
output logic        csr_wr_en_MEM;
output logic [31:0] csr_result_MEM;
output logic [11:0] csr_addr_MEM;
output logic        csr_forward12_MEM;




always @(posedge clk or posedge rst)begin
    if(rst)begin
        MEM_WB                  <= 2'b00;
        MEM_M                   <= 2'b00;
        MEM_Reg_rd              <= 5'b00000;
        MEM_ALU_out             <= `ZeroWord;
        MEM_WriteDatain         <= `ZeroWord;
        MEM_instruction         <= `ZeroWord;
        HazardMuxControl_MEM    <= 1'b0;
        csr_wr_en_MEM           <= 1'b0;
        csr_result_MEM          <= 32'b0;
        csr_addr_MEM            <= 12'b0;
        csr_forward12_MEM       <= 1'b0;
    end
    else if(stall || WFI && !interrupt_pulse)
    begin
        MEM_WB                  <= MEM_WB;
        MEM_M                   <= MEM_M;
        MEM_Reg_rd              <= MEM_Reg_rd;
        MEM_ALU_out             <= MEM_ALU_out;
        MEM_WriteDatain         <= MEM_WriteDatain;
        MEM_instruction         <= MEM_instruction;
        HazardMuxControl_MEM    <= HazardMuxControl_MEM;
        csr_wr_en_MEM           <= csr_wr_en_MEM;
        csr_result_MEM          <= csr_result_MEM;
        csr_addr_MEM            <= csr_addr_MEM;
        csr_forward12_MEM       <= csr_forward12_MEM;
    end
    else
    begin
        MEM_WB                  <= EX_WB;
        MEM_M                   <= EX_M;
        MEM_Reg_rd              <= EX_Reg_rd;
        MEM_ALU_out             <= EX_ALU_out;
        MEM_WriteDatain         <= EX_WriteDatain;
        MEM_instruction         <= EX_instruction;
        HazardMuxControl_MEM    <= HazardMuxControl;
        csr_wr_en_MEM           <= csr_wr_en_EX;
        csr_result_MEM          <= csr_result_EX;
        csr_addr_MEM            <= csr_addr_EX;
        csr_forward12_MEM       <= csr_forward12_EX;
    end
end
endmodule
