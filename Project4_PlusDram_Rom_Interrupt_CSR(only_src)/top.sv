`include "SRAM_wrapper.sv"
`include "CPU_wrapper.sv"
`include "./AXI/AXI.sv"
`include "ROM_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "SCtrl_wrapper.sv"
`include "sensor_ctrl.sv"

module top(
    input clk, rst,

	//sensor
	input        sensor_ready,
	input [31:0] sensor_out,
	output logic sensor_en,
	
	//ROM
	input [31:0] ROM_out,
	output logic        ROM_read,
	output logic        ROM_enable,
	output logic [13:0] ROM_address,

	//DRAM
	input [31:0] DRAM_Q,
	input        DRAM_valid,
	output logic        DRAM_CSn,
	output logic [3:0]  DRAM_WEn,
	output logic        DRAM_RASn,
	output logic        DRAM_CASn,
	output logic [10:0] DRAM_A,
	output logic [31:0] DRAM_D
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

/*
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
*/

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

//WRITE ADDRESS2
logic [`AXI_IDS_BITS-1:0]  AWID_S2;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S2;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S2;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2;
logic [1:0]                AWBURST_S2;
logic                      AWVALID_S2;
logic                      AWREADY_S2;
//WRITE DATA2
logic [`AXI_DATA_BITS-1:0] WDATA_S2;
logic [`AXI_STRB_BITS-1:0] WSTRB_S2;
logic                      WLAST_S2;
logic                      WVALID_S2;
logic                      WREADY_S2;
//WRITE RESPONSE2
logic [`AXI_IDS_BITS-1:0] BID_S2;
logic [1:0]               BRESP_S2;
logic                     BVALID_S2;
logic                     BREADY_S2;

//WRITE ADDRESS3
logic [`AXI_IDS_BITS-1:0]  AWID_S3;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S3;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S3;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3;
logic [1:0]                AWBURST_S3;
logic                      AWVALID_S3;
logic                      AWREADY_S3;
//WRITE DATA3
logic [`AXI_DATA_BITS-1:0] WDATA_S3;
logic [`AXI_STRB_BITS-1:0] WSTRB_S3;
logic                      WLAST_S3;
logic                      WVALID_S3;
logic                      WREADY_S3;
//WRITE RESPONSE3
logic [`AXI_IDS_BITS-1:0] BID_S3;
logic [1:0]               BRESP_S3;
logic                     BVALID_S3;
logic                     BREADY_S3;

//WRITE ADDRESS4
logic [`AXI_IDS_BITS-1:0]  AWID_S4;
logic [`AXI_ADDR_BITS-1:0] AWADDR_S4;
logic [`AXI_LEN_BITS-1:0]  AWLEN_S4;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4;
logic [1:0]                AWBURST_S4;
logic                      AWVALID_S4;
logic                      AWREADY_S4;
//WRITE DATA4
logic [`AXI_DATA_BITS-1:0] WDATA_S4;
logic [`AXI_STRB_BITS-1:0] WSTRB_S4;
logic                      WLAST_S4;
logic                      WVALID_S4;
logic                      WREADY_S4;
//WRITE RESPONSE4
logic [`AXI_IDS_BITS-1:0] BID_S4;
logic [1:0]               BRESP_S4;
logic                     BVALID_S4;
logic                     BREADY_S4;


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

 //READ ADDRESS2
logic [`AXI_IDS_BITS-1:0]  ARID_S2;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S2;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S2;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2;
logic [1:0]                ARBURST_S2;
logic                      ARVALID_S2;
logic ARREADY_S2;
//READ DATA2
logic [`AXI_IDS_BITS-1:0]  RID_S2;
logic [`AXI_DATA_BITS-1:0] RDATA_S2;
logic [1:0]                RRESP_S2;
logic                      RLAST_S2;
logic                     RVALID_S2;
logic RREADY_S2;

