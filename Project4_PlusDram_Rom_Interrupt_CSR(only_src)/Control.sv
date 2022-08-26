`include "Defines.svh"
`include "IDInstDef.svh"
module Control(Instruction, opcode, EX, M, WB, j_type_flag, branch_flag, branch_or_jalr, reg_write_csr, MRET, WFI);
input [31:0] Instruction;
input [6:0]  opcode;
//input rst;
output logic [4:0] EX;      // EX = ALUsrc1, ALUsrc2  ALUsel(3bit)
output logic [1:0] M;       // M = Memread, Memwrite 
output logic [1:0] WB;      // WB = Memtoreg, Regwrite
output logic j_type_flag, branch_flag, branch_or_jalr;  //j_type_flag is actually only used by JALR. JAL jumps to the same PC value as branch, 
                                        //but when the control hazard judges, JALR has the same chance as branch stll 2 cycle case.
//hw4 new add
output logic reg_write_csr, MRET, WFI;

//logic [6:0] opcode7;
//assign opcode7 = Instruction [6:0];
always_comb begin
        case(opcode)
            `OP_R_TYPE:
            begin
                EX = 5'b00_000;           // EX[4:3] = 2'b00 is rs1 rs2 , EX[2:0] = 3'b000 is R-type caluation
                M = 2'b00;                // M[1:0]  = no read no write
                WB = 2'b11;               // WB[1] = 1 is from alu out, WB[0] = 1 is write back reg(regwrite)
                j_type_flag = 1'b0;            // No Jump
                branch_flag = 1'b0;            // No Branch
                branch_or_jalr = 1'b0;
                reg_write_csr = 1'b0;
            end
            `OP_OPI:
            begin
                EX = 5'b01_001;
                M = 2'b00;
                WB = 2'b11;
                j_type_flag = 1'b0;
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0;
                reg_write_csr = 1'b0;
            end
            `OP_STORE:
            begin
                EX = 5'b01_010;
                M = 2'b01;                  // M[1] = 0 is memread disable, M[0] = 1 is memwrite enable
                WB = 2'b00;                 // should XX (undetermine)
                j_type_flag = 1'b0;
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0;
                reg_write_csr = 1'b0;     
            end
            `OP_LOAD:
            begin
                EX = 5'b01_010;
                M = 2'b10;
                WB = 2'b01;      // WB = Memtoreg, Regwrite
                j_type_flag = 1'b0;
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0;  
                reg_write_csr = 1'b0;        
            end
            `OP_BRANCH:       // It should be done in the ID, so there should be no EX M WB control
            begin
                EX = 5'b00_011;   // **************************************** 00 not sure ****************************************
                M = 2'b00;
                WB = 2'b00;
                j_type_flag = 1'b0;
                branch_flag = 1'b1;
                branch_or_jalr = 1'b1; 
                reg_write_csr = 1'b0;
            end

            `OP_AUIPC:
            begin
                EX = 5'b11_100;   // EX[4:3] = 2'b11 is PC and imm , EX[2:0] = 3'b100 is U-type caluation 
                M = 2'b00;
                WB = 2'b11;
                j_type_flag = 1'b0;
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0;    
                reg_write_csr = 1'b0;  
            end
            `OP_LUI:
            begin
                EX = 5'b01_100;     // EX[4:3] = 2'b01 is 0(out = r2_data_i, so r1_data_i is what don't care) and imm , EX[2:0] = 3'b100 is U-type caluation
                M = 2'b00;
                WB = 2'b11;
                j_type_flag = 1'b0;
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0; 
                reg_write_csr = 1'b0;          
            end
            `OP_JALR:               // When the time comes, write the jump function and remember that the PC LSB set after PC=imm+rs1 is 1.                    
            begin
                EX = 5'b00_110;     // EX[4:3] = 2'b00 , Give it whatever you want, nothing to do with out = pcadd4
                                    // Originally is 110 JALR type, but ID stage should pass out pc jump target, so give the value 111 debug(aluop=111 is default)
                M = 2'b00;
                WB = 2'b11;
                j_type_flag = 1'b1;
                branch_flag = 1'b1;    //Count her as a branch because she will have control hazard!! 
                branch_or_jalr = 1'b1; //You have to set branch_flag to 1 to be judged by HazardDetectionUnit   
                reg_write_csr = 1'b0;
            end
            `OP_JAL:                           
            begin
                EX = 5'b00_101;         // Originally is 110 JALR type, but ID stage should pass out pc jump target, so give the value 111 debug(aluop=111 is default)
                M = 2'b00;
                WB = 2'b11;
                j_type_flag = 1'b0;     //Difference with JALR 
                branch_flag = 1'b1;
                branch_or_jalr = 1'b0;  
                reg_write_csr = 1'b0;                              
            end
            `OP_CSR:
            begin
                EX = 5'b00_111;         //EX[2:0] for ALU_ctrl sel type
                M = 2'b00;
                WB = 2'b11;
                j_type_flag = 1'b0;    
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0;  
                reg_write_csr =(Instruction[14:12] == 3'b000)? 1'b0 : 1'b1;//is MERT or WFI  
            end
            default:
            begin
                EX = 5'b00000;
                M = 2'b00;
                WB = 2'b00;
                j_type_flag = 1'b0;
                branch_flag = 1'b0;
                branch_or_jalr = 1'b0;  
                reg_write_csr = 1'b0;           
            end
        endcase
end

assign MRET = (Instruction == 32'h3020_0073)? 1'b1 : 1'b0;
assign WFI = (Instruction == 32'h1050_0073)? 1'b1 : 1'b0;

endmodule
