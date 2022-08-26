`include "Defines.svh"
`include "IDInstDef.svh"
module PCadd4(PC_out, PCadd4_Out);
input [`PC_addr] PC_out;
output logic[`PC_addr] PCadd4_Out;
always_comb //always use combination logic
begin
    PCadd4_Out = PC_out + 32'h4;
end
endmodule




















