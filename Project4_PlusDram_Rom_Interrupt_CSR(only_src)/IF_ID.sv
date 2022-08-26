`include "Defines.svh"
`include "IDInstDef.svh"
module IF_ID(clk, rst, stall, IF_ID_write, PC_out, PCadd4_Out, ID_PC_out, ID_PCadd4_Out, 
    IF_flush, IF_flush_out, IM_Instruction, IM_Instruction_reg, WFI, interrupt_pulse);
// input
input clk, rst;
input [`PC_addr] PC_out, PCadd4_Out;            //InstMem_data
input IF_flush;                                 //IF_ID_write
input IF_ID_write;
//AXI new add.
input stall;
input [31:0] IM_Instruction;
// output
output logic [31:0] ID_PC_out;                  // ID_InstMem_data, 
output logic [31:0] ID_PCadd4_Out;
output logic IF_flush_out;
output logic [31:0] IM_Instruction_reg;

//hw4 new add
input WFI;
input interrupt_pulse;


always @(posedge clk or posedge rst) begin
    if (rst)begin
        ID_PCadd4_Out <= `ZeroWord;
        ID_PC_out <= `ZeroWord;
        IF_flush_out <= 1'b0;
        IM_Instruction_reg <= 32'b0;
    end
    else
    begin
        //AXI new add
        if (stall || WFI && !interrupt_pulse)
        begin
            ID_PCadd4_Out <= ID_PCadd4_Out;
            ID_PC_out <= ID_PC_out;
            IF_flush_out <= IF_flush_out;
            IM_Instruction_reg <= IM_Instruction_reg; 
        end
        else if (IF_flush)
        begin
            ID_PCadd4_Out <= `ZeroWord;
            ID_PC_out <= `ZeroWord;
            IF_flush_out <= IF_flush;    // when IF_flush==1
            IM_Instruction_reg <= 32'b0;
        end
        else
        begin
            //The disadvantage is that when IF_ID write=0, the value pulled out by IM will not be stalled!!!
            if (IF_ID_write == 1'b0)
            begin
                ID_PCadd4_Out <= ID_PCadd4_Out;
                ID_PC_out <= ID_PC_out;
                IF_flush_out <= IF_flush;
                IM_Instruction_reg <= IM_Instruction;
            end
            else
            begin
                ID_PCadd4_Out <= PCadd4_Out;
                ID_PC_out <= PC_out;
                IF_flush_out <= IF_flush;
                IM_Instruction_reg <= IM_Instruction;
            end
        end
    end
end
endmodule
