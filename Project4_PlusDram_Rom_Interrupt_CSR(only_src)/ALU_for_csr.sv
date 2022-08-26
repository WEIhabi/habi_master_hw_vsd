`include "Defines.svh"
`include "IDInstDef.svh"

module ALU_for_csr(
input [31:0] src1,
input [31:0] csr_src,
input [31:0] imm,//assign imm pass mux
input [2:0]  csr_func3,
output logic [31:0] csr_result
);

always_comb begin
	case (csr_func3)
		`FUNCT3_CSRRW:  csr_result = src1;
		`FUNCT3_CSRRS:  csr_result = csr_src | src1;
		`FUNCT3_CSRRC:  csr_result = csr_src & ~src1;
		`FUNCT3_CSRRWI: csr_result = imm;              
		`FUNCT3_CSRRSI: csr_result = csr_src | imm;
		`FUNCT3_CSRRCI: csr_result = csr_src & ~imm;
		default: csr_result = 32'b0;
	endcase
end

//The WFI instruction is just a hint, and a legal implementation is to implement WFI as a NOP.

endmodule
