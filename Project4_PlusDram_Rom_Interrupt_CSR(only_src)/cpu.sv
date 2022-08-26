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
`include "delay_FF_stall_control.sv"
`include "interrupt_unit.sv"
module cpu(
    //input
    input clk, rst,
    input [31:0] IM_out,           //Instruction read from IM connect to SRAM_IM_DO
    input [31:0] DM_data,                   //Data read from DM connect to SRAM_DM_DO
    output logic [31:0] DM_input,         //When the cpu is connected to the DM in the top, it is pulled from EX/MEM and connected to SRAM_DM_DI
    
    //after AXI new add
    output [31:0] IM_address,       //done     send to SRAM_wrapper decode
    output [31:0] ALU_result_MEM,   //done     send to SRAM_wrapper decode
    output [6:0] opcode_MEM,        //done     send to CPU_wrapper help WSTRB decode
    output [2:0] funct3_MEM,        //done     send to CPU_wrapper help WSTRB decode
    input stall,                     //done
    //hw4 new add
    input interrupt
);

//HDU
logic PC_write_wire;              
logic IF_ID_write_wire;
logic IF_ID_write_delay_wire;       
logic HazardMuxControl;
logic branch_or_jalr_wire;

logic [4:0] MEM_RegRd_wire;         //for ID forwarding and MEM stage reg_rd and Hazard
logic [4:0] EX_RegRd_wire;
//for IF wire
logic [31:0] PCadd4_out_wire;
logic [31:0] PC_out_wire;
//for IF_ID
logic [31:0] ID_PC_out_wire;
logic [31:0] ID_PCadd4_Out_wire;
logic IF_flush;
logic [31:0] IM_Instruction_reg;
//for ID wire
logic IF_flush_out_wire;
logic [31:0] true_Instruction_wire;
logic branch_wire;                  //for IF flush input and control pc mux[0] bit
logic jump_wire;                    
logic [31:0] branch_target_wire;
logic [31:0] jarl_target_wire;
logic [31:0] ID_reg1Data_wire;
logic [31:0] ID_reg2Data_wire;
logic [31:0] get_32bit_imm_wire;
logic [4:0] Reg_rs1_wire;
logic [4:0] Reg_rs2_wire;
logic [4:0] Reg_rd_wire;

//for ID control!
logic [8:0] control_wire;           //Pull out from mux to ID/EX
logic [8:0] control_wire_after_ID_EX;//Control signal from ID/EX reg
logic [3:0] control_wire_after_EX_MEM;//Control signal from EX/MEM reg
logic [1:0] control_wire_after_MEM_WB;//Control signal from MEM/WB reg
//for EXE wire
logic [4:0] Reg_rs1reg_wire;             //When ID is used, ID_InstMem_data[19:15] is used for wiring
logic [4:0] Reg_rs2reg_wire;             //When ID is used, ID_InstMem_data[24:20] is used for wiring
logic [31:0] EX_reg1Data_wire;
logic [31:0] EX_reg2Data_wire;
logic [31:0] EX_imm_value_wire;
logic [31:0] EX_instruction_wire;
logic [31:0] EX_PCadd4_Out_wire;
logic [31:0] EX_PC_wire;
logic [31:0] ALU_out_wire;
logic [31:0] DM_write_data_wire;
logic HazardMuxControl_EX;
logic [31:0] src2_MEM;
//for MEM wire
logic [31:0] MEM_instruction_wire;
logic [31:0] DM_final_data_wire;
logic [31:0] DM_data_out;
logic HazardMuxControl_MEM;
//for WB wire
logic [31:0] writedata;
logic [4:0]  Reg_rd;                //for WB input reg_rd and ID stage write back reg ID _forwarding and MEM/WB output
logic [31:0] WB_ALUout_wire;
logic [31:0] WB_instruction_wire;

