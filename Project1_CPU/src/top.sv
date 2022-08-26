`include "Defines.svh"
`include "IDInstDef.svh"
`include "SRAM_wrapper.sv"
`include "cpu.sv"
module top(
    input clk, rst
);
logic [31:0] IM_Instruction_wire;
logic [31:0] DM_data_wire;
logic [13:0] IM_address_wire;
logic [13:0] DM_address_wire;
//logic MEM_control_wire;
//logic CS_control_wire;
logic [3:0] WEB_wire;
logic [31:0] DI_wire;
logic Enable; 
logic [31:0] data_Disable;
logic [3:0] WEB_Disable;
assign Enable = 1'b1;
assign data_Disable = 32'b0;
assign WEB_Disable = 4'b1111;
cpu cpu(
    .clk(clk),
    .rst(rst),
    .IM_Instruction(IM_Instruction_wire),
    .DM_data(DM_data_wire),
    .IM_address(IM_address_wire),
    .DM_address(DM_address_wire),
        //.MEM_control_reg(MEM_control_wire),
    //.CS_control(CS_control_wire),
    .WEB(WEB_wire),
    .DI(DI_wire)
); 
SRAM_wrapper IM1(//WEB always high, DI can empty link(空接)
    .CK(clk),
    .CS(Enable),
    .OE(Enable),
    .WEB(WEB_Disable),
    .A(IM_address_wire),
    .DI(data_Disable),
    .DO(IM_Instruction_wire)
    );
SRAM_wrapper DM1(
    .CK(clk),
    .CS(Enable),
    .OE(Enable),
    .WEB(WEB_wire),
    .A(DM_address_wire),
    .DI(DI_wire),
    .DO(DM_data_wire)
);
endmodule