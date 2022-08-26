`include "Defines.svh"
`include "IDInstDef.svh"
module jump_function (rs1_data, imm_in, jalr_address);
input [31:0] rs1_data, imm_in;
output logic [31:0] jalr_address;
logic [31:0] set_LSB_zero;
logic [31:0] jalr_mask;
assign jalr_mask = 32'b1111_1111_1111_1111_1111_1111_1111_1110;
assign set_LSB_zero = rs1_data + imm_in;
assign jalr_address = set_LSB_zero &  jalr_mask;   
endmodule