//hw4 new add
logic [31:0] Imm_csr_ID, Imm_csr_EX;
logic hazard;
logic MRET, WFI, MEIE;
logic [31:0] IF_Instruction;
logic [31:0] ID_Instruction;
logic [31:0] mtvec_pc, mepc_pc;
logic [31:0] csr_rs_ID, csr_rs_EX;
logic [11:0] csr_addr_ID, csr_addr_EX, csr_addr_MEM, csr_addr_WB;      //pass by pipeline
logic [31:0] csr_result_EX, csr_result_MEM, csr_result_WB;             //pass by pipeline
logic        csr_wr_en_ID, csr_wr_en_EX, csr_wr_en_MEM, csr_wr_en_WB;  //pass by pipeline
logic        csr_forward12_EX, csr_forward12_MEM;
logic        csr_forward13_MEM, csr_forward13_WB;

interrupt_unit IU(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .WFI(WFI),
    .MEIE(MEIE),
    .interrupt(interrupt),
    .interrupt_pulse(interrupt_pulse)
);


HazardDetectionUnit HDU(
    .rst(rst),
    .EX_RegWrite(control_wire_after_ID_EX[0]),
    .PC_write(PC_write_wire),
    .IF_ID_write(IF_ID_write_wire),
    .HazardMuxControl(HazardMuxControl),
    .branch_or_jalr(branch_or_jalr_wire),
    .ID_EX_memRead(control_wire_after_ID_EX[3]),
    .EX_MEM_memRead(control_wire_after_EX_MEM[3]),
    .MEM_RegRd(MEM_RegRd_wire),
    .EX_RegRd(EX_RegRd_wire),
    .ID_RegRs1(true_Instruction_wire[19:15]),
    .ID_RegRs2(true_Instruction_wire[24:20]),
    .hazard(hazard) //---"connect done"---
);

delay_FF_stall_control delayIF_ID_write_wire(
    .clk(clk),
    .rst(rst),
    .stall(stall),
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
    .IF_flush(IF_flush),
    .stall(stall),
    //hw4 new add
    .interrupt(interrupt_pulse),
    .MRET(MRET),                    //---"connect done"---
    .WFI(WFI),                      //---"connect done"---
    .mtvec_pc(mtvec_pc),            //---"connect done"---
    .mepc_pc(mepc_pc),              //---"connect done"---
    .IM_out(IM_out),                //input ---"connect done"---
    .Instruction(IF_Instruction)    //output ---"connect done"---
);

IF_ID IF_ID(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .PC_out(PC_out_wire),
    .PCadd4_Out(PCadd4_out_wire),
    .ID_PC_out(ID_PC_out_wire),
    .ID_PCadd4_Out(ID_PCadd4_Out_wire),
    .IF_flush(IF_flush),
    .IF_ID_write(IF_ID_write_wire),
    .IF_flush_out(IF_flush_out_wire),
    .IM_Instruction(IF_Instruction),    //---"connect done"---
    .IM_Instruction_reg(ID_Instruction),//---"connect done"---
    .WFI(WFI),
    .interrupt_pulse(interrupt_pulse)
);

