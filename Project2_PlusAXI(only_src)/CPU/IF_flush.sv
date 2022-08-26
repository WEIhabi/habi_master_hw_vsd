`include "Defines.svh"
`include "IDInstDef.svh"
module IF_flush (branch, jump, flush);
input branch, jump;
output logic flush;
assign flush = branch | jump;
endmodule