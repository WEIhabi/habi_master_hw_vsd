`include "Defines.svh"
`include "IDInstDef.svh"


`include "Control.sv"
`include "Immediate_Generator.sv"
`include "jump_function.sv"
`include "Registerfile.sv"
`include "branch_function.sv"
//`include "ID_adder.sv"
//`include "ID_stage_comparators.sv"
`include "IDstage_forwarding.sv"
`include "mux4to1.sv"
//`include "mux2to1_forID.sv"
`include "mux2to1_32bit.sv"
`include "csr_regfile.sv"



module ID (
    // input 
    input clk,
    input rst,
    input IF_ID_write_delay,
    input IF_flush_out,
    input [31:0] EX_instruction,
    input [31:0] pc_i,
    input [31:0] instruction,
    input [4:0]  write_reg,
    input [4:0]  MEM_RegRd,
    input [4:0]  WB_RegRd,
    input MEM_RegWrite,
    input WB_RegWrite,
    input [31:0] write_data,    //write back data and for ID forwarding
    input Hazard_sel_mux,
    input [31:0] ALU_result_MEM,//for ID forwarding, In fact, it should be called ALU_fonwarding better, so it is easy to misunderstand it as 14bit DM input.
    //AXI new add.
    input stall,
    
    //hw4 new add
    input hazard,
    input interrupt,
    input [11:0] csr_addr_WB,
    input [31:0] csr_writeback_data,
    input reg_write_csr_WB,

    //

    // output
    output logic [31:0] ID_reg1Data,
    output logic [31:0] ID_reg2Data,
    output logic branch,         
    output logic branch_or_jalr,        //for Hazard detection unit input
    output logic [31:0] branch_target,  //branch and jal target address
    output logic [31:0] jump_target,
    output logic [31:0] get_32bit_imm,
    output logic [4:0]  Reg_rs1,
    output logic [4:0]  Reg_rs2,
    output logic [4:0]  Reg_rd,
    output logic jump_flag,     
    output logic [8:0] control,  //[8:4]is EX(alusrc1,alusrc2,alusel3bit), [3:2] is MEM(r,w), [1:0] is WB(Mtoreg,regwrite) 
    output logic [31:0] true_Instruction,

    //hw4 new add
    output logic [31:0] Imm_csr,
    output logic        reg_write_csr_ID,
    output logic        MRET,
    output logic        MEIE,
    output logic        WFI,
    output logic [11:0] csr_addr_ID,
    output logic [31:0] csr_rs,
    output logic [31:0] mtvec_pc,
    output logic [31:0] mepc_pc
    //
);
    
logic [31:0] read_data1_reg, read_data2_reg;
logic [2:0]  comparator_out;
logic [1:0]  Forward_A, Forward_B;
logic [8:0]  control_reg;
logic branch_flag;  
//logic [31:0] after_stall_control_Instruction;
logic [31:0] after_IF_ID_write_control;
//hw4 new add
logic [31:0] instruction_flush;
logic [6:0]  opcode;


assign Reg_rs1 = true_Instruction[19:15];
assign Reg_rs2 = true_Instruction[24:20];
assign Reg_rd = true_Instruction[11:7];

//hw4 new add
/*
always_comb begin   //need to considerate!!
    if(hazard)  instruction_flush = 32'b0;
    else        instruction_flush = true_Instruction;
end
*/
assign opcode = true_Instruction[6:0];          
assign csr_addr_ID = true_Instruction [31:20];

//

mux2to1_32bit IF_ID_write_control(
    .sel(IF_ID_write_delay),
    .in1(EX_instruction),
    .in2(instruction),
    .out(after_IF_ID_write_control)
);