ID ID(
    //input
    .clk(clk),
    .rst(rst),
    .IF_ID_write_delay(IF_ID_write_delay_wire),
    .IF_flush_out(IF_flush_out_wire),
    .EX_instruction(EX_instruction_wire),
    .pc_i(ID_PC_out_wire),
    .instruction(ID_Instruction),   //---"connect done"---
    //The value directly pulled from IM without passing through the pipe
    .write_reg(Reg_rd),
    .MEM_RegRd(MEM_RegRd_wire),
    .WB_RegRd(Reg_rd),
    .MEM_RegWrite(control_wire_after_EX_MEM[0]),
    .WB_RegWrite(control_wire_after_MEM_WB[0]),
    .write_data(writedata),
    .Hazard_sel_mux(HazardMuxControl),
    .ALU_result_MEM(ALU_result_MEM),
    .stall(stall),

    //hw4 new add
    .hazard(hazard),                    //---"connect done"---
    .interrupt(interrupt_pulse),
    .csr_addr_WB(csr_addr_WB),          //write back rd address from WB stage
    .csr_writeback_data(csr_result_WB), //write back data from WB stage
    .reg_write_csr_WB(csr_wr_en_WB),    //WB stage plug back this signal

    //output
    .ID_reg1Data(ID_reg1Data_wire),
    .ID_reg2Data(ID_reg2Data_wire),
    .branch(branch_wire),
    .branch_target(branch_target_wire),
    .jump_target(jarl_target_wire),
    .get_32bit_imm(get_32bit_imm_wire),
    .Reg_rs1(Reg_rs1_wire),
    .Reg_rs2(Reg_rs2_wire),
    .Reg_rd(Reg_rd_wire),
    .jump_flag(jump_wire),
    .branch_or_jalr(branch_or_jalr_wire),
    .control(control_wire),
    .true_Instruction(true_Instruction_wire),

    //hw4 new add
    .Imm_csr(Imm_csr_ID),       //to pipe to ALU_for_csr    ---"connect done"---
    .reg_write_csr_ID(csr_wr_en_ID),    //stage by stage pass to WB stage   ---"connect done"---
    .MRET(MRET),                //to IF stage   ---"connect done"---
    .MEIE(MEIE),                //to interrupt unit
    .WFI(WFI),                  //to 'IF stage' and 'interrupt unit' and 'every pipeline' to control
    .csr_addr_ID(csr_addr_ID),  //!!!!!!!!!!!-------to ID/EXE pipe reg and Forwarding unit to detect////pipe OK Forwarding unit not yet.
    .csr_rs(csr_rs_ID),         //to ID/EXE pipe reg    ---"connect done"---
    .mtvec_pc(mtvec_pc),        //to IF stage           ---"connect done"---
    .mepc_pc(mepc_pc)           //to IF stage           ---"connect done"---
);

ID_EX ID_EX(
    .clk(clk),
    .rst(rst),
    .HazardMuxControl(HazardMuxControl),
    .stall(stall),
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
    .EX_WB(control_wire_after_ID_EX[1:0]),     // WB[1:0]={Memtoreg, Regwrite}
    .EX_M(control_wire_after_ID_EX[3:2]),      // M[1:0]={memread,memwrite} 
    .EX_EX(control_wire_after_ID_EX[8:4]),     // EX[4:0]={ALUsrc1, ALUsrc2  ALUsel(3bit)}
    .Reg_rs1reg(Reg_rs1reg_wire),
    .Reg_rs2reg(Reg_rs2reg_wire),
    .Reg_rdreg(EX_RegRd_wire),
    .EX_reg1Data(EX_reg1Data_wire),
    .EX_reg2Data(EX_reg2Data_wire),
    .EX_imm_value(EX_imm_value_wire),
    .EX_PCadd4_Out(EX_PCadd4_Out_wire),
    .EX_PC(EX_PC_wire),
    .EX_instruction(EX_instruction_wire),
    .HazardMuxControl_EX(HazardMuxControl_EX),

    //hw4 new add
    .interrupt_pulse(interrupt_pulse),
    .Imm_csr_ID(Imm_csr_ID),
    .csr_wr_en_ID(csr_wr_en_ID),
    .WFI(WFI),
    .csr_addr_ID(csr_addr_ID),
    .csr_rs_ID(csr_rs_ID),

    .Imm_csr_EX(Imm_csr_EX),
    .csr_wr_en_EX(csr_wr_en_EX),
    .csr_addr_EX(csr_addr_EX),
    .csr_rs_EX(csr_rs_EX)
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
    .WB_RegRd(Reg_rd),                              
    .write_data(writedata),
    .ALU_result_MEM(ALU_result_MEM),               //Forwarding from the next level
    .MEM_RegWrite(control_wire_after_EX_MEM[0]),
    .WB_RegWrite(control_wire_after_MEM_WB[0]),
    .ALU_out(ALU_out_wire),
    .DM_write_data(DM_write_data_wire),

    //hw4 new add
    .Imm_csr_EX(Imm_csr_EX),
    .csr_addr_ID(csr_addr_ID),             //to forwarding unit 
    .csr_addr_EX(csr_addr_EX),
    .csr_addr_MEM(csr_addr_MEM),
    .csr_addr_WB(csr_addr_WB),
    .ID_instruction(true_Instruction_wire),
    .MEM_instruction(MEM_instruction_wire),//or plug MEM mux output?
    .csr_rs(csr_rs_EX),
    .csr_result_MEM(csr_result_MEM),
    .csr_result_WB(csr_result_WB),
    //.ALU_result_EX(ALU_result_EX),
    .csr_result_EX(csr_result_EX),
    .csr_forward_MEM(csr_forward12_MEM),    //input (plug in from EX/MEM pipe)
    .csr_forward_WB(csr_forward13_WB),      //input (plug in from MEM/WB pipe)
    .csr_forward12(csr_forward12_EX),       //output to EX/MEM pipe
    .csr_forward13(csr_forward13_MEM)       //output to MEM/WB pipe
);

