`include "Defines.svh"
`include "IDInstDef.svh"
// 9/29 09:31 revise.
// No need to make any sign or unsign judgment here
module Immediate_Generator(Imm_input_Instruction, get_32bit, Imm_csr);
input [31:0] Imm_input_Instruction;
output logic [31:0] get_32bit;  //32-bit
output logic [31:0] Imm_csr;

logic [11:0] Imm_12bit;
logic [11:0] Imm_12bit_Stype;
logic [11:0] Imm_12bit_Btype;   // [0] need to fill 0 ******
logic [19:0] Imm_20bit_Utype;
logic [19:0] Imm_20bit_Jtype;   // [0] need to fill 0 ******
//hw4
//logic [31:0]  Imm_csr;

//  logic [2:0] func3;  // determine unsign instruction -> 9/29 don't determine here
logic [6:0] opcode7;
//for I-type and LOAD type
assign Imm_12bit = Imm_input_Instruction[31:20];  
//for S-type
assign Imm_12bit_Stype = {Imm_input_Instruction[31:25], Imm_input_Instruction[11:7]};   
//for B-type 
assign Imm_12bit_Btype = {Imm_input_Instruction[31], Imm_input_Instruction[7], 
                            Imm_input_Instruction[30:25],Imm_input_Instruction[11:8]};  
//for U-type
assign Imm_20bit_Utype = Imm_input_Instruction[31:12];    
//for J-type 
assign Imm_20bit_Jtype = {Imm_input_Instruction[31], Imm_input_Instruction[19:12],  
                            Imm_input_Instruction[20], Imm_input_Instruction[30:21]};
//hw4
assign Imm_csr = {27'b0, Imm_input_Instruction[19:15]};

assign opcode7 = Imm_input_Instruction[6:0];
//assign func3 = Imm_input_Instruction[14:12];
always_comb
begin
    case(opcode7)
        `OP_OPI:begin
                get_32bit = {{20{Imm_12bit[11]}}, Imm_12bit };
        end
    //LOAD same with OP_imm operation
        `OP_LOAD:begin
                get_32bit = {{20{Imm_12bit[11]}}, Imm_12bit};
        end
        `OP_STORE:begin
            //Sign Extension, Zero Sign Extension 
            get_32bit = {{20{Imm_12bit_Stype[11]}}, Imm_12bit_Stype};
        end
        `OP_BRANCH:begin    //the LSB part is 1, not 0 !!
            //Sign Extension, Zero Sign Extension 
            get_32bit = {{19{Imm_12bit_Btype[11]}}, Imm_12bit_Btype, 1'b0};
        end
        `OP_LUI:begin  // Put the unsigned 20-bit in the 31-12 bits of the rd register, and padded the lowest 12-bit with 0. 
            get_32bit = {Imm_20bit_Utype, 12'b0};
        end
        `OP_AUIPC:begin // Put the unsigned 20-bit in the 31-12 bits of the rd register, and padded the lowest 12-bit with 0.
            get_32bit = {Imm_20bit_Utype, 12'b0};
        end
        `OP_JALR:begin  //************************** special case, same with I-type, not is J-type!! **************************
            //Sign Extension, Zero Sign Extension 
            get_32bit = {{20{Imm_12bit[11]}}, Imm_12bit};
        end
        `OP_JAL:begin   //the LSB part is 1, not 0 !!
            //Sign Extension, Zero Sign Extension 
            get_32bit = {{11{Imm_20bit_Jtype[19]}}, Imm_20bit_Jtype, 1'b0};
        end
        /*
        `OP_CSR:begin
            get_32bit = Imm_csr;
        end
        */
        default:begin       // R-type and default value will come
            get_32bit = 32'b0;
        end
    endcase
end
endmodule