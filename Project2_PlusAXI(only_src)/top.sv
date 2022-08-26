//`include "Defines.svh"
//`include "IDInstDef.svh"
//`include "AXI_define.svh"
`include "SRAM_wrapper.sv"
//`include "cpu.sv"
`include "CPU_wrapper.sv"
`include "./AXI/AXI.sv"


module top(
    input clk, rst
);


//SLAVE INTERFACE FOR MASTERS
//WRITE ADDRESS
logic [`AXI_ID_BITS-1:0] AWID_M1;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M1;
logic [`AXI_LEN_BITS-1:0] AWLEN_M1;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1;
logic [1:0] AWBURST_M1;
logic AWVALID_M1;
logic AWREADY_M1;
//WRITE DATA
logic [`AXI_DATA_BITS-1:0] WDATA_M1;
logic [`AXI_STRB_BITS-1:0] WSTRB_M1;
logic WLAST_M1;
logic WVALID_M1;
logic WREADY_M1;
//WRITE RESPONSE
logic [`AXI_ID_BITS-1:0] BID_M1;
logic [1:0] BRESP_M1;
logic BVALID_M1;
logic BREADY_M1;

//READ ADDRESS0
logic [`AXI_ID_BITS-1:0] ARID_M0;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M0;
logic [`AXI_LEN_BITS-1:0] ARLEN_M0;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0;
logic [1:0] ARBURST_M0;
logic ARVALID_M0;
logic ARREADY_M0;
//READ DATA0
logic [`AXI_ID_BITS-1:0] RID_M0;
logic [`AXI_DATA_BITS-1:0] RDATA_M0;
logic [1:0] RRESP_M0;
logic RLAST_M0;
logic RVALID_M0;
logic RREADY_M0;
//READ ADDRESS1
logic [`AXI_ID_BITS-1:0] ARID_M1;
logic [`AXI_ADDR_BITS-1:0] ARADDR_M1;
logic [`AXI_LEN_BITS-1:0] ARLEN_M1;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1;
logic [1:0] ARBURST_M1;
logic ARVALID_M1;
logic ARREADY_M1;
//READ DATA1
logic [`AXI_ID_BITS-1:0] RID_M1;
logic [`AXI_DATA_BITS-1:0] RDATA_M1;
logic [1:0] RRESP_M1;
logic RLAST_M1;
logic RVALID_M1;
logic RREADY_M1;

//MASTER INTERFACE FOR SLAVES
//WRITE ADDRESS0
logic [`AXI_IDS_BITS-1:0] AWID_S0;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S0;
logic [`AXI_LEN_BITS-1:0] AWLEN_S0;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0;
logic [1:0] AWBURST_S0;
logic AWVALID_S0;
logic AWREADY_S0;
//WRITE DATA0
logic [`AXI_DATA_BITS-1:0] WDATA_S0;
logic [`AXI_STRB_BITS-1:0] WSTRB_S0;
logic WLAST_S0;
logic WVALID_S0;
logic WREADY_S0;
//WRITE RESPONSE0
logic [`AXI_IDS_BITS-1:0] BID_S0;
logic [1:0] BRESP_S0;
logic BVALID_S0;
logic BREADY_S0;

//WRITE ADDRESS1
logic [`AXI_IDS_BITS-1:0] AWID_S1;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S1;
logic [`AXI_LEN_BITS-1:0] AWLEN_S1;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1;
logic [1:0] AWBURST_S1;
logic AWVALID_S1;
logic AWREADY_S1;
//WRITE DATA1
logic [`AXI_DATA_BITS-1:0] WDATA_S1;
logic [`AXI_STRB_BITS-1:0] WSTRB_S1;
logic WLAST_S1;
logic WVALID_S1;
logic WREADY_S1;
//WRITE RESPONSE1
logic [`AXI_IDS_BITS-1:0] BID_S1;
logic [1:0] BRESP_S1;
logic BVALID_S1;
logic BREADY_S1;

