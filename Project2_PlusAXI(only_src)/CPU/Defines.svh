`ifndef _Def
`define _Def
// Attention: this may cause the speed of ID too slow to finish in a cycle
// `define ID_BRANCHES
// Attention: this may be slowwer then the former one!!!
// `define ID_JALR
`define ZeroWord            32'h0000_0000
`define WriteEnable         1'b1
`define ReadEnable          1'b1
`define ReadDisable         1'b0
`define ChipEnable          1'b1
`define ChipDisable         1'b0
`define rstEnable          1'b1
// ============= Register file related ===============
`endif