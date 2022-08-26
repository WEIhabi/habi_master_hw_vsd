`include "Defines.svh"
`include "IDInstDef.svh"
// This module is for reduce branch hazard delay cycle, from 3 reduce to 1.
// only stall one cycle , because if a branch jump occurs, just clear the IF instruction
module ID_stage_comparators(Data1, Data2, com_out);
input [31:0] Data1, Data2;
output logic [2:0] com_out;
// logic lessthan, equal;
always_comb begin   // ex: out = 100 is Data1 < Data2
    com_out[0] = (Data1 == Data2);
    com_out[1] = $signed(Data1) < $signed(Data2);
    com_out[2] = $unsigned( Data1 ) < $unsigned( Data2 );
end
endmodule