EX_MEM EX_MEM(
    .clk(clk),
    .rst(rst),
    .HazardMuxControl(HazardMuxControl_EX),
    .stall(stall),
    .EX_WB(control_wire_after_ID_EX[1:0]),
    .EX_M(control_wire_after_ID_EX[3:2]),
    .EX_Reg_rd(EX_RegRd_wire),
    .EX_ALU_out(ALU_out_wire),
    .EX_WriteDatain(DM_write_data_wire),
    .EX_instruction(EX_instruction_wire),
    .MEM_WB(control_wire_after_EX_MEM[1:0]),
    .MEM_M(control_wire_after_EX_MEM[3:2]),
    .MEM_Reg_rd(MEM_RegRd_wire),
    .MEM_ALU_out(ALU_result_MEM),                  
    .MEM_WriteDatain(src2_MEM),             //pull the wrapper WDATA_M1.
    .MEM_instruction(MEM_instruction_wire),
    .HazardMuxControl_MEM(HazardMuxControl_MEM),
    
    //hw4 new add
    .interrupt_pulse(interrupt_pulse),
    .WFI(WFI),
    .csr_wr_en_EX(csr_wr_en_EX),
    .csr_wr_en_MEM(csr_wr_en_MEM),
    .csr_result_EX(csr_result_EX),
    .csr_result_MEM(csr_result_MEM),
    .csr_addr_EX(csr_addr_EX),
    .csr_addr_MEM(csr_addr_MEM),
    .csr_forward12_EX(csr_forward12_EX),
    .csr_forward12_MEM(csr_forward12_MEM)
);

MEM mem(
    .src2(src2_MEM),
    .DM_in(DM_input),
    .HazardMuxControl_MEM(HazardMuxControl_MEM),
    .ALU_out(ALU_result_MEM),                          //Same reason as above
    .MEM_control(control_wire_after_EX_MEM[3:2]),
    .MEM_instruction(MEM_instruction_wire),
    .DM_out(DM_data),
    .DM_final_data(DM_final_data_wire),                 //Pull the output result of MEM(DM) directly to WB, without pipe
    .opcode_MEM(opcode_MEM),
    .funct3_MEM(funct3_MEM)
);

MEM_WB MEM_WBx(
    .clk(clk),
    .rst(rst),
    .stall(stall),
    .MEM_WB(control_wire_after_EX_MEM[1:0]),
    .MEM_ALU_out(ALU_result_MEM),
    .MEM_Reg_rd(MEM_RegRd_wire),
    .WB_WB(control_wire_after_MEM_WB[1:0]),
    .WB_ALUout(WB_ALUout_wire),
    .WB_Reg_rd(Reg_rd),
    .DM_data(DM_final_data_wire),
    .DM_data_out(DM_data_out),

    //hw4 new add
    .interrupt_pulse(interrupt_pulse),
    .WFI(WFI),
    .csr_wr_en_MEM(csr_wr_en_MEM),
    .csr_wr_en_WB(csr_wr_en_WB),
    .csr_result_MEM(csr_result_MEM),
    .csr_result_WB(csr_result_WB),
    .csr_addr_MEM(csr_addr_MEM),
    .csr_addr_WB(csr_addr_WB),
    .csr_forward13_MEM(csr_forward13_MEM),
    .csr_forward13_WB(csr_forward13_WB)
);

WB WBx(
    .clk(clk),
    .rst(rst),
    .WB(control_wire_after_MEM_WB[1:0]),
    .memout(DM_data_out),                   //connect with memout(no access pipe)
    .aluout(WB_ALUout_wire),
    .writedata(writedata)
);

endmodule
