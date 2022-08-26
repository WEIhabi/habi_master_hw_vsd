`include "Defines.svh"
`include "IDInstDef.svh"
//`include "PC.sv"
//`include "PCadd4.sv"
//`include "mux4to1.sv"
//`include "IF_flush.sv"
module IF_stage(
    input clk,
    input rst,
    input PC_write,
    input branch,
    input jump,
    input stall,
    input IF_ID_write,
    input [31:0] branch_target,
    input [31:0] jarl_target,
    output logic [31:0] IM_address,
    output logic [31:0] PCadd4_out,
    output logic [31:0] PC_out,
    output logic IF_flush
);
logic flush_control;
logic [31:0] PC_in_reg;        //wire

//HW3 calculate IPC
integer cycle_count;//32bit
integer inst_count; //32bit
integer stall_counter;//calculate stall cycle
logic [31:0] pc_reg;

always_ff @(posedge clk or posedge rst) begin
    if(rst) cycle_count <= 32'd0;
    else    cycle_count <= cycle_count + 32'd1;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) pc_reg <= 32'd0;
    else    pc_reg <= PC_out;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) inst_count <= 32'd0;
    else if(PC_out != pc_reg) inst_count <= inst_count + 32'd1;
    else    inst_count <= inst_count;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) stall_counter <= 32'd0;
    else if(stall) stall_counter <= stall_counter + 32'd1;
    else    stall_counter <= stall_counter;
end
///////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst) begin
    if (rst)        PC_out <= `ZeroWord;
    else if(stall)  PC_out <= PC_out;
    else    PC_out <= (PC_write == `WriteEnable)? PC_in_reg : PC_out;
end

assign IM_address = PC_out;
assign PCadd4_out = PC_out + 32'h4;


always_comb begin
    case({jump,branch})
        2'b00: PC_in_reg = PCadd4_out;
        2'b01: PC_in_reg = branch_target;
        2'b10: PC_in_reg = jarl_target;
        2'b11: PC_in_reg = PCadd4_out;
    endcase
end

assign flush_control = branch | jump;
assign IF_flush = IF_ID_write & flush_control;

endmodule
