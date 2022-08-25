`include "Defines.svh"
`include "IDInstDef.svh"
`include "IF_stage.sv"
`include "IF_ID.sv"
`include "ID.sv"
`include "ID_EX.sv"
`include "EX.sv"
`include "EX_MEM.sv"
`include "MEM.sv"
`include "MEM_WB.sv"
`include "WB.sv"
`include "HazardDetectionUnit.sv"
`include "delay_FF.sv"
module cpu(
    //input
    input clk, rst,
    input [31:0] IM_Instruction,           //Instruction read from IM connect to SRAM_IM_DO
    //input [31:0] alu_out_for_WB,
    input [31:0] DM_data,                   //Data read from DM connect to SRAM_DM_DO
    //output
    output logic [13:0] IM_address,         //Connect to SRAM_IM_A
    output logic [13:0] DM_address,         //Connect to SRAM_DM_A
    //output logic [31:0] alu_out_forDM

        //output logic MEM_control_reg,       //Then pull it to SRAM (DM) to connect to OE (memread)
    //output logic CS_control,            //Control the opening or closing of SRAM (power saving), remember that this can only be used to control DM, the IM part is always Enable
    output logic [3:0]  WEB,            //Receive sram_DM_WEB
    output logic [31:0] DI             //When the cpu is connected to the DM in the top, it is pulled from EX/MEM and connected to SRAM_DM_DI

);

logic PC_write_wire;              
logic IF_ID_write_wire;
logic IF_ID_write_delay_wire;       //!!!!!!!!!
logic HazardMuxControl_wire;
logic branch_flag_wire;             //for Hazard and branch and ID forwarding
logic branch_or_jalr_wire;
//logic HazardMuxControl_delay_wire;
//logic pc_write_delay_wire;
//logic ID_EX_memRead_wire;         //Replaced by all levels of control...[X:0]
//logic EX_MEM_memRead_wire;        //Replaced by all levels of control...[X:0]
logic [4:0] MEM_RegRd_wire;         //for ID forwarding and MEM stage reg_rd and Hazard
logic [4:0] EX_RegRd_wire;
//for IF wire
logic [31:0] PCadd4_out_wire;
logic [31:0] PC_out_wire;
//for IF_ID
logic [31:0] ID_PC_out_wire;
logic [31:0] ID_PCadd4_Out_wire;
logic IF_flush;
//for ID wire
//logic [31:0] ID_InstMem_data;     //Replaced by IM_Instruction
logic IF_flush_out_wire;
logic [31:0] true_Instruction_wire;
logic branch_wire;                  //for IF flush input and control pc mux[0] bit
logic jump_wire;                    
logic [31:0] branch_target_wire;
logic [31:0] jarl_target_wire;
//logic MEM_RegWrite_wire;          //Replaced by all levels of control...[X:0]
//logic WB_RegWrite_wire;   
logic [31:0] ID_reg1Data_wire;
logic [31:0] ID_reg2Data_wire;
logic [31:0] get_32bit_imm_wire;
logic [4:0] Reg_rs1_wire;
logic [4:0] Reg_rs2_wire;
logic [4:0] Reg_rd_wire;
//logic [31:0] pc_o_wire;
//for ID control!
logic [8:0] control_wire;           //Pull out from mux to ID/EX
logic [8:0] control_wire_after_ID_EX;//Control signal from ID/EX reg
logic [3:0] control_wire_after_EX_MEM;//Control signal from EX/MEM reg
logic [1:0] control_wire_after_MEM_WB;//Control signal from MEM/WB reg
//for EXE wire
logic [4:0] Reg_rs1reg_wire;             //When ID is used, ID_InstMem_data[19:15] is used for wiring
logic [4:0] Reg_rs2reg_wire;             //When ID is used, ID_InstMem_data[24:20] is used for wiring
//logic [4:0] Reg_rdreg_wire;           //Because the hazard unit is connected first, EX_RegRd_wire is used here, and no additional calls are made!
//In the ID, ID_InstMem_data[11:7] is used for wiring
logic [31:0] EX_reg1Data_wire;
logic [31:0] EX_reg2Data_wire;
logic [31:0] EX_imm_value_wire;
logic [31:0] EX_instruction_wire;
logic [31:0] EX_PCadd4_Out_wire;
logic [31:0] EX_PC_wire;
logic [31:0] ALU_out_wire;
logic [31:0] DM_write_data_wire;
logic [31:0] MEM_WriteDatain_wire;
//for MEM wire
logic [31:0] MEM_ALU_out_wire;
logic [31:0] ALU_out_wire_for_DM;           //forwarfing for ID stage and EXE stage
logic [31:0] MEM_instruction_wire;
logic [31:0] DM_final_data_wire;
//for WB wire
logic [31:0] writedata;
logic [4:0]  Reg_rd;                //for WB input reg_rd and ID stage write back reg ID _forwarding and MEM/WB output
//logic [31:0] WB_memout_wire;      //Pull the output result of MEM(DM) directly to WB, without pipe
logic [31:0] WB_ALUout_wire;
//logic regwrite_wire;
logic [31:0] WB_instruction_wire;
HazardDetectionUnit HDU(
    .rst(rst),
    .EX_RegWrite(control_wire_after_ID_EX[0]),
    .PC_write(PC_write_wire),
    .IF_ID_write(IF_ID_write_wire),
    .HazardMuxControl(HazardMuxControl_wire),
    .branch_or_jalr(branch_or_jalr_wire),
    .ID_EX_memRead(control_wire_after_ID_EX[3]),
    .EX_MEM_memRead(control_wire_after_EX_MEM[3]),
    .MEM_RegRd(MEM_RegRd_wire),
    .EX_RegRd(EX_RegRd_wire),
    .ID_RegRs1(true_Instruction_wire[19:15]),
    .ID_RegRs2(true_Instruction_wire[24:20])
);
delay_FF delayIF_ID_write_wire(
    .clk(clk),
    .rst(rst),
    .in(IF_ID_write_wire),
    .out(IF_ID_write_delay_wire)
);
IF_stage IF_s(
    .clk(clk),
    .rst(rst),
    .IF_ID_write(IF_ID_write_wire),
    .PC_write(PC_write_wire),
    .branch(branch_wire),
    .jump(jump_wire),
    .branch_target(branch_target_wire),
    .jarl_target(jarl_target_wire),
    .IM_address(IM_address),            //Pull to the outside of the CPU to connect to SRAM (IM)
    .PCadd4_out(PCadd4_out_wire),
    .PC_out(PC_out_wire),
    .IF_flush(IF_flush)
);

IF_ID IF_ID(
    .clk(clk),
    .rst(rst),
    .PC_out(PC_out_wire),
    .PCadd4_Out(PCadd4_out_wire),
    //.InstMem_data(IM_Instruction),
    .ID_PC_out(ID_PC_out_wire),
    //.ID_InstMem_data(ID_InstMem_data),
    .ID_PCadd4_Out(ID_PCadd4_Out_wire),
    .IF_flush(IF_flush),
    .IF_ID_write(IF_ID_write_wire),
    .IF_flush_out(IF_flush_out_wire)
);
ID ID(
    //input
    .clk(clk),
    .rst(rst),
    .IF_ID_write_delay(IF_ID_write_delay_wire),
    //.IF_ID_write(IF_ID_write_wire),
    .IF_flush_out(IF_flush_out_wire),
    .EX_instruction(EX_instruction_wire),
    .pc_i(ID_PC_out_wire),
    .instruction(IM_Instruction),
    //The value directly pulled from IM without passing through the pipe
    .write_reg(Reg_rd),
    .MEM_RegRd(MEM_RegRd_wire),
    .WB_RegRd(Reg_rd),
    .MEM_RegWrite(control_wire_after_EX_MEM[0]),                ////////////////////////
    .WB_RegWrite(control_wire_after_MEM_WB[0]),
    .write_data(writedata),
    .Hazard_sel_mux(HazardMuxControl_wire),
    //.regwrite(regwrite_wire),        //In fact, you can directly use control_wire_after_MEM_WB[0] to save one less pull
    .DM_address_in(ALU_out_wire_for_DM),
    //output
    .ID_reg1Data(ID_reg1Data_wire),
    .ID_reg2Data(ID_reg2Data_wire),
    .branch(branch_wire),
    .branch_flag(branch_flag_wire),
    .branch_target(branch_target_wire),
    .jump_target(jarl_target_wire),
    .get_32bit_imm(get_32bit_imm_wire),
    .Reg_rs1(Reg_rs1_wire),
    .Reg_rs2(Reg_rs2_wire),
    .Reg_rd(Reg_rd_wire),
    .jump_flag(jump_wire),
    .branch_or_jalr(branch_or_jalr_wire),
    .control(control_wire),
    .true_Instruction(true_Instruction_wire)
);
ID_EX ID_EX(
    .clk(clk),
    .rst(rst),
    .ID_WB(control_wire[1:0]),
    .ID_M(control_wire[3:2]),
    .ID_EX(control_wire[8:4]),
    .Reg_rs1(Reg_rs1_wire),
    .Reg_rs2(Reg_rs2_wire),
    .Reg_rd(Reg_rd_wire),
    .ID_reg1Data(ID_reg1Data_wire),
    .ID_reg2Data(ID_reg2Data_wire),
    .ID_imm_value(get_32bit_imm_wire),
    .ID_PCadd4_Out(ID_PCadd4_Out_wire),
    .ID_PC(ID_PC_out_wire),
    .ID_instruction(true_Instruction_wire),
    .EX_WB(control_wire_after_ID_EX[1:0]),                       // WB[1:0]={Memtoreg, Regwrite}
    .EX_M(control_wire_after_ID_EX[3:2]),                       // M[1:0]={memread,memwrite} 
    .EX_EX(control_wire_after_ID_EX[8:4]),                       // EX[4:0]={ALUsrc1, ALUsrc2  ALUsel(3bit)}
    .Reg_rs1reg(Reg_rs1reg_wire),
    .Reg_rs2reg(Reg_rs2reg_wire),
    .Reg_rdreg(EX_RegRd_wire),
    .EX_reg1Data(EX_reg1Data_wire),
    .EX_reg2Data(EX_reg2Data_wire),
    .EX_imm_value(EX_imm_value_wire),
    .EX_PCadd4_Out(EX_PCadd4_Out_wire),
    .EX_PC(EX_PC_wire),
    .EX_instruction(EX_instruction_wire)
);
EX EX(
    .EX_reg1Data(EX_reg1Data_wire),
    .EX_reg2Data(EX_reg2Data_wire),
    .EX_control(control_wire_after_ID_EX[8:4]),
    .EX_instruction(EX_instruction_wire),
    .PCadd4(EX_PCadd4_Out_wire),
    .PC(EX_PC_wire),
    .imm_extend(EX_imm_value_wire),
    .Reg_rs1(Reg_rs1reg_wire),
    .Reg_rs2(Reg_rs2reg_wire),
    .MEM_RegRd(MEM_RegRd_wire),
    .WB_RegRd(Reg_rd),                                  //There may be a mistake, it has been corrected
    .write_data(writedata),
    .DM_address_in(ALU_out_wire_for_DM),               //Forwarding from the next level
    .MEM_RegWrite(control_wire_after_EX_MEM[0]),
    .WB_RegWrite(control_wire_after_MEM_WB[0]),
    .ALU_out(ALU_out_wire),
    .DM_write_data(DM_write_data_wire)
    //.EX_true_instruction(EX_true_instruction_wire)
);
EX_MEM EX_MEM(
    .clk(clk),
    .rst(rst),
    .EX_WB(control_wire_after_ID_EX[1:0]),
    .EX_M(control_wire_after_ID_EX[3:2]),
    .EX_Reg_rd(EX_RegRd_wire),
    .EX_ALU_out(ALU_out_wire),
    .EX_WriteDatain(DM_write_data_wire),
    .EX_instruction(EX_instruction_wire),
    .MEM_WB(control_wire_after_EX_MEM[1:0]),
    .MEM_M(control_wire_after_EX_MEM[3:2]),
    .MEM_Reg_rd(MEM_RegRd_wire),
    .MEM_ALU_out(MEM_ALU_out_wire),                  //MEM_ALU_out_wire=ALU_out_wire_for_DM,
    //(The internal signals are all connected together, they are actually the same line)
    //but in order to avoid multiple conflicting drivers
    .MEM_WriteDatain(MEM_WriteDatain_wire),
    .MEM_instruction(MEM_instruction_wire)
);
MEM mem(
    .rst(rst),
    .DM_write_data(MEM_WriteDatain_wire),
    .ALU_out(MEM_ALU_out_wire),                          //Same reason as above
    .MEM_control(control_wire_after_EX_MEM[3:2]),
    .MEM_instruction(MEM_instruction_wire),
    .WB_instruction(WB_instruction_wire),
    .DM_read_data_reg(DM_data),
    //.MEM_control_reg(MEM_control_reg),      //MEM_control_reg = MEM_control[1]   , [1] = memread
    //.CS_control(CS_control),
    .WEB(WEB),
    .DM_address_in(DM_address),
    .ALU_out_reg(ALU_out_wire_for_DM),
    .DM_final_data(DM_final_data_wire),                 //Pull the output result of MEM(DM) directly to WB, without pipe
    .DI(DI)
);
MEM_WB MEM_WBx(
    .clk(clk),
    .rst(rst),
    .MEM_WB(control_wire_after_EX_MEM[1:0]),
    .MEM_instruction(MEM_instruction_wire),
    //.MEM_memout(DM_data),
    .MEM_ALU_out(ALU_out_wire_for_DM),
    .MEM_Reg_rd(MEM_RegRd_wire),
    .WB_WB(control_wire_after_MEM_WB[1:0]),
    //.WB_memout(WB_memout_wire),
    .WB_ALUout(WB_ALUout_wire),
    .WB_instruction(WB_instruction_wire),
    .WB_Reg_rd(Reg_rd)
);
WB WBx(
    .WB(control_wire_after_MEM_WB[1:0]),
    .memout(DM_final_data_wire),                   //connect with memout(no access pipe)
    .aluout(WB_ALUout_wire),
    .writedata(writedata)
    //.regwrite(regwrite_wire)
);
endmodule
