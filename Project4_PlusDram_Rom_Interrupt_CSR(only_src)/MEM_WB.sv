`include "Defines.svh"
`include "IDInstDef.svh"
module MEM_WB(clk, rst, stall, MEM_WB, MEM_ALU_out, MEM_Reg_rd, WB_WB, WB_ALUout, 
                WB_Reg_rd, DM_data, DM_data_out, WFI, csr_wr_en_MEM, csr_wr_en_WB,
                csr_result_MEM, csr_result_WB, csr_addr_MEM, csr_addr_WB, interrupt_pulse,
                csr_forward13_MEM, csr_forward13_WB);

input clk, rst, stall;
input [1:0] MEM_WB;
input [31:0] MEM_ALU_out;       
input [4:0] MEM_Reg_rd;
input [31:0] DM_data;

output logic [1:0] WB_WB;
output logic [31:0] WB_ALUout;  
output logic [4:0] WB_Reg_rd;
output logic [31:0] DM_data_out;

//hw4 new add 
input WFI;
input csr_wr_en_MEM;
input [31:0] csr_result_MEM;
input [11:0] csr_addr_MEM;
input interrupt_pulse;
input csr_forward13_MEM;
output logic        csr_wr_en_WB;
output logic [31:0] csr_result_WB;
output logic [11:0] csr_addr_WB;
output logic        csr_forward13_WB;


always @(posedge clk or posedge rst) begin
    if(rst)begin
        WB_WB               <= 2'b00;
        WB_Reg_rd           <= 5'b00000;
        WB_ALUout           <= `ZeroWord;
        DM_data_out         <= 32'b0;
        csr_wr_en_WB        <= 1'b0;
        csr_result_WB       <= 32'b0;
        csr_addr_WB         <= 12'b0;
        csr_forward13_WB    <= 1'b0;
    end
    else if(stall || WFI && !interrupt_pulse)
    begin
        WB_WB               <= WB_WB;
        WB_Reg_rd           <= WB_Reg_rd;
        WB_ALUout           <= WB_ALUout;
        DM_data_out         <= DM_data_out; 
        csr_wr_en_WB        <= csr_wr_en_WB;
        csr_result_WB       <= csr_result_WB;
        csr_addr_WB         <= csr_addr_WB;
        csr_forward13_WB    <= csr_forward13_WB;
    end
    else
    begin
        WB_WB               <= MEM_WB;
        WB_Reg_rd           <= MEM_Reg_rd;
        WB_ALUout           <= MEM_ALU_out;
        DM_data_out         <= DM_data; 
        csr_wr_en_WB        <= csr_wr_en_MEM;
        csr_result_WB       <= csr_result_MEM;
        csr_addr_WB         <= csr_addr_MEM;
        csr_forward13_WB    <= csr_forward13_MEM;
    end
end
endmodule
