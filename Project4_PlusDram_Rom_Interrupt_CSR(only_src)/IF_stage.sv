`include "Defines.svh"
`include "IDInstDef.svh"

module IF_stage(
    input clk,
    input rst,
    input PC_write,
    input branch,
    input jump,
    input stall,
    input IF_ID_write,

    //hw4 new add
    input interrupt,
    input MRET, 
    input WFI,
    input [31:0] mtvec_pc,
    input [31:0] mepc_pc,
    input [31:0] IM_out,
    output logic [31:0] Instruction,


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

/*
//origin
always @(posedge clk or posedge rst) begin
    if (rst)        PC_out <= `ZeroWord;
    else if(stall)  PC_out <= PC_out;
    else    PC_out <= (PC_write == `WriteEnable)? PC_in_reg : PC_out;
end
//
*/

//hw4 new try
always @(posedge clk or posedge rst) begin
    if (rst)            PC_out <= `ZeroWord;
    else if (stall)     PC_out <= PC_out;
    else if (interrupt) PC_out <= mtvec_pc;
    else if (!PC_write) PC_out <= PC_out;          //maybe have change to ID_pc (origin is macro `WriteEnable)
    else if (branch)    PC_out <= branch_target;
    else if (jump)      PC_out <= jarl_target;
    else if (WFI)       PC_out <= PC_out;
    else if (MRET)      PC_out <= mepc_pc;          //Exit the interrupt program and return to the previous address
    else                PC_out <= PCadd4_out;
end
//
assign IM_address = PC_out;
assign PCadd4_out = PC_out + 32'h4;

/*
//origin
always_comb begin
    case({jump,branch})
        2'b00: PC_in_reg = PCadd4_out;
        2'b01: PC_in_reg = branch_target;
        2'b10: PC_in_reg = jarl_target;
        2'b11: PC_in_reg = PCadd4_out;
    endcase
end
*/

//hw4 new add
always_comb begin
	if (interrupt)      Instruction = 32'b0;
    else if (!PC_write) Instruction = 32'b0;
	else Instruction = (WFI || MRET)? 32'b0 : IM_out;
end
//

assign flush_control = branch | jump;
assign IF_flush = IF_ID_write & flush_control;

endmodule
