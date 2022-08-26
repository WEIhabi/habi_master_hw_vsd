`include "Defines.svh"
`include "IDInstDef.svh"
module ALU(ALUcontrol, r1_data_i, r2_data_i, pcadd4, out, csr_src);
input [3:0] ALUcontrol;
input [31:0] r1_data_i, r2_data_i, pcadd4;
//hw4 new add 
input [31:0] csr_src;

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
        4'b0000:   //add
            out = r1_data_i + r2_data_i;
            //out = $signed(r1_data_i) + $signed(r2_data_i);
        4'b0001:   //sub
            out = r1_data_i - r2_data_i;
            //out = $signed(r1_data_i) - $signed(r2_data_i);
        4'b0010:   //sll
            out = r1_data_i << r2_data_i[4:0];
        4'b0011:   //slt
            out = {31'h0, lt_res};
        4'b0100:   //sltu
            out = {31'h0, ltu_res};
        4'b0101:  //xor
            out = r1_data_i ^ r2_data_i;
        4'b110:   //srl
            out = r1_data_i >> r2_data_i[4:0];
        4'b0111:  //sra
            //  Originally used $signed(r1_data_i) >> r2_data_i, but >> can't determine MSB is 1 extend or 0 extend
            out = y[31:0];
        4'b1000:  //or
            out = r1_data_i | r2_data_i;
        4'b1001:  //and
            out = r1_data_i & r2_data_i;
        4'b1010:   //for LUI instruction (rd=imm)
            out = r2_data_i; 
        4'b1011:   // for JALR instruction 
            out = pcadd4;
        4'b1100:   //for csr instruction
            out = csr_src;
        default:begin
            out = `ZeroWord;
        end
    endcase
end
endmodule
