`include "Defines.svh"
`include "IDInstDef.svh"
module branch_function (branch_flag, ID_comparator, func3, branch, opcode7);
input branch_flag;
input [2:0] ID_comparator;
input [2:0] func3;
input [6:0] opcode7;      //difference_jalr_and_beq opcode[2] different
// ID_comparator[0]=1 is data1 == data2
// ID_comparator[1]=1 is data1 < data2 
// ID_comparator[2] = $unsigned( Data1) < $unsigned( Data2 );
output logic branch;
logic out_reg;
// Assuming that there is an error in the end, it may be to do more opcode judgments of JALR and BEQ
always_comb begin
    if(branch_flag)begin
        if(opcode7 == `OP_JAL)begin
            out_reg = 1'b1;
        end
        else
        begin
            case(func3)
                //JALR[2]=1 , difference_jalr_and_beq
                `FUNCT3_BEQ:
                begin
                    if(opcode7[2] == 1'b0)begin//beq
                    //BEQ func3 is the same as JALR func3 and branch_flag is 1, but JALR should not have two data comparable, 
                        out_reg = ID_comparator[0];      // equal test, if equal ID_comparator[0] = 1
                    end
                    else
                    begin
                        out_reg = 1'b0; //JALR
                    end
                end
                `FUNCT3_BNE:
                    out_reg = ~ID_comparator[0];     // non equal test, if non equal ID_comparator[0] = 0
                `FUNCT3_BLT:
                    out_reg = ID_comparator[1];      // if data1 < data2, then ID_comparator[1] = 1
                `FUNCT3_BGE:
                    out_reg = ~ID_comparator[1];     // if data1 >= data2, then ID_comparator[1] = 0
                `FUNCT3_BLTU:
                    out_reg = ID_comparator[2];      // if data1 < data2, then ID_comparator[2] = 1
                `FUNCT3_BGEU:
                    out_reg = ~ID_comparator[2];     // if data1 < data2, then ID_comparator[2] = 0
                default:
                    out_reg = 1'b0;
            endcase
        end

    end
    else
    begin
        out_reg = 1'b0;
    end
end
assign branch = out_reg & branch_flag;//JALR can't jump in here
endmodule