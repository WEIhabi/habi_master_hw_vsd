module ForwardingUnit(MEM_RegRd, WB_RegRd, EX_RegRs, EX_RegRt, MEM_RegWrite, WB_RegWrite, Forward_A, Forward_B);
input MEM_RegWrite, WB_RegWrite;
input [4:0] MEM_RegRd, WB_RegRd, EX_RegRs, EX_RegRt;
output logic [1:0] Forward_A, Forward_B;
//Forward_A
always_comb begin 
    if((MEM_RegWrite) && (MEM_RegRd != 5'b0) && (MEM_RegRd == EX_RegRs))
        Forward_A = 2'b10;
    else if((WB_RegWrite) && (WB_RegRd != 5'b0) && (WB_RegRd == EX_RegRs) && ((MEM_RegRd != EX_RegRs) || (MEM_RegWrite == 1'b0)))
    // avoid lw nop error case (MEM_RegWrite == 1'b0)
    // add in "(MEM_RegRd != EX_RegRs)" to prevent this case!!
    // (MEM/WB) add $1, $1, $2
    // (EX/MEM) add $1, $1, $3
    // (ID/EX)  add $1, $1, $4  
    // Avoid three consecutive instructions without knowing whether to do EXE hazard or MEM hazard first!
        Forward_A = 2'b01;
    else 
        Forward_A = 2'b00;
end
//Forward_B
always_comb begin
    if((MEM_RegWrite) && (MEM_RegRd != 5'b0) && (MEM_RegRd == EX_RegRt))
        Forward_B = 2'b10;
     
    else if((WB_RegWrite) && (WB_RegRd != 5'b0) && (WB_RegRd == EX_RegRt) && ((MEM_RegRd != EX_RegRt) || (MEM_RegWrite == 1'b0)))
    // add in "(MEM_RegRd != EX_RegRs)" to prevent this case!!
    // (MEM/WB) add $1, $1, $2
    // (EX/MEM) add $1, $1, $3
    // (ID/EX)  add $1, $1, $4  
    // Avoid three consecutive instructions without knowing whether to do EXE hazard or MEM hazard first!
        Forward_B = 2'b01;
    else 
        Forward_B = 2'b00;
end
endmodule