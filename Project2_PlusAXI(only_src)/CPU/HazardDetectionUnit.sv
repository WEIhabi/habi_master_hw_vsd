`include "Defines.svh"
`include "IDInstDef.svh"
module HazardDetectionUnit(rst, PC_write, IF_ID_write, HazardMuxControl, branch_or_jalr, ID_EX_memRead, EX_MEM_memRead, EX_RegWrite, MEM_RegRd, EX_RegRd, ID_RegRs1, ID_RegRs2);
//rs1=rs,rs2=rt(compare with mips)
input [4:0]  MEM_RegRd, EX_RegRd, ID_RegRs1, ID_RegRs2;
input branch_or_jalr, ID_EX_memRead, EX_MEM_memRead, EX_RegWrite, rst;       //branch_flag
output logic PC_write, IF_ID_write, HazardMuxControl;//need ID_flush??
always_comb begin
    if( ( branch_or_jalr || ID_EX_memRead ) && ((EX_RegRd == ID_RegRs1) || (EX_RegRd == ID_RegRs2)) && EX_RegWrite) begin // stall 1 cycle case
        PC_write = 1'b0;
        IF_ID_write = 1'b0;
        HazardMuxControl = 1'b0;
    end
    else if( branch_or_jalr && EX_MEM_memRead && ((MEM_RegRd == ID_RegRs1) || (MEM_RegRd == ID_RegRs2))) begin //stall 2 cycle case
        //This situation will occur when the next time comes in after the stall 1 cycle case, 
        //or the general load command in the rd of the MEM is the same as the branch in the rs1 or rs2 of the ID stage.
        PC_write = 1'b0;
        IF_ID_write = 1'b0;
        HazardMuxControl = 1'b0;
    end
    else
    begin   //no stall
        PC_write = 1'b1;
        IF_ID_write = 1'b1;
        HazardMuxControl = 1'b1;    //control enable
    end
end
endmodule
