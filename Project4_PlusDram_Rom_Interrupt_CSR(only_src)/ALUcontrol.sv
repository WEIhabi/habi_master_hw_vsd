`include "Defines.svh"
`include "IDInstDef.svh"
module ALUcontrol(ALUsel, opcode7, func3, func7, ALUcontrol, CSRcontrol);
input [2:0] ALUsel; //  sel R, I, L_S, B, U, J operation (ALUop), connect to control EX[2:0]
input [6:0] opcode7;// pc_i [6:0]
input [2:0] func3; // pc_i [14:12]
input func7;  //pc_i [31:25] determine the difference add and sub, but only instruction[30] to determine

output logic [3:0] ALUcontrol;

//hw4 new add
output logic [2:0] CSRcontrol;


always_comb begin
    case(ALUsel)
        3'b000:begin//R-type
            case(func3)
                `FUNCT3_ADD_SUB:begin
                    if(!func7)               //add
                        ALUcontrol = 4'b0000;
                    else                     //sub
                        ALUcontrol = 4'b0001;
                end
                `FUNCT3_SLL:
                    ALUcontrol = 4'b0010;    //sll
                `FUNCT3_SLT:
                    ALUcontrol = 4'b0011;    //slt
                `FUNCT3_SLTU:
                    ALUcontrol = 4'b0100;    //sltu
                `FUNCT3_XOR:
                    ALUcontrol = 4'b0101;    //xor
                `FUNCT3_SRL_SRA:begin
                    if(!func7)               //srl
                        ALUcontrol = 4'b0110;   
                    else                     //sra
                        ALUcontrol = 4'b0111;
                end
                `FUNCT3_OR:                  //or
                    ALUcontrol = 4'b1000;
                `FUNCT3_AND:                 //and
                    ALUcontrol = 4'b1001;
            endcase
        end
        3'b001:begin//I-type
            case(func3)
                `FUNCT3_ADDI:      //func3=000
                    ALUcontrol = 4'b0000;
                `FUNCT3_SLLI:      //func3=001
                    ALUcontrol = 4'b0010;
                `FUNCT3_SLTI:     //func3=010
                    ALUcontrol = 4'b0011;
                `FUNCT3_SLTIU:     //func3=011
                    ALUcontrol = 4'b0100;
                `FUNCT3_XORI:      //func3=100
                    ALUcontrol = 4'b0101;
                `FUNCT3_SRLI_SRAI:begin //func3=101
                    if(!func7)     //srl
                        ALUcontrol = 4'b110;    
                    else           //sra
                        ALUcontrol = 4'b111;
                end
                `FUNCT3_ORI:       //func3=110
                    ALUcontrol = 4'b1000;
                `FUNCT3_ANDI:      //func3=111
                    ALUcontrol = 4'b1001;
            endcase
        end
        3'b010://LOAD and STORE type
            ALUcontrol = 4'b0000;       //add operation
        3'b011://branch type
            ALUcontrol = 4'b0001;        //sub operation
        3'b100:begin//U-type
            case(opcode7)
                `OP_AUIPC:
                    ALUcontrol = 4'b0000;//add operation
                `OP_LUI:
                    ALUcontrol = 4'b1010;//rd = imm
                default:
                    ALUcontrol = 4'b1111;
            endcase
        end
        3'b101:     //J-type
            ALUcontrol = 4'b1011;       //rd = pc + 4
        3'b110:     //JALR (I-type)
            ALUcontrol = 4'b1011;       //rd = pc + 4
        default:    //CSR-type EX[2:0] = 3'b111
            ALUcontrol = 4'b1100;
    endcase
end

always_comb begin
	case (func3)
		3'b001:  CSRcontrol = `FUNCT3_CSRRW;
		3'b010:  CSRcontrol = `FUNCT3_CSRRS;
		3'b011:  CSRcontrol = `FUNCT3_CSRRC;
		3'b101:  CSRcontrol = `FUNCT3_CSRRWI;
		3'b110:  CSRcontrol = `FUNCT3_CSRRSI;
		3'b111:  CSRcontrol = `FUNCT3_CSRRCI;
		default: CSRcontrol = `FUNCT3_MRET_WFI; //3'b000 MRET WFI
	endcase
end

endmodule