//READ ADDRESS0
logic [`AXI_IDS_BITS-1:0] ARID_S0;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S0;
logic [`AXI_LEN_BITS-1:0] ARLEN_S0;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0;
logic [1:0] ARBURST_S0;
logic ARVALID_S0;
logic ARREADY_S0;
//READ DATA0
logic [`AXI_IDS_BITS-1:0] RID_S0;
logic [`AXI_DATA_BITS-1:0] RDATA_S0;
logic [1:0] RRESP_S0;
logic RLAST_S0;
logic RVALID_S0;
logic RREADY_S0;
//READ ADDRESS1
logic [`AXI_IDS_BITS-1:0] ARID_S1;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S1;
logic [`AXI_LEN_BITS-1:0] ARLEN_S1;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1;
logic [1:0] ARBURST_S1;
logic ARVALID_S1;
logic ARREADY_S1;
//READ DATA1
logic [`AXI_IDS_BITS-1:0] RID_S1;
logic [`AXI_DATA_BITS-1:0] RDATA_S1;
logic [1:0] RRESP_S1;
logic RLAST_S1;
logic RVALID_S1;
logic RREADY_S1;



/////////////////////////////////////////////////////////////////////////////
/* CPU has been wrapped by CPUwrapper
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
*/

CPU_wrapper cpu(
    .clk(clk),
    .rst_n(!rst),
    //WRITE ADDRESS
    .AWID_M1(AWID_M1),
    .AWADDR_M1(AWADDR_M1),
    .AWLEN_M1(AWLEN_M1),
    .AWSIZE_M1(AWSIZE_M1),
    .AWBURST_M1(AWBURST_M1),
    .AWVALID_M1(AWVALID_M1),
    .AWREADY_M1(AWREADY_M1),
    //WRITE DATA
    .WDATA_M1(WDATA_M1),
    .WSTRB_M1(WSTRB_M1),
    .WLAST_M1(WLAST_M1),
    .WVALID_M1(WVALID_M1),
    .WREADY_M1(WREADY_M1),
    //WRITE RESPONSE
    .BID_M1(BID_M1),
    .BRESP_M1(BRESP_M1),
    .BVALID_M1(BVALID_M1),
    .BREADY_M1(BREADY_M1),
    //READ ADDRESS0
    .ARID_M0(ARID_M0),
    .ARADDR_M0(ARADDR_M0),
    .ARLEN_M0(ARLEN_M0),
    .ARSIZE_M0(ARSIZE_M0),
    .ARBURST_M0(ARBURST_M0),
    .ARVALID_M0(ARVALID_M0),
    .ARREADY_M0(ARREADY_M0),
    //READ DATA0
    .RID_M0(RID_M0),
    .RDATA_M0(RDATA_M0),
    .RRESP_M0(RRESP_M0),
    .RLAST_M0(RLAST_M0),
    .RVALID_M0(RVALID_M0),
    .RREADY_M0(RREADY_M0),
    //READ ADDRESS1
    .ARID_M1(ARID_M1),
    .ARADDR_M1(ARADDR_M1),
    .ARLEN_M1(ARLEN_M1),
    .ARSIZE_M1(ARSIZE_M1),
    .ARBURST_M1(ARBURST_M1),
    .ARVALID_M1(ARVALID_M1),
    .ARREADY_M1(ARREADY_M1),
    //READ DATA1
    .RID_M1(RID_M1),
    .RDATA_M1(RDATA_M1),
    .RRESP_M1(RRESP_M1),
    .RLAST_M1(RLAST_M1),
    .RVALID_M1(RVALID_M1),
    .RREADY_M1(RREADY_M1)
    /*
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
    */
); 

