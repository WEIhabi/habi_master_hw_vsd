`include "Defines.svh"
`include "IDInstDef.svh"
//`include "LOAD_signextend.sv"
module MEM(
    input [31:0]  ALU_out,
    input HazardMuxControl_MEM,           
    //input [31:0]  MEM_WriteDatain,    //Then DM will be pulled directly from EX_MEM
    input [1:0]   MEM_control,          //[1] = memread, [0] = memwrite
    //memread pull out from OE, memwrite receives Membyte_sel to control WEB
    input [31:0]   MEM_instruction,     // for MEMbyte_sel use          "Input/inout port 'MEM_control[1]' declared in the design-unit 'MEM' has a driver but no load"
    //input [31:0]   WB_instruction,      // for LOAD_signextend use(At this point it has reached the WB stage)
    input [31:0] DM_out,      //Value pulled back from outside cpu
    //input [31:0] MEM_WriteDatain,       //for store the register data to be written**********
    //This writing here is also directly assign DI = MEM_WriteDatain, so it is better to pull it from EX/MEM when the cpu and DM are connected directly in the top
    //output logic MEM_control_reg,       //Then pull it to SRAM (DM) to connect to OE (memread)
    //output logic CS_control,            //Control the opening or closing of SRAM (power saving)
    //output logic [3:0]  WEB,            //Receive sram_DM_WEB, WSTRB replaced
    //output logic [31:0] DM_address_in,  //Receive sram_DM_A
    //output logic [31:0] ALU_out_reg,    //In order to receive MEM_WB.sv of MEM_ALUout
    output logic [31:0] DM_final_data,   //After load_extend, finally received MEM_memout of MEM_WB.sv
    input        [31:0] src2,
    output logic [31:0] DM_in,

    output logic [6:0]  opcode_MEM,
    output logic [2:0]  funct3_MEM
);

logic [31:0] hazard_control_instruction;


//assign DM_address_in = ALU_out/*[15:2]*/;// send to SRAM_wrapper [15:2]
//assign ALU_out_reg = ALU_out;

//hazard_control_instruction is used to avoid writing the wrong value into the wrong mem location when the next instruction with hazard is store
assign opcode_MEM = hazard_control_instruction [6:0];
assign funct3_MEM = hazard_control_instruction [14:12];

always_comb begin
    if(!HazardMuxControl_MEM)
        hazard_control_instruction = 32'b0;
    else
        hazard_control_instruction = MEM_instruction;
end
//
/*
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
    .opcode7(hazard_control_instruction[6:0]),//
    .func3(hazard_control_instruction[14:12]),//
    .Byte_Address(ALU_out[1:0]),
    .DM_out(DM_final_data)
);
*/


logic [31:0] DM_out_byte, DM_out_half;

always_comb begin
	case (funct3_MEM)
		3'b000:  DM_in = {src2[7:0], src2[7:0], src2[7:0], src2[7:0]};
		3'b001:  DM_in = {src2[15:0], src2[15:0]};
		default: DM_in = src2;
	endcase
end

always_comb begin
    if (ALU_out[1:0] == 2'b00)   DM_out_half = (funct3_MEM == 3'b001)? 32'($signed(DM_out[15:0])) : {16'b0, DM_out[15:0]};
    else                         DM_out_half = (funct3_MEM == 3'b001)? 32'($signed(DM_out[31:16])) : {16'b0, DM_out[31:16]};
end

always_comb begin
    case (ALU_out[1:0])
        2'b00:   DM_out_byte = (funct3_MEM == 3'b000)? 32'($signed(DM_out[7:0])) : {24'b0, DM_out[7:0]};
        2'b01:   DM_out_byte = (funct3_MEM == 3'b000)? 32'($signed(DM_out[15:8])) : {24'b0, DM_out[15:8]};
        2'b10:   DM_out_byte = (funct3_MEM == 3'b000)? 32'($signed(DM_out[23:16])) : {24'b0, DM_out[23:16]};
        default: DM_out_byte = (funct3_MEM == 3'b000)? 32'($signed(DM_out[31:24])) : {24'b0, DM_out[31:24]};
    endcase
end

always_comb begin
    case (funct3_MEM)
        3'b000, 3'b100: DM_final_data = DM_out_byte;
        3'b001, 3'b101: DM_final_data = DM_out_half;
        default:        DM_final_data = DM_out;
    endcase
end



endmodule