//READ ADDRESS3
logic [`AXI_IDS_BITS-1:0]  ARID_S3;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S3;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S3;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3;
logic [1:0]                ARBURST_S3;
logic                      ARVALID_S3;
logic ARREADY_S3;
//READ DATA3
logic [`AXI_IDS_BITS-1:0]  RID_S3;
logic [`AXI_DATA_BITS-1:0] RDATA_S3;
logic [1:0]                RRESP_S3;
logic                      RLAST_S3;
logic                      RVALID_S3;
logic RREADY_S3;

//READ ADDRESS4
logic [`AXI_IDS_BITS-1:0]  ARID_S4;
logic [`AXI_ADDR_BITS-1:0] ARADDR_S4;
logic [`AXI_LEN_BITS-1:0]  ARLEN_S4;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4;
logic [1:0]                ARBURST_S4;
logic                      ARVALID_S4;
logic ARREADY_S4;
//READ DATA4
logic [`AXI_IDS_BITS-1:0]  RID_S4;
logic [`AXI_DATA_BITS-1:0] RDATA_S4;
logic [1:0]                RRESP_S4;
logic                      RLAST_S4;
logic                      RVALID_S4;
logic RREADY_S4;

//sensor control
logic        sctrl_en, sctrl_clear;
logic [5:0]  sctrl_addr;
logic        sctrl_interrupt, interrupt;
logic [31:0] sctrl_out;

/////////////////////////////////////////////////////////////////////////////


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
    .RREADY_M1(RREADY_M1),

    //hw4 new add
	.interrupt(interrupt)
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
    //no Write to S0
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
	//
	.AWID_S2(AWID_S2),
	.AWADDR_S2(AWADDR_S2),
	.AWLEN_S2(AWLEN_S2),
	.AWSIZE_S2(AWSIZE_S2),
	.AWBURST_S2(AWBURST_S2),
	.AWVALID_S2(AWVALID_S2),
	.AWREADY_S2(AWREADY_S2),
	.WDATA_S2(WDATA_S2),
	.WSTRB_S2(WSTRB_S2),
	.WLAST_S2(WLAST_S2),
	.WVALID_S2(WVALID_S2),
	.WREADY_S2(WREADY_S2),
	.BID_S2(BID_S2),
	.BRESP_S2(BRESP_S2),
	.BVALID_S2(BVALID_S2),
	.BREADY_S2(BREADY_S2),
	.AWID_S3(AWID_S3),
	.AWADDR_S3(AWADDR_S3),
	.AWLEN_S3(AWLEN_S3),
	.AWSIZE_S3(AWSIZE_S3),
	.AWBURST_S3(AWBURST_S3),
	.AWVALID_S3(AWVALID_S3),
	.AWREADY_S3(AWREADY_S3),
	.WDATA_S3(WDATA_S3),
	.WSTRB_S3(WSTRB_S3),
	.WLAST_S3(WLAST_S3),
	.WVALID_S3(WVALID_S3),
	.WREADY_S3(WREADY_S3),
	.BID_S3(BID_S3),
	.BRESP_S3(BRESP_S3),
	.BVALID_S3(BVALID_S3),
	.BREADY_S3(BREADY_S3),
	.AWID_S4(AWID_S4),
	.AWADDR_S4(AWADDR_S4),
	.AWLEN_S4(AWLEN_S4),
	.AWSIZE_S4(AWSIZE_S4),
	.AWBURST_S4(AWBURST_S4),
	.AWVALID_S4(AWVALID_S4),
	.AWREADY_S4(AWREADY_S4),
	.WDATA_S4(WDATA_S4),
	.WSTRB_S4(WSTRB_S4),
	.WLAST_S4(WLAST_S4),
	.WVALID_S4(WVALID_S4),
	.WREADY_S4(WREADY_S4),
	.BID_S4(BID_S4),
	.BRESP_S4(BRESP_S4),
	.BVALID_S4(BVALID_S4),
	.BREADY_S4(BREADY_S4),
	//
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
	.RREADY_S1(RREADY_S1),
	.ARID_S2(ARID_S2),
	.ARADDR_S2(ARADDR_S2),
	.ARLEN_S2(ARLEN_S2),
	.ARSIZE_S2(ARSIZE_S2),
	.ARBURST_S2(ARBURST_S2),
	.ARVALID_S2(ARVALID_S2),
	.ARREADY_S2(ARREADY_S2),
	.RID_S2(RID_S2),
	.RDATA_S2(RDATA_S2),
	.RRESP_S2(RRESP_S2),
	.RLAST_S2(RLAST_S2),
	.RVALID_S2(RVALID_S2),
	.RREADY_S2(RREADY_S2),
	.ARID_S3(ARID_S3),
	.ARADDR_S3(ARADDR_S3),
	.ARLEN_S3(ARLEN_S3),
	.ARSIZE_S3(ARSIZE_S3),
	.ARBURST_S3(ARBURST_S3),
	.ARVALID_S3(ARVALID_S3),
	.ARREADY_S3(ARREADY_S3),
	.RID_S3(RID_S3),
	.RDATA_S3(RDATA_S3),
	.RRESP_S3(RRESP_S3),
	.RLAST_S3(RLAST_S3),
	.RVALID_S3(RVALID_S3),
	.RREADY_S3(RREADY_S3),
	.ARID_S4(ARID_S4),
	.ARADDR_S4(ARADDR_S4),
	.ARLEN_S4(ARLEN_S4),
	.ARSIZE_S4(ARSIZE_S4),
	.ARBURST_S4(ARBURST_S4),
	.ARVALID_S4(ARVALID_S4),
	.ARREADY_S4(ARREADY_S4),
	.RID_S4(RID_S4),
	.RDATA_S4(RDATA_S4),
	.RRESP_S4(RRESP_S4),
	.RLAST_S4(RLAST_S4),
	.RVALID_S4(RVALID_S4),
	.RREADY_S4(RREADY_S4)	
);


