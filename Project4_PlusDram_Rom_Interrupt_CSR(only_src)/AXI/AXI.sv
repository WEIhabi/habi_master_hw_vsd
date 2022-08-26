//================================================
// Auther:      Chen Tsung-Chi (Michael)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "AXI_define.svh"
`include "Write_Arbiter.sv"
`include "Read_Arbiter.sv"
`include "Read_address_channel.sv"
`include "Read_data_channel.sv"
`include "Write_address_channel.sv"
`include "Write_data_channel.sv"
`include "Write_response_channel.sv"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	//WRITE RESPONSE
	output logic  [`AXI_ID_BITS-1:0] BID_M1,
	output logic  [1:0] BRESP_M1,
	output logic  BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0 (NO)
    //WRITE DATA0    (NO)
    //WRITE RESPONSE0(NO)

	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
    //WRITE ADDRESS2
    output logic [`AXI_IDS_BITS-1:0]  AWID_S2,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
    output logic [`AXI_LEN_BITS-1:0]  AWLEN_S2,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
    output logic [1:0]                AWBURST_S2,
    output logic                      AWVALID_S2,
    input AWREADY_S2,
    //WRITE DATA2
    output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
    output logic                      WLAST_S2,
    output logic                      WVALID_S2,
    input WREADY_S2,
    //WRITE RESPONSE2
    input [`AXI_IDS_BITS-1:0] BID_S2,
    input [1:0]               BRESP_S2,
    input                     BVALID_S2,
    output logic BREADY_S2,

    //WRITE ADDRESS3
    output logic [`AXI_IDS_BITS-1:0]  AWID_S3,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
    output logic [`AXI_LEN_BITS-1:0]  AWLEN_S3,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
    output logic [1:0]                AWBURST_S3,
    output logic                      AWVALID_S3,
    input AWREADY_S3,
    //WRITE DATA3
    output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
    output logic                      WLAST_S3,
    output logic                      WVALID_S3,
    input WREADY_S3,
    //WRITE RESPONSE3
    input [`AXI_IDS_BITS-1:0] BID_S3,
    input [1:0]               BRESP_S3,
    input                     BVALID_S3,
    output logic BREADY_S3,

    //WRITE ADDRESS4
    output logic [`AXI_IDS_BITS-1:0]  AWID_S4,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
    output logic [`AXI_LEN_BITS-1:0]  AWLEN_S4,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
    output logic [1:0]                AWBURST_S4,
    output logic                      AWVALID_S4,
    input AWREADY_S4,
    //WRITE DATA4
    output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
    output logic                      WLAST_S4,
    output logic                      WVALID_S4,
    input WREADY_S4,
    //WRITE RESPONSE4
    input [`AXI_IDS_BITS-1:0] BID_S4,
    input [1:0]               BRESP_S4,
    input                     BVALID_S4,
    output logic BREADY_S4,


	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output ARVALID_S0,
	input ARREADY_S0,
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,
    
    //READ ADDRESS2
    output logic [`AXI_IDS_BITS-1:0]  ARID_S2,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
    output logic [`AXI_LEN_BITS-1:0]  ARLEN_S2,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
    output logic [1:0]                ARBURST_S2,
    output logic                      ARVALID_S2,
    input ARREADY_S2,
    //READ DATA2
    input [`AXI_IDS_BITS-1:0]  RID_S2,
    input [`AXI_DATA_BITS-1:0] RDATA_S2,
    input [1:0]                RRESP_S2,
    input                      RLAST_S2,
    input                      RVALID_S2,
    output logic RREADY_S2,

    //READ ADDRESS3
    output logic [`AXI_IDS_BITS-1:0]  ARID_S3,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
    output logic [`AXI_LEN_BITS-1:0]  ARLEN_S3,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
    output logic [1:0]                ARBURST_S3,
    output logic                      ARVALID_S3,
    input ARREADY_S3,
    //READ DATA3
    input [`AXI_IDS_BITS-1:0]  RID_S3,
    input [`AXI_DATA_BITS-1:0] RDATA_S3,
    input [1:0]                RRESP_S3,
    input                      RLAST_S3,
    input                      RVALID_S3,
    output logic RREADY_S3,

    //READ ADDRESS4
    output logic [`AXI_IDS_BITS-1:0]  ARID_S4,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
    output logic [`AXI_LEN_BITS-1:0]  ARLEN_S4,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
    output logic [1:0]                ARBURST_S4,
    output logic                      ARVALID_S4,
    input ARREADY_S4,
    //READ DATA4
    input [`AXI_IDS_BITS-1:0]  RID_S4,
    input [`AXI_DATA_BITS-1:0] RDATA_S4,
    input [1:0]                RRESP_S4,
    input                      RLAST_S4,
    input                      RVALID_S4,
    output logic RREADY_S4
	
);
    //---------- you should put your design here ----------//
	
logic [1:0] Aibiter_Read_State_control;
logic [3:0] Arbiter_ARID_control;

logic [1:0] Aibiter_Write_State_control;
logic [3:0] Arbiter_AWID_control;

logic AWREADY_M0;
logic WREADY_M0;

logic [1:0] BRESP_M0;
logic [3:0] BID_M0;
logic       BVALID_M0;




Write_Arbiter write_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
    //write data address
    .AWADDR_M0(32'b0),   //addr
    .AWADDR_M1(AWADDR_M1),
    .AWVALID_M0(1'b0),          //valid
    .AWVALID_M1(AWVALID_M1),
    //
    .BVALID_M0(1'b0),           
    .BVALID_M1(BVALID_M1),
    .BREADY_M0(1'b0),
    .BREADY_M1(BREADY_M1),
    //
    .Aibiter_Write_State_control(Aibiter_Write_State_control),
    .Arbiter_AWID_control(Arbiter_AWID_control)
);

Write_address_channel write_address_channel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
	.Aibiter_Write_State_control(Aibiter_Write_State_control),
    .Arbiter_AWID_control(Arbiter_AWID_control),
    //M to S
    //M0
    .AWID_M0(4'b0),    
    .AWADDR_M0(32'b0),
    .AWLEN_M0(4'b0001),
    .AWSIZE_M0(3'b010),   
    .AWBURST_M0(2'b0),
    .AWVALID_M0(1'b0),
    //M1
    .AWID_M1(AWID_M1),    
    .AWADDR_M1(AWADDR_M1),
    .AWLEN_M1(AWLEN_M1),
    .AWSIZE_M1(AWSIZE_M1),
    .AWBURST_M1(AWBURST_M1),
    .AWVALID_M1(AWVALID_M1),
    //S1
    .AWID_S1(AWID_S1),    
    .AWADDR_S1(AWADDR_S1),
    .AWLEN_S1(AWLEN_S1),
    .AWSIZE_S1(AWSIZE_S1),
    .AWBURST_S1(AWBURST_S1),
    .AWVALID_S1(AWVALID_S1),
    //S2
    .AWID_S2(AWID_S2),
    .AWADDR_S2(AWADDR_S2),
    .AWLEN_S2(AWLEN_S2),
    .AWSIZE_S2(AWSIZE_S2),
    .AWBURST_S2(AWBURST_S2),
    .AWVALID_S2(AWVALID_S2),
    //S3
    .AWID_S3(AWID_S3),
    .AWADDR_S3(AWADDR_S3),
    .AWLEN_S3(AWLEN_S3),
    .AWSIZE_S3(AWSIZE_S3),
    .AWBURST_S3(AWBURST_S3),
    .AWVALID_S3(AWVALID_S3),
    //S4
    .AWID_S4(AWID_S4),
    .AWADDR_S4(AWADDR_S4),
    .AWLEN_S4(AWLEN_S4),
    .AWSIZE_S4(AWSIZE_S4),
    .AWBURST_S4(AWBURST_S4),
    .AWVALID_S4(AWVALID_S4),
    //S to M
    //.AWREADY_S0(AWREADY_S0),
    .AWREADY_S1(AWREADY_S1),
    .AWREADY_S2(AWREADY_S2),
    .AWREADY_S3(AWREADY_S3),
    .AWREADY_S4(AWREADY_S4),
    .AWREADY_M0(AWREADY_M0),
    .AWREADY_M1(AWREADY_M1)
);

Write_data_channel write_data_channel(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
    .Aibiter_Write_State_control(Aibiter_Write_State_control),
    .Arbiter_AWID_control(Arbiter_AWID_control),
    //M to S 
    //M0  
    .WDATA_M0(32'b0),
    .WSTRB_M0(4'b0),    // for narrow transfers
    .WLAST_M0(1'b0),
    .WVALID_M0(1'b0),
    //M1      
    .WDATA_M1(WDATA_M1),
    .WSTRB_M1(WSTRB_M1),     
    .WLAST_M1(WLAST_M1),
    .WVALID_M1(WVALID_M1),
    //write data channel output
    //S1
    .WDATA_S1(WDATA_S1),
    .WSTRB_S1(WSTRB_S1),     
    .WLAST_S1(WLAST_S1),
    .WVALID_S1(WVALID_S1),
    //S2
    .WDATA_S2(WDATA_S2),
    .WSTRB_S2(WSTRB_S2),
    .WLAST_S2(WLAST_S2),
    .WVALID_S2(WVALID_S2),
    //S3
    .WDATA_S3(WDATA_S3),
    .WSTRB_S3(WSTRB_S3),
    .WLAST_S3(WLAST_S3),
    .WVALID_S3(WVALID_S3),
    //S4
    .WDATA_S4(WDATA_S4),
    .WSTRB_S4(WSTRB_S4),
    .WLAST_S4(WLAST_S4),
    .WVALID_S4(WVALID_S4),
    //S to M 
    .WREADY_S1(WREADY_S1),
    .WREADY_S2(WREADY_S2),
    .WREADY_S3(WREADY_S3),
    .WREADY_S4(WREADY_S4),
    .WREADY_M0(WREADY_M0),
    .WREADY_M1(WREADY_M1)
);

Write_response_channel write_response_channel(
    .ACLK(ACLK),
	.ARESETn(ARESETn),
    .Aibiter_Write_State_control(Aibiter_Write_State_control),
    .Arbiter_AWID_control(Arbiter_AWID_control),
    //S to M
    
    //S1
    .BID_S1(BID_S1),
    .BRESP_S1(BRESP_S1),
    .BVALID_S1(BVALID_S1),
    //S2
    .BID_S2(BID_S2),
    .BRESP_S2(BRESP_S2),
    .BVALID_S2(BVALID_S2),
    //S3
    .BID_S3(BID_S3),
    .BRESP_S3(BRESP_S3),
    .BVALID_S3(BVALID_S3),
    //S4
    .BID_S4(BID_S4),
    .BRESP_S4(BRESP_S4),
    .BVALID_S4(BVALID_S4),
    //M0
    .BID_M0(BID_M0),
    .BRESP_M0(BRESP_M0),
    .BVALID_M0(BVALID_M0),
    //M1
    .BID_M1(BID_M1),
    .BRESP_M1(BRESP_M1),
    .BVALID_M1(BVALID_M1),
    //M to S
    .BREADY_M0(1'b0),
    .BREADY_M1(BREADY_M1),
    //.BREADY_S0(BREADY_S0),
    .BREADY_S1(BREADY_S1),
    .BREADY_S2(BREADY_S2),
    .BREADY_S3(BREADY_S3),
    .BREADY_S4(BREADY_S4)
);

Read_Arbiter read_arbiter(
	.ACLK(ACLK),
	.ARESETn(ARESETn),
    //write address
	.ARADDR_M0(ARADDR_M0),
    .ARADDR_M1(ARADDR_M1),
    .ARVALID_M0(ARVALID_M0),
	.ARVALID_M1(ARVALID_M1),
    //read address
    .RVALID_M0(RVALID_M0),           
    .RVALID_M1(RVALID_M1),
    .RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    //
    .ARREADY_M0(ARREADY_M0),
    .ARREADY_M1(ARREADY_M1),
    .ARLEN_M0(ARLEN_M0),
    .RLAST_M0(RLAST_M0),
    .ARLEN_M1(ARLEN_M1),
    .RLAST_M1(RLAST_M1),
    //
    .Aibiter_Read_State_control(Aibiter_Read_State_control),
    .Arbiter_ARID_control(Arbiter_ARID_control)
);

Read_address_channel read_address_channel(
	.ACLK(ACLK),
    .ARESETn(ARESETn),
	//
	.Aibiter_Read_State_control(Aibiter_Read_State_control),
    .Arbiter_ARID_control(Arbiter_ARID_control),
	//
    .ARID_M0(ARID_M0),
    .ARADDR_M0(ARADDR_M0),
    .ARLEN_M0(ARLEN_M0),
    .ARSIZE_M0(ARSIZE_M0),
    .ARBURST_M0(ARBURST_M0),
    .ARVALID_M0(ARVALID_M0),
	//
    .ARID_M1(ARID_M1),
    .ARADDR_M1(ARADDR_M1),
    .ARLEN_M1(ARLEN_M1),
    .ARSIZE_M1(ARSIZE_M1),
    .ARBURST_M1(ARBURST_M1),
    .ARVALID_M1(ARVALID_M1),
	//
    .ARID_S0(ARID_S0),
    .ARADDR_S0(ARADDR_S0),
    .ARLEN_S0(ARLEN_S0),
    .ARSIZE_S0(ARSIZE_S0),
    .ARBURST_S0(ARBURST_S0),
    .ARVALID_S0(ARVALID_S0),
	//
    .ARID_S1(ARID_S1),
    .ARADDR_S1(ARADDR_S1),
    .ARLEN_S1(ARLEN_S1),
    .ARSIZE_S1(ARSIZE_S1),
    .ARBURST_S1(ARBURST_S1),
    .ARVALID_S1(ARVALID_S1),
    //
    .ARID_S2(ARID_S2),
    .ARADDR_S2(ARADDR_S2),
    .ARLEN_S2(ARLEN_S2),
    .ARSIZE_S2(ARSIZE_S2),
    .ARBURST_S2(ARBURST_S2),
    .ARVALID_S2(ARVALID_S2),
    //
    .ARID_S3(ARID_S3),
    .ARADDR_S3(ARADDR_S3),
    .ARLEN_S3(ARLEN_S3),
    .ARSIZE_S3(ARSIZE_S3),
    .ARBURST_S3(ARBURST_S3),
    .ARVALID_S3(ARVALID_S3),
    //
    .ARID_S4(ARID_S4),
    .ARADDR_S4(ARADDR_S4),
    .ARLEN_S4(ARLEN_S4),
    .ARSIZE_S4(ARSIZE_S4),
    .ARBURST_S4(ARBURST_S4),
    .ARVALID_S4(ARVALID_S4),
	//
    .ARREADY_S0(ARREADY_S0),
    .ARREADY_S1(ARREADY_S1),
    .ARREADY_S2(ARREADY_S2),
    .ARREADY_S3(ARREADY_S3),
    .ARREADY_S4(ARREADY_S4),
    .ARREADY_M0(ARREADY_M0),
    .ARREADY_M1(ARREADY_M1)
);

Read_data_channel read_data_channel(
	.ACLK(ACLK),
    .ARESETn(ARESETn),
	//
	.Aibiter_Read_State_control(Aibiter_Read_State_control),
    .Arbiter_ARID_control(Arbiter_ARID_control),
	//
    .RID_S0(RID_S0),
    .RDATA_S0(RDATA_S0),
    .RRESP_S0(RRESP_S0),
    .RLAST_S0(RLAST_S0),
    .RVALID_S0(RVALID_S0),
	//
    .RID_S1(RID_S1),
    .RDATA_S1(RDATA_S1),
    .RRESP_S1(RRESP_S1),
    .RLAST_S1(RLAST_S1),
    .RVALID_S1(RVALID_S1),
	//
    .RID_S2(RID_S2),
    .RDATA_S2(RDATA_S2),
    .RRESP_S2(RRESP_S2),
    .RLAST_S2(RLAST_S2),
    .RVALID_S2(RVALID_S2),
    //
    .RID_S3(RID_S3),
    .RDATA_S3(RDATA_S3),
    .RRESP_S3(RRESP_S3),
    .RLAST_S3(RLAST_S3),
    .RVALID_S3(RVALID_S3),
    //
    .RID_S4(RID_S4),
    .RDATA_S4(RDATA_S4),
    .RRESP_S4(RRESP_S4),
    .RLAST_S4(RLAST_S4),
    .RVALID_S4(RVALID_S4),
    //
    .RID_M0(RID_M0),
    .RDATA_M0(RDATA_M0),
    .RRESP_M0(RRESP_M0),
    .RLAST_M0(RLAST_M0),
    .RVALID_M0(RVALID_M0),
	//
    .RID_M1(RID_M1),
    .RDATA_M1(RDATA_M1),
    .RRESP_M1(RRESP_M1),
    .RLAST_M1(RLAST_M1),
    .RVALID_M1(RVALID_M1),
	//
	.RREADY_M0(RREADY_M0),
    .RREADY_M1(RREADY_M1),
    .RREADY_S0(RREADY_S0),
    .RREADY_S1(RREADY_S1),
    .RREADY_S2(RREADY_S2),
    .RREADY_S3(RREADY_S3),
    .RREADY_S4(RREADY_S4)
);
	
	
endmodule
