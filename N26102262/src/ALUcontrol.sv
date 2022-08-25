`include "Defines.svh"
`include "IDInstDef.svh"
module ALUcontrol(ALUsel, opcode7, func3, func7, ALUcontrol);
input [2:0] ALUsel; //  sel R, I, L_S, B, U, J operation (ALUop), connect to control EX[2:0]
input [6:0] opcode7;// pc_i [6:0]
input [2:0] func3; // pc_i [14:12]
input func7;  //pc_i [31:25] determine the difference add and sub, but only instruction[30] to determine
output logic [3:0] ALUcontrol;
always_comb begin
    case(ALUsel)
        3'b000:begin//R-type
            case(func3)
                `FUNCT3_ADD_SUB:begin
                    if(!func7)begin  //  add
                        ALUcontrol = 4'b0000;
                    end
                    else
                    begin                   //sub
                        ALUcontrol = 4'b0001;
                    end
                end
                `FUNCT3_SLL:begin
                    ALUcontrol = 4'b0010;    //sll
                end
                `FUNCT3_SLT:begin
                    ALUcontrol = 4'b0011;    //slt
                end
                `FUNCT3_SLTU:begin
                    ALUcontrol = 4'b0100;    //sltu
                end
                `FUNCT3_XOR:begin
                    ALUcontrol = 4'b0101;    //xor
                end
                `FUNCT3_SRL_SRA:begin
                    if(!func7)begin  //srl
                        ALUcontrol = 4'b0110;
                    end       
                    else
                    begin                   //sra
                        ALUcontrol = 4'b0111;
                    end
                end
                `FUNCT3_OR:begin            //or
                    ALUcontrol = 4'b1000;
                end
                `FUNCT3_AND:begin            //and
                    ALUcontrol = 4'b1001;
                end
                /*default:begin
                    ALUcontrol = 4'b1111;     //default value
                end*/
            endcase
        end
        3'b001:begin//I-type
            case(func3)
                `FUNCT3_ADDI:begin      //func3=000
                    ALUcontrol = 4'b0000;
                end
                `FUNCT3_SLLI:begin      //func3=001
                    ALUcontrol = 4'b0010;        
                end
                `FUNCT3_SLTI:begin      //func3=010
                    ALUcontrol = 4'b0011;
                end
                `FUNCT3_SLTIU:begin     //func3=011
                    ALUcontrol = 4'b0100;
                end
                `FUNCT3_XORI:begin      //func3=100
                    ALUcontrol = 4'b0101;
                end
                `FUNCT3_SRLI_SRAI:begin //func3=101
                    if(!func7)begin      //srl
                        ALUcontrol = 4'b110;    
                    end
                    else
                    begin                       //sra
                        ALUcontrol = 4'b111;
                    end
                end
                `FUNCT3_ORI:begin       //func3=110
                    ALUcontrol = 4'b1000;
                end
                `FUNCT3_ANDI:begin      ////func3=111
                    ALUcontrol = 4'b1001;
                end
                /*default:begin
                    ALUcontrol = 4'b1111;
                end*/
            endcase
        end
        3'b010:begin//LOAD and STORE type
            ALUcontrol = 4'b0000;       //add operation
        end
            
        3'b011:begin//branch type
            ALUcontrol = 4'b0001;        //sub operation
        end
        3'b100:begin//U-type
            case(opcode7)
                `OP_AUIPC:begin
                    ALUcontrol = 4'b0000;//add operation
                end
                `OP_LUI:begin
                    ALUcontrol = 4'b1010;//rd = imm
                end
                default:begin
                    ALUcontrol = 4'b1111;
                end
            endcase
        end
        3'b101:begin//J-type
            ALUcontrol = 4'b1011;       //rd = pc + 4
        end

        3'b110:begin//JALR (I-type)
            ALUcontrol = 4'b1011;       //rd = pc + 4
        end

        default:begin
            ALUcontrol = 4'b1111;
        end
    endcase
end
endmodule