ROM_wrapper ROM1(
	.clk(clk),
	.rst_n(!rst),
	.ROM_out(ROM_out),
	.ROM_read(ROM_read),
	.ROM_enable(ROM_enable),
	.ROM_address(ROM_address),
	.ARID(ARID_S0),
	.ARADDR(ARADDR_S0),
	.ARLEN(ARLEN_S0),
	.ARSIZE(ARSIZE_S0),
	.ARBURST(ARBURST_S0),
	.ARVALID(ARVALID_S0),
	.ARREADY(ARREADY_S0),
	.RID(RID_S0),
	.RDATA(RDATA_S0),
	.RRESP(RRESP_S0),
	.RLAST(RLAST_S0),
	.RVALID(RVALID_S0),
	.RREADY(RREADY_S0)
);

SRAM_wrapper IM1(
	.clk(clk),
	.rst_n(~rst),
	.AWID(AWID_S1),
	.AWADDR(AWADDR_S1),
	.AWLEN(AWLEN_S1),
	.AWSIZE(AWSIZE_S1),
	.AWBURST(AWBURST_S1),
	.AWVALID(AWVALID_S1),
	.AWREADY(AWREADY_S1),
	.WDATA(WDATA_S1),
	.WSTRB(WSTRB_S1),
	.WLAST(WLAST_S1),
	.WVALID(WVALID_S1),
	.WREADY(WREADY_S1),
	.BID(BID_S1),
	.BRESP(BRESP_S1),
	.BVALID(BVALID_S1),
	.BREADY(BREADY_S1),
	.ARID(ARID_S1),
	.ARADDR(ARADDR_S1),
	.ARLEN(ARLEN_S1),
	.ARSIZE(ARSIZE_S1),
	.ARBURST(ARBURST_S1),
	.ARVALID(ARVALID_S1),
	.ARREADY(ARREADY_S1),
	.RID(RID_S1),
	.RDATA(RDATA_S1),
	.RRESP(RRESP_S1),
	.RLAST(RLAST_S1),
	.RVALID(RVALID_S1),
	.RREADY(RREADY_S1)
    
    );
SRAM_wrapper DM1(
	.clk(clk),
	.rst_n(~rst),
	.AWID(AWID_S2),
	.AWADDR(AWADDR_S2),
	.AWLEN(AWLEN_S2),
	.AWSIZE(AWSIZE_S2),
	.AWBURST(AWBURST_S2),
	.AWVALID(AWVALID_S2),
	.AWREADY(AWREADY_S2),
	.WDATA(WDATA_S2),
	.WSTRB(WSTRB_S2),
	.WLAST(WLAST_S2),
	.WVALID(WVALID_S2),
	.WREADY(WREADY_S2),
	.BID(BID_S2),
	.BRESP(BRESP_S2),
	.BVALID(BVALID_S2),
	.BREADY(BREADY_S2),
	.ARID(ARID_S2),
	.ARADDR(ARADDR_S2),
	.ARLEN(ARLEN_S2),
	.ARSIZE(ARSIZE_S2),
	.ARBURST(ARBURST_S2),
	.ARVALID(ARVALID_S2),
	.ARREADY(ARREADY_S2),
	.RID(RID_S2),
	.RDATA(RDATA_S2),
	.RRESP(RRESP_S2),
	.RLAST(RLAST_S2),
	.RVALID(RVALID_S2),
	.RREADY(RREADY_S2)
);

