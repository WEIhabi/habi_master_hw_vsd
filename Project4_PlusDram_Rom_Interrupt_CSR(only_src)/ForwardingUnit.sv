`include "Defines.svh"
`include "IDInstDef.svh"

module ForwardingUnit(MEM_RegRd, WB_RegRd, EX_RegRs, EX_RegRt, MEM_RegWrite, WB_RegWrite, 
    Forward_A, Forward_B, ID_instruction, EX_instruction, MEM_instruction, csr_addr_ID, csr_addr_EX, 
    csr_addr_MEM, csr_forward12, csr_forward13);

input MEM_RegWrite, WB_RegWrite;
input [4:0] MEM_RegRd, WB_RegRd, EX_RegRs, EX_RegRt;
output logic [1:0] Forward_A, Forward_B;


//hw4 new add
input [31:0] ID_instruction, EX_instruction, MEM_instruction;                                           //plug in not yet
input [11:0] csr_addr_ID, csr_addr_EX, csr_addr_MEM;       //plug in not yet
output logic csr_forward12, csr_forward13;

logic [6:0] opcode_ID;
logic [6:0] opcode_EX;
logic [6:0] opcode_MEM;

assign opcode_ID  = ID_instruction[6:0];
assign opcode_EX  = EX_instruction[6:0];
assign opcode_MEM = MEM_instruction[6:0];
//

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


//--------------------------hw4 new add----------------------


//forward12 is mean EX to MEM, forward13 is mean EX to WB.
always_comb begin
    //can't forward when overwrite forbidden region
    if (opcode_EX == `OP_CSR && opcode_ID == `OP_CSR && csr_addr_EX != 12'h305 && csr_addr_EX != 12'h344)
        csr_forward12 = (csr_addr_EX == csr_addr_ID)? 1'b1 : 1'b0;
    else
        csr_forward12 = 1'b0;
end
    

always_comb begin
//can't forward when overwrite forbidden region
	if (opcode_MEM == `OP_CSR && opcode_ID == `OP_CSR && csr_addr_MEM != 12'h305 && csr_addr_MEM != 12'h344)
		csr_forward13 = (csr_addr_MEM == csr_addr_ID)? 1'b1 : 1'b0;
	else
		csr_forward13 = 1'b0;
end

/*
always_comb begin
	priority if (csr_forward12) begin
		case (csr_addr_MEM)
			12'h300: csr_src = {19'b0, CSR_result_MEM[12:11], 3'b0, CSR_result_MEM[7], 3'b0, CSR_result_MEM[3], 3'b0};
			12'h304: csr_src = {20'b0, CSR_result_MEM[11], 11'b0};
			default: csr_src = CSR_result_MEM;
		endcase
	end
	else if (csr_forward13) begin
		case (csr_addr_WB)
			12'h300: csr_src = {19'b0, CSR_result_WB[12:11], 3'b0, CSR_result_WB[7], 3'b0, CSR_result_WB[3], 3'b0};
			12'h304: csr_src = {20'b0, CSR_result_WB[11], 11'b0};
			default: csr_src = CSR_result_WB;
		endcase
	end
	else
		csr_src = csr_rs;
end
*/

endmodule