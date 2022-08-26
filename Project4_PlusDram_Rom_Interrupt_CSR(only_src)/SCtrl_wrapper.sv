`include "AXI_define.svh"

module SCtrl_wrapper(
input clk,
input rst,
output logic       sctrl_en,
output logic       sctrl_clear,
output logic [5:0] sctrl_addr,
input                      sctrl_interrupt,
input [`AXI_DATA_BITS-1:0] sctrl_out,
output logic cpu_interrupt,

//READ ADDRESS
input [`AXI_IDS_BITS-1:0]  ARID,
input [`AXI_ADDR_BITS-1:0] ARADDR,
input [`AXI_LEN_BITS-1:0]  ARLEN,
input [`AXI_SIZE_BITS-1:0] ARSIZE,
input [1:0]                ARBURST,
input                      ARVALID,
output logic ARREADY,
//READ DATA
output logic [`AXI_IDS_BITS-1:0]  RID,
output logic [`AXI_DATA_BITS-1:0] RDATA,
output logic [1:0]                RRESP,
output logic                      RLAST,
output logic                      RVALID,
input RREADY,

//WRITE ADDRESS
input [`AXI_IDS_BITS-1:0]  AWID,
input [`AXI_ADDR_BITS-1:0] AWADDR,
input [`AXI_LEN_BITS-1:0]  AWLEN,
input [`AXI_SIZE_BITS-1:0] AWSIZE,
input [1:0]                AWBURST,
input                      AWVALID,
output logic AWREADY,
//WRITE DATA
input [`AXI_DATA_BITS-1:0] WDATA,
input [`AXI_STRB_BITS-1:0] WSTRB,
input                      WLAST,
input                      WVALID,
output logic WREADY,
//WRITE RESPONSE
output logic [`AXI_IDS_BITS-1:0] BID,
output logic [1:0]               BRESP,
output logic                     BVALID,
input BREADY
);

logic       WEB;

////////////////
logic [1:0] ARLEN_counter;
logic [3:0] ARLEN_reg;
logic AR_transfer, W_transfer, B_transfer;


assign WEB = (WSTRB == 4'b0)? 1'b0 : 1'b1;
assign cpu_interrupt = sctrl_interrupt;

always_comb begin
    if (WVALID && WREADY) //write
        sctrl_addr = AWADDR[7:2];
    else //read
        sctrl_addr = (ARBURST == 2'd0)? ARADDR[7:2] : {ARADDR[7:4], ARLEN_counter};
end

always_ff @ (posedge clk or posedge rst) begin 
    if (rst) sctrl_en <= 1'b0;
    else begin 
        if (AWADDR == 32'h1000_0100 && WVALID && WREADY && !WEB)
            sctrl_en <= (WDATA == 32'b0)? 1'b0 : 1'b1;
        else
            sctrl_en <= sctrl_en;
    end
end

always_ff @ (posedge clk or posedge rst) begin 
    if (rst) sctrl_clear <= 1'b0;
    else begin
        if (AWADDR == 32'h1000_0200 && WVALID && WREADY && !WEB)
            sctrl_clear <= (WDATA == 32'b0)? 1'b0 : 1'b1;
        else
            sctrl_clear <= sctrl_clear;
    end
end

////----------- write -----------////
//assign AW_transfer = AWVALID & AWREADY;
assign W_transfer = WVALID & WREADY & WLAST;
assign B_transfer = BVALID & BREADY;

assign AWREADY = 1'b1;
assign WREADY = 1'b1;
assign BID = AWID;
assign BRESP = `AXI_RESP_OKAY;

always_ff @ (posedge clk or posedge rst) begin
	if (rst) BVALID <= 1'b0;
	else begin
		if (B_transfer) BVALID <= 1'b0;		//Need to wait W_transfer finish again.
		else if (W_transfer) BVALID <= 1'b1;
		//The write response channel depends on whether the write action is completed.
		else BVALID <= BVALID;
	end
end


////----------- read -----------////
assign AR_transfer = ARVALID & ARREADY;
//assign R_transfer = RVALID & RREADY & RLAST;

assign ARREADY = 1'b1;
assign RID = ARID;
assign RRESP = `AXI_RESP_OKAY;
assign RDATA = sctrl_out;


always_ff @(posedge clk or posedge rst) begin
	if(rst) ARLEN_reg <= 4'd0;
	else begin
		if(ARREADY && ARVALID)	ARLEN_reg <= ARLEN;
		else ARLEN_reg <= ARLEN_reg;
	end
end

always_comb begin
    if(ARBURST == 2'b0) //transfer 1 data per 1 hand shake
        RLAST = 1'b1;
    else                //transfer many data per 1 hand shake
        RLAST = (ARLEN_counter == ARLEN_reg)? 1'b1 : 1'b0;
end

always_ff @( posedge clk or posedge rst) begin
    if(rst)  
		ARLEN_counter <= 2'd3;			//If change to ARLEN_reg will wrong. So this value must with cpu wrapper send to same parameter.
    else if(ARLEN_counter == 2'd0)
		ARLEN_counter <= ARLEN_reg;
    else if(ARVALID && ARREADY)
		ARLEN_counter <= ARLEN_counter - 2'd1;
    else if(RVALID && RREADY)
		ARLEN_counter <= (RLAST)? ARLEN_reg : ARLEN_counter - 2'd1;
    else
		ARLEN_counter <= ARLEN_counter;
end

always_ff @ (posedge clk or posedge rst) begin
	if (rst) RVALID <= 1'b0;
	else 
	begin
		if (RVALID & RREADY & RLAST) RVALID <= 1'b0;			//Put RVALID down after R_transfer finish.(Need to wait AR_transfer again)
		else if (AR_transfer) RVALID <= 1'b1;
		//The read data channel depends on whether the read address action is completed.
		else RVALID <= RVALID;					//Master send VALID should keep high, until Slave return READY(handshake). 
	end
end


endmodule
