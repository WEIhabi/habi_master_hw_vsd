`include "Defines.svh"
`include "IDInstDef.svh"
`include "Membyte_sel.sv"
`include "LOAD_signextend.sv"
module MEM(
    input rst,
    input [31:0]  ALU_out,
    input [31:0]  DM_write_data,            
    //input [31:0]  MEM_WriteDatain,    //Then DM will be pulled directly from EX_MEM
    input [1:0]   MEM_control,          //[1] = memread, [0] = memwrite
    //memread pull out from OE, memwrite receives Membyte_sel to control WEB
    input [31:0]   MEM_instruction,     // for MEMbyte_sel use          "Input/inout port 'MEM_control[1]' declared in the design-unit 'MEM' has a driver but no load"
    input [31:0]   WB_instruction,      // for LOAD_signextend use(At this point it has reached the WB stage)
    input [31:0] DM_read_data_reg,      //Value pulled back from outside cpu
    //input [31:0] MEM_WriteDatain,       //for store the register data to be written**********
    //This writing here is also directly assign DI = MEM_WriteDatain, so it is better to pull it from EX/MEM when the cpu and DM are connected directly in the top
    //output logic MEM_control_reg,       //Then pull it to SRAM (DM) to connect to OE (memread)
    //output logic CS_control,            //Control the opening or closing of SRAM (power saving)
    output logic [3:0]  WEB,            //Receive sram_DM_WEB
    output logic [13:0] DM_address_in,  //Receive sram_DM_A
    output logic [31:0] DI,             //Receive sram_DM_DI***********************
    output logic [31:0] ALU_out_reg,    //In order to receive MEM_WB.sv of MEM_ALUout
    output logic [31:0] DM_final_data   //After load_extend, finally received MEM_memout of MEM_WB.sv
);
assign DM_address_in = ALU_out[15:2];// ALU_out_reg/4
assign ALU_out_reg = ALU_out;
//assign MEM_control_reg = MEM_control[1];//[1] = memread
Membyte_sel Membyte_sel(
    .rst(rst),
    .write_data(DM_write_data),
    .memwrite(MEM_control[0]),
    .Byte_Address(ALU_out[1:0]),
    .func3(MEM_instruction[14:12]),
    .WEB(WEB),
    .DI(DI)
);
LOAD_signextend LOAD_signextend(
    .DM_read_data(DM_read_data_reg),
    .opcode7(WB_instruction[6:0]),
    .func3(WB_instruction[14:12]),
    .Byte_Address(ALU_out[1:0]),
    .DM_out(DM_final_data)
);
endmodule