SCtrl_wrapper SC1(
	.clk(clk),
	.rst(rst),
	.sctrl_en(sctrl_en),
	.sctrl_clear(sctrl_clear),
	.sctrl_addr(sctrl_addr),
	.sctrl_interrupt(sctrl_interrupt),
	.sctrl_out(sctrl_out),
	.cpu_interrupt(interrupt),
	.ARID(ARID_S3),
	.ARADDR(ARADDR_S3),
	.ARLEN(ARLEN_S3),
	.ARSIZE(ARSIZE_S3),
	.ARBURST(ARBURST_S3),
	.ARVALID(ARVALID_S3),
	.ARREADY(ARREADY_S3),
	.RID(RID_S3),
	.RDATA(RDATA_S3),
	.RRESP(RRESP_S3),
	.RLAST(RLAST_S3),
	.RVALID(RVALID_S3),
	.RREADY(RREADY_S3),
	.AWID(AWID_S3),
	.AWADDR(AWADDR_S3),
	.AWLEN(AWLEN_S3),
	.AWSIZE(AWSIZE_S3),
	.AWBURST(AWBURST_S3),
	.AWVALID(AWVALID_S3),
	.AWREADY(AWREADY_S3),
	.WDATA(WDATA_S3),
	.WSTRB(WSTRB_S3),
	.WLAST(WLAST_S3),
	.WVALID(WVALID_S3),
	.WREADY(WREADY_S3),
	.BID(BID_S3),
	.BRESP(BRESP_S3),
	.BVALID(BVALID_S3),
	.BREADY(BREADY_S3)
);

sensor_ctrl sensor(
	.clk(clk),
	.rst(rst),
	.sctrl_en(sctrl_en),
	.sctrl_clear(sctrl_clear),
	.sctrl_addr(sctrl_addr),
	.sensor_ready(sensor_ready),
	.sensor_out(sensor_out),
	.sctrl_interrupt(sctrl_interrupt),
	.sctrl_out(sctrl_out),
	.sensor_en(sensor_en)
);


DRAM_wrapper DRAM1(
	.clk(clk),
	.rst_n(!rst),
	.DRAM_Q(DRAM_Q),
	.DRAM_valid(DRAM_valid),
	.DRAM_CSn(DRAM_CSn),
	.DRAM_WEn(DRAM_WEn),
	.DRAM_RASn(DRAM_RASn),
	.DRAM_CASn(DRAM_CASn),
	.DRAM_A(DRAM_A),
	.DRAM_D(DRAM_D),
	.ARID(ARID_S4),
	.ARADDR(ARADDR_S4),
	.ARLEN(ARLEN_S4),
	.ARSIZE(ARSIZE_S4),
	.ARBURST(ARBURST_S4),
	.ARVALID(ARVALID_S4),
	.ARREADY(ARREADY_S4),
	.RID(RID_S4),
	.RDATA(RDATA_S4),
	.RRESP(RRESP_S4),
	.RLAST(RLAST_S4),
	.RVALID(RVALID_S4),
	.RREADY(RREADY_S4),
	.AWID(AWID_S4),
	.AWADDR(AWADDR_S4),
	.AWLEN(AWLEN_S4),
	.AWSIZE(AWSIZE_S4),
	.AWBURST(AWBURST_S4),
	.AWVALID(AWVALID_S4),
	.AWREADY(AWREADY_S4),
	.WDATA(WDATA_S4),
	.WSTRB(WSTRB_S4),
	.WLAST(WLAST_S4),
	.WVALID(WVALID_S4),
	.WREADY(WREADY_S4),
	.BID(BID_S4),
	.BRESP(BRESP_S4),
	.BVALID(BVALID_S4),
	.BREADY(BREADY_S4)
);


endmodule
