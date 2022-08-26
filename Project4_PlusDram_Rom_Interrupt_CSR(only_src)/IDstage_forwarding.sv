module IDstage_forwarding(branch_or_jalr, Forward_A, Forward_B, ID_RegRs, ID_RegRt, MEM_RegRd, WB_RegRd, MEM_RegWrite, WB_RegWrite);

input branch_or_jalr, MEM_RegWrite, WB_RegWrite;
input [4:0] ID_RegRs, ID_RegRt, MEM_RegRd, WB_RegRd;

output logic [1:0] Forward_A, Forward_B;

//Forward_A
always_comb begin
    if((branch_or_jalr && MEM_RegWrite) && (MEM_RegRd != 5'd0) && (MEM_RegRd == ID_RegRs) )
        Forward_A = 2'b10;

    else if((WB_RegWrite) && (WB_RegRd != 5'd0) && (WB_RegRd == ID_RegRs) && (MEM_RegRd != ID_RegRs))
        Forward_A = 2'b01;
    else 
        Forward_A = 2'b00;
end


//Forward_B
always_comb begin
    if((branch_or_jalr) && (MEM_RegWrite) && (MEM_RegRd != 5'd0) && (MEM_RegRd == ID_RegRt))
        Forward_B = 2'b10;
    else if((WB_RegWrite) && (WB_RegRd != 5'd0) && (WB_RegRd == ID_RegRt) && (MEM_RegRd != ID_RegRt))
        Forward_B = 2'b01;  
    else 
        Forward_B = 2'b00;
end



endmodule