AXI axi(
    .ACLK(clk),
	.ARESETn(~rst),
	.AWID_M1(AWID_M1),
	.AWADDR_M1(AWADDR_M1),
	.AWLEN_M1(AWLEN_M1),
	.AWSIZE_M1(AWSIZE_M1),
	.AWBURST_M1(AWBURST_M1),
	.AWVALID_M1(AWVALID_M1),
	.AWREADY_M1(AWREADY_M1),
	.WDATA_M1(WDATA_M1),
	.WSTRB_M1(WSTRB_M1),
	.WLAST_M1(WLAST_M1),
	.WVALID_M1(WVALID_M1),
	.WREADY_M1(WREADY_M1),
	.BID_M1(BID_M1),
	.BRESP_M1(BRESP_M1),
	.BVALID_M1(BVALID_M1),
	.BREADY_M1(BREADY_M1),
	.ARID_M0(ARID_M0),
	.ARADDR_M0(ARADDR_M0),
	.ARLEN_M0(ARLEN_M0),
	.ARSIZE_M0(ARSIZE_M0),
	.ARBURST_M0(ARBURST_M0),
	.ARVALID_M0(ARVALID_M0),
	.ARREADY_M0(ARREADY_M0),
	.RID_M0(RID_M0),
	.RDATA_M0(RDATA_M0),
	.RRESP_M0(RRESP_M0),
	.RLAST_M0(RLAST_M0),
	.RVALID_M0(RVALID_M0),
	.RREADY_M0(RREADY_M0),
	.ARID_M1(ARID_M1),
	.ARADDR_M1(ARADDR_M1),
	.ARLEN_M1(ARLEN_M1),
	.ARSIZE_M1(ARSIZE_M1),
	.ARBURST_M1(ARBURST_M1),
	.ARVALID_M1(ARVALID_M1),
	.ARREADY_M1(ARREADY_M1),
	.RID_M1(RID_M1),
	.RDATA_M1(RDATA_M1),
	.RRESP_M1(RRESP_M1),
	.RLAST_M1(RLAST_M1),
	.RVALID_M1(RVALID_M1),
	.RREADY_M1(RREADY_M1),
    //
	.AWID_S0(AWID_S0),
	.AWADDR_S0(AWADDR_S0),
	.AWLEN_S0(AWLEN_S0),
	.AWSIZE_S0(AWSIZE_S0),
	.AWBURST_S0(AWBURST_S0),
	.AWVALID_S0(AWVALID_S0),
	.AWREADY_S0(AWREADY_S0),
	.WDATA_S0(WDATA_S0),
	.WSTRB_S0(WSTRB_S0),
	.WLAST_S0(WLAST_S0),
	.WVALID_S0(WVALID_S0),
	.WREADY_S0(WREADY_S0),
	.BID_S0(BID_S0),
	.BRESP_S0(BRESP_S0),
	.BVALID_S0(BVALID_S0),
	.BREADY_S0(BREADY_S0),
	.AWID_S1(AWID_S1),
	.AWADDR_S1(AWADDR_S1),
	.AWLEN_S1(AWLEN_S1),
	.AWSIZE_S1(AWSIZE_S1),
	.AWBURST_S1(AWBURST_S1),
	.AWVALID_S1(AWVALID_S1),
	.AWREADY_S1(AWREADY_S1),
	.WDATA_S1(WDATA_S1),
	.WSTRB_S1(WSTRB_S1),
	.WLAST_S1(WLAST_S1),
	.WVALID_S1(WVALID_S1),
	.WREADY_S1(WREADY_S1),
	.BID_S1(BID_S1),
	.BRESP_S1(BRESP_S1),
	.BVALID_S1(BVALID_S1),
	.BREADY_S1(BREADY_S1),
	.ARID_S0(ARID_S0),
	.ARADDR_S0(ARADDR_S0),
	.ARLEN_S0(ARLEN_S0),
	.ARSIZE_S0(ARSIZE_S0),
	.ARBURST_S0(ARBURST_S0),
	.ARVALID_S0(ARVALID_S0),
	.ARREADY_S0(ARREADY_S0),
	.RID_S0(RID_S0),
	.RDATA_S0(RDATA_S0),
	.RRESP_S0(RRESP_S0),
	.RLAST_S0(RLAST_S0),
	.RVALID_S0(RVALID_S0),
	.RREADY_S0(RREADY_S0),
	.ARID_S1(ARID_S1),
	.ARADDR_S1(ARADDR_S1),
	.ARLEN_S1(ARLEN_S1),
	.ARSIZE_S1(ARSIZE_S1),
	.ARBURST_S1(ARBURST_S1),
	.ARVALID_S1(ARVALID_S1),
	.ARREADY_S1(ARREADY_S1),
	.RID_S1(RID_S1),
	.RDATA_S1(RDATA_S1),
	.RRESP_S1(RRESP_S1),
	.RLAST_S1(RLAST_S1),
	.RVALID_S1(RVALID_S1),
	.RREADY_S1(RREADY_S1)
);


