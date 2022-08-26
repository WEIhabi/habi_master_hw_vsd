`include "Defines.svh"
`include "IDInstDef.svh"
module ALU(ALUcontrol, r1_data_i, r2_data_i, pcadd4, out);
input [3:0] ALUcontrol;
input [31:0] r1_data_i, r2_data_i, pcadd4;
output logic [31:0] out;
logic ltu_res;
logic lt_res;
logic [63:0] y;
//assign lt_res = ( $signed(r1_data_i) < $signed(r2_data_i) ) ? 1 : 0;    //compare signed number magnitude
//assign ltu_res = ( r1_data_i < r2_data_i ) ? 1 : 0;                     //compare unsigned number magnitude
assign y = ({32{r1_data_i[31]}} << (6'd32 - {1'b0,r2_data_i[4:0]})) | r1_data_i >> r2_data_i[4:0];    // Ref :github 



always_comb begin 
    if( $signed(r1_data_i) < $signed(r2_data_i))
        lt_res = 1'b1;
    else
        lt_res = 1'b0;
end

always_comb begin 
    if( r1_data_i < r2_data_i)
        ltu_res = 1'b1;
    else
        ltu_res = 1'b0;
end





always_comb begin 
    case(ALUcontrol)
        4'b0000:begin   //add
            out = r1_data_i + r2_data_i;
            //out = $signed(r1_data_i) + $signed(r2_data_i);
        end
        4'b0001:begin   //sub
            out = r1_data_i - r2_data_i;
            //out = $signed(r1_data_i) - $signed(r2_data_i);
        end
        4'b0010:begin   //sll
            out = r1_data_i << r2_data_i[4:0];
        end
        4'b0011:begin   //slt
            out = {31'h0, lt_res};
        end
        4'b0100:begin   //sltu
            out = {31'h0, ltu_res};
        end
        4'b0101:begin  //xor
            out = r1_data_i ^ r2_data_i;
        end
        4'b110:begin   //srl
            out = r1_data_i >> r2_data_i[4:0];
        end
        4'b0111:begin  //sra
            //  Originally used $signed(r1_data_i) >> r2_data_i, but >> can't determine MSB is 1 extend or 0 extend
            out = y[31:0];
        end
        4'b1000:begin  //or
            out = r1_data_i | r2_data_i;
        end
        4'b1001:begin  //and
            out = r1_data_i & r2_data_i;
        end
        4'b1010:begin   //for LUI instruction (rd=imm)
            out = r2_data_i; 
        end
        4'b1011:begin   // for JALR instruction 
            out = pcadd4;
            //pc = imm + rs1 
        end
        default:begin
            out = `ZeroWord;
        end
    endcase
end
endmodule
