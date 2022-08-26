`include "Defines.svh"
`include "IDInstDef.svh"
`include "ALU.sv"
`include "ALUcontrol.sv"
`include "ForwardingUnit.sv"
`include "mux4to1.sv"
`include "mux2to1_32bit.sv"
`include "ALU_for_csr.sv"

module EX (
    input [31:0] EX_reg1Data,
    input [31:0] EX_reg2Data,
    input [4:0]  EX_control,        //[4:0]=alusrc1,alusrc2,alusel[2:0]
    input [31:0] EX_instruction,    
    input [31:0] PCadd4,
    input [31:0] PC,
    input [31:0] imm_extend,
    input [4:0]  Reg_rs1,
    input [4:0]  Reg_rs2,
    //input [4:0]  Reg_rd,          
    input [4:0]  MEM_RegRd,
    input [4:0]  WB_RegRd,
    input [31:0] write_data,        //write back data and for ID forwarding
    input [31:0] ALU_result_MEM,     //for EXE forwarding, In fact, it should be called ALU_fonwarding better, so it is easy to misunderstand it as 14bit DM input.
    input MEM_RegWrite,
    input WB_RegWrite,
    output logic [31:0] ALU_out,
    output logic [31:0] DM_write_data,

    //hw4 new add
    input [31:0] Imm_csr_EX,
    input [11:0] csr_addr_ID,          //to forwarding unit
    input [11:0] csr_addr_EX,
    input [11:0] csr_addr_MEM,
    input [11:0] csr_addr_WB,
    input [31:0] csr_rs,            //forwarding to determine
    input [31:0] csr_result_MEM,    //forwarding pull back
    input [31:0] csr_result_WB,     //forwarding pull back
    input [31:0] ID_instruction,
    input [31:0] MEM_instruction,
    input        csr_forward_MEM,
    input        csr_forward_WB,
    //output logic [31:0] ALU_result_EX,
    output logic [31:0] csr_result_EX,
    output logic csr_forward12, 
    output logic csr_forward13

    
);

logic [3:0]  ALUcontrol;
logic [31:0] Forwarding_mux1out;
logic [31:0] Forwarding_mux2out;
logic [1:0]  Forward_A, Forward_B;
logic [31:0] ALU_data1_in; 
logic [31:0] ALU_data2_in;

//hw4 new add
logic [2:0]  CSRcontrol;
logic [31:0] csr_src;


always_comb begin
	priority if (csr_forward_MEM) begin
		case (csr_addr_MEM)
			12'h300: csr_src = {19'b0, csr_result_MEM[12:11], 3'b0, csr_result_MEM[7], 3'b0, csr_result_MEM[3], 3'b0};
			12'h304: csr_src = {20'b0, csr_result_MEM[11], 11'b0};
			default: csr_src = csr_result_MEM;
		endcase
	end
	else if (csr_forward_WB) begin
		case (csr_addr_WB)
			12'h300: csr_src = {19'b0, csr_result_WB[12:11], 3'b0, csr_result_WB[7], 3'b0, csr_result_WB[3], 3'b0};
			12'h304: csr_src = {20'b0, csr_result_WB[11], 11'b0};
			default: csr_src = csr_result_WB;
		endcase
	end
	else
		csr_src = csr_rs;
end




ALUcontrol ALUcontro(
    .ALUsel(EX_control[2:0]),
    .opcode7(EX_instruction[6:0]),
    .func3(EX_instruction[14:12]),
    .func7(EX_instruction[30]),
    .ALUcontrol(ALUcontrol),
    //hw4 new add
    .CSRcontrol(CSRcontrol)
);

//hw4 new add
ALU_for_csr ALU_csr(
    .src1(ALU_data1_in),//need to considerate forwarding case! otherwise src1=Forwarding_mux1out
    .csr_src(csr_src),  //input
    .imm(Imm_csr_EX),
    .csr_func3(CSRcontrol),
    .csr_result(csr_result_EX)
);


ALU ALU(
    .ALUcontrol(ALUcontrol),
    .r1_data_i(ALU_data1_in),
    .r2_data_i(ALU_data2_in),
    .pcadd4(PCadd4),
    .out(ALU_out),
    //hw4 new add
    .csr_src(csr_src)   //input
);

ForwardingUnit ForwardingUnit(
    .MEM_RegRd(MEM_RegRd),
    .WB_RegRd(WB_RegRd),
    .EX_RegRs(Reg_rs1),
    .EX_RegRt(Reg_rs2),
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B),
    //hw4 new add
    .ID_instruction(ID_instruction),
    .EX_instruction(EX_instruction),
    .MEM_instruction(MEM_instruction),
    .csr_addr_ID(csr_addr_ID),
    .csr_addr_EX(csr_addr_EX),
    .csr_addr_MEM(csr_addr_MEM),
    .csr_forward12(csr_forward12),  //output
    .csr_forward13(csr_forward13)   //output
    //.CSR_result_MEM(csr_result_MEM),
    //.CSR_result_WB(csr_result_WB),
    //.csr_rs(csr_rs),
    //.csr_src(csr_src)   //output
);

mux4to1 forwarding1_mux4to1(
    .in0(EX_reg1Data),
    .in1(write_data),
    .in2(ALU_result_MEM),
    .in3(ALU_result_MEM),//***************default***************
    .out(Forwarding_mux1out),
    .sel0(Forward_A[0]),
    .sel1(Forward_A[1])
);

mux4to1 forwarding2_mux4to1(
    .in0(EX_reg2Data),
    .in1(write_data),
    .in2(ALU_result_MEM),
    .in3(ALU_result_MEM),//***************default***************
    .out(Forwarding_mux2out),
    .sel0(Forward_B[0]),
    .sel1(Forward_B[1])
);

assign DM_write_data = Forwarding_mux2out; //prepare for store M[rs1+imm]=rs2

mux2to1_32bit src1(
    .in1(Forwarding_mux1out),
    .in2(PC),
    .sel(EX_control[4]),
    .out(ALU_data1_in)
);
mux2to1_32bit src2(
    .in1(Forwarding_mux2out),
    .in2(imm_extend),
    .sel(EX_control[3]),
    .out(ALU_data2_in)
);





endmodule