SRAM_wrapper IM1(
    .clk(clk),
	.rst_n(!rst),
    //WRITE ADDRESS
	.AWID(AWID_S0),
	.AWADDR(AWADDR_S0),
	.AWLEN(AWLEN_S0),
	.AWSIZE(AWSIZE_S0),
	.AWBURST(AWBURST_S0),
	.AWVALID(AWVALID_S0),
	.AWREADY(AWREADY_S0),
    //WRITE DATA0
	.WDATA(WDATA_S0),
	.WSTRB(WSTRB_S0),
	.WLAST(WLAST_S0),
	.WVALID(WVALID_S0),
	.WREADY(WREADY_S0),
    //WRITE RESPONSE0
	.BID(BID_S0),
	.BRESP(BRESP_S0),
	.BVALID(BVALID_S0),
	.BREADY(BREADY_S0),
    //READ ADDRESS0
	.ARID(ARID_S0),
	.ARADDR(ARADDR_S0),
	.ARLEN(ARLEN_S0),
	.ARSIZE(ARSIZE_S0),
	.ARBURST(ARBURST_S0),
	.ARVALID(ARVALID_S0),
	.ARREADY(ARREADY_S0),
    //READ DATA0
	.RID(RID_S0),
	.RDATA(RDATA_S0),
	.RRESP(RRESP_S0),
	.RLAST(RLAST_S0),
	.RVALID(RVALID_S0),
	.RREADY(RREADY_S0)
    /*
    //WEB always high, DI can empty link(空接)
    .CK(clk),
    .CS(Enable),
    .OE(Enable),
    .WEB(WEB_Disable),
    .A(IM_address_wire),
    .DI(data_Disable),
    .DO(IM_Instruction_wire)
    */
    );
SRAM_wrapper DM1(
    .clk(clk),
	.rst_n(!rst),
     //WRITE ADDRESS
	.AWID(AWID_S1),
	.AWADDR(AWADDR_S1),
	.AWLEN(AWLEN_S1),
	.AWSIZE(AWSIZE_S1),
	.AWBURST(AWBURST_S1),
	.AWVALID(AWVALID_S1),
	.AWREADY(AWREADY_S1),
    //WRITE DATA0
	.WDATA(WDATA_S1),
	.WSTRB(WSTRB_S1),
	.WLAST(WLAST_S1),
	.WVALID(WVALID_S1),
	.WREADY(WREADY_S1),
    //WRITE RESPONSE0
	.BID(BID_S1),
	.BRESP(BRESP_S1),
	.BVALID(BVALID_S1),
	.BREADY(BREADY_S1),
    //READ ADDRESS0
	.ARID(ARID_S1),
	.ARADDR(ARADDR_S1),
	.ARLEN(ARLEN_S1),
	.ARSIZE(ARSIZE_S1),
	.ARBURST(ARBURST_S1),
	.ARVALID(ARVALID_S1),
	.ARREADY(ARREADY_S1),
    //READ DATA0
	.RID(RID_S1),
	.RDATA(RDATA_S1),
	.RRESP(RRESP_S1),
	.RLAST(RLAST_S1),
	.RVALID(RVALID_S1),
	.RREADY(RREADY_S1)
    /*
    .CK(clk),
    .CS(Enable),
    .OE(Enable),
    .WEB(WEB_wire),
    .A(DM_address_wire),
    .DI(DI_wire),
    .DO(DM_data_wire)
    */
);
endmodule