mux2to1_32bit IF_flush_control(
    .sel(IF_flush_out),
    .in1(after_IF_ID_write_control),
    .in2(32'h0),
    .out(true_Instruction)
);

Control Contro(
    .Instruction(true_Instruction),//origin is true_Instruction
    .opcode(opcode),
    .EX(control_reg[8:4]),
    .M(control_reg[3:2]),
    .WB(control_reg[1:0]),
    .j_type_flag(jump_flag),
    .branch_flag(branch_flag),
    .branch_or_jalr(branch_or_jalr),
    .reg_write_csr(reg_write_csr_ID),
    .MRET(MRET),
    .WFI(WFI)
);

/*
mux2to1_forID mux2to1_forID(
    .in1(9'b0),
    .in2(control_reg[8:0]),
    .sel(Hazard_sel_mux),
    .muxout(control[8:0])
);
*/

assign control = (Hazard_sel_mux == 1'b0) ? 9'b0 : control_reg;

Registerfile Registerfile(
    .clk(clk),
    .rst(rst),
    .read_reg1(true_Instruction[19:15]),
    .read_reg2(true_Instruction[24:20]),
    .write_reg(write_reg),
    .write_data(write_data),
    .read_data1(read_data1_reg),
    .read_data2(read_data2_reg),
    .regWrite(WB_RegWrite)
);

//hw4 new add
csr_regfile csr_regfile(
    //input
    .clk(clk),
    .rst(rst),
    .rs_address(csr_addr_ID),
    .rd_address(csr_addr_WB),
    .csr_writeback_data(csr_writeback_data),
    .pc(pc_i),
    .interrupt(interrupt),
    .MRET(MRET),
    .reg_write_csr(reg_write_csr_WB),
    //output
    .csr_rs(csr_rs),
    .MEIE(MEIE),
    .mtvec_pc(mtvec_pc),
    .mepc_pc(mepc_pc)
);
//

Immediate_Generator Immediate_Generator(
    .Imm_input_Instruction(true_Instruction),
    .get_32bit(get_32bit_imm),
    .Imm_csr(Imm_csr)
);
/*
ID_adder ID_adder(
    .in1(get_32bit_imm),
    .in2(pc_i),         
    .adderout(branch_target)
);
*/
assign branch_target = get_32bit_imm + pc_i;

IDstage_forwarding IDstage_forwarding(
    .branch_or_jalr(branch_or_jalr),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B),
    .ID_RegRs(true_Instruction[19:15]),
    .ID_RegRt(true_Instruction[24:20]),
    .MEM_RegRd(MEM_RegRd),
    .WB_RegRd(WB_RegRd),
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite)
);
/*
ID_stage_comparators ID_stage_comparators(
    .Data1(ID_reg1Data),
    .Data2(ID_reg2Data),
    .com_out(comparator_out)
);
*/
always_comb begin   // ex: out = 100 is Data1 < Data2
    comparator_out[0] = (ID_reg1Data == ID_reg2Data);
    comparator_out[1] = $signed(ID_reg1Data) < $signed(ID_reg2Data);
    comparator_out[2] = $unsigned( ID_reg1Data ) < $unsigned( ID_reg2Data );
end

branch_function branch_function(
    .branch_flag(branch_flag),
    .ID_comparator(comparator_out),
    .func3(true_Instruction[14:12]),
    .branch(branch),
    .opcode7(true_Instruction[6:0])
);

jump_function jump_function(
    .rs1_data(ID_reg1Data),     // Remember to modify when drawing pictures here
    .imm_in(get_32bit_imm),
    .jalr_address(jump_target)
);

mux4to1 data1_mux4to1(
    .in0(read_data1_reg),
    .in1(write_data),
    .in2(ALU_result_MEM),
    .in3(read_data1_reg),//***************default***************
    .out(ID_reg1Data),
    .sel0(Forward_A[0]),
    .sel1(Forward_A[1])
);

mux4to1 data2_mux4to1(
    .in0(read_data2_reg),
    .in1(write_data),
    .in2(ALU_result_MEM),
    .in3(read_data2_reg),//***************default***************
    .out(ID_reg2Data),
    .sel0(Forward_B[0]),
    .sel1(Forward_B[1])
);

endmodule
