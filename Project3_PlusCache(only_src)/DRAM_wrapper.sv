//================================================
// Auther:      WEI Sheng-Ran
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "AXI_define.svh"


module DRAM_wrapper(
input        clk,
input        rst_n,
input [31:0] DRAM_Q,
input        DRAM_valid,
output logic        DRAM_CSn,
output logic [3:0]  DRAM_WEn,
output logic        DRAM_RASn,
output logic        DRAM_CASn,
output logic [10:0] DRAM_A,
output logic [31:0] DRAM_D,
    
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


//logic [1:0]  wait_ctr;
logic [2:0]  delay;
logic [2:0]  DRAM_status;
logic        DRAM_write;
logic [10:0] row_addr;

logic [1:0] ARLEN_counter;
logic [3:0] ARLEN_reg;

//status 0: IDLE
//status 1: ACT
//status 2: READ
//status 3: WRITE
//status 4: PRE

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) DRAM_status <= 3'd0;
	else
		case (DRAM_status)
			3'd0: DRAM_status <= ((AWVALID && AWREADY) || (ARVALID && ARREADY))? 3'd1 : DRAM_status;
			3'd1: begin
				if (!DRAM_RASn) DRAM_status <= (DRAM_write)? 3'd3 : 3'd2;
				else            DRAM_status <= DRAM_status;
			end
			3'd2: begin
				if (!DRAM_CASn) begin
					if (ARBURST == 2'd0)
						DRAM_status <= 3'd4;
					else
						DRAM_status <= (ARLEN_counter == 2'd0)? 3'd4 : DRAM_status;
				end
				else
					DRAM_status <= DRAM_status;
			end
			3'd3:    DRAM_status <= (!DRAM_CASn)? 3'd4 : DRAM_status;
			default: DRAM_status <= (!DRAM_RASn)? 3'd0 : DRAM_status;
		endcase
end

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) DRAM_write <= 1'b0;
	else begin
		if (DRAM_status == 3'd0)
			DRAM_write <= (AWVALID && AWREADY)? 1'b1 : 1'b0;
		else
			DRAM_write <= DRAM_write;
	end
end

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) row_addr <= 11'b0;
	else begin
		if (DRAM_status == 3'd1 && !DRAM_RASn)
			row_addr <= (DRAM_write)? AWADDR[22:12] : ARADDR[22:12];
		else
			row_addr <= row_addr;
	end
end

/*
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) wait_ctr <= 2'd0;
	else begin
		if (DRAM_status == 3'd2) begin
			if (!DRAM_CASn)
				wait_ctr <= (wait_ctr == 2'd0)? 2'd3 : wait_ctr - 2'd1;
			else
				wait_ctr <= wait_ctr;
		end
		else
			wait_ctr <= 2'd3;
	end
end
*/


///////////////////////////////////////////////////////////////////////////
//new test(using ARLEN to change data amount)
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) ARLEN_reg <= 4'd0;
	else begin
		if(ARREADY && ARVALID)	ARLEN_reg <= ARLEN;
		else ARLEN_reg <= ARLEN_reg;
	end
end

always_ff @( posedge clk or negedge rst_n) begin
    if(!rst_n)  
		ARLEN_counter <= 2'd3;			
	else if(DRAM_status == 3'd2)begin
		if (!DRAM_CASn)
			ARLEN_counter <= (ARLEN_counter == 2'd0)? 2'd3 : ARLEN_counter - 2'd1;
		else	ARLEN_counter <= ARLEN_counter;
	end
	else ARLEN_counter <= ARLEN_reg;
end
//
///////////////////////////////////////////////////////////////////////////
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) delay <= 3'd0;
	else begin
		if (DRAM_status != 3'd0)
			delay <= (delay == 3'd4)? 3'd0 : delay + 3'd1;
		else
			delay <= 3'd0;
	end
end

always_comb begin
	if ((DRAM_status == 3'd1 || DRAM_status == 3'd4) && delay == 3'd4)
		DRAM_RASn = 1'b0;
	else
		DRAM_RASn = 1'b1;
end

always_comb begin
	if (DRAM_status == 3'd2 || DRAM_status == 3'd3)
		DRAM_CASn = (delay == 3'd4)? 1'b0 : 1'b1;
	else
		DRAM_CASn = 1'b1;
end

always_comb begin
	case (DRAM_status)
		3'd0:    DRAM_A = 11'b0;
		3'd1:    DRAM_A = (DRAM_write)? AWADDR[22:12] : ARADDR[22:12];
		3'd2:    DRAM_A = (ARBURST == 2'd0)? {1'b0, ARADDR[11:2]} : {1'b0, ARADDR[11:4], ARLEN_counter};
		3'd3:    DRAM_A = {1'b0, AWADDR[11:2]};
		default: DRAM_A = row_addr;
	endcase
end

always_comb begin
	if (WVALID && WREADY)
		DRAM_WEn = WSTRB;
	else if (DRAM_status == 3'd4 && !DRAM_RASn)
		DRAM_WEn = 4'h0;
	else
		DRAM_WEn = 4'hF;
end

assign DRAM_CSn = 1'b0;
assign DRAM_D = WDATA;

////----------- write -----------////

assign AWREADY = 1'b1;
assign WREADY = (DRAM_status == 3'd3 && delay == 3'd4)? 1'b1 : 1'b0;
assign BID = AWID;
assign BRESP = `AXI_RESP_OKAY;
assign BVALID = (DRAM_status == 3'd4 && delay == 3'd4)? 1'b1 : 1'b0;

////----------- read -----------////

assign ARREADY = 1'b1;
assign RID = ARID;
assign RDATA = DRAM_Q;
assign RRESP = `AXI_RESP_OKAY;
assign RLAST = (DRAM_status == 3'd4 && DRAM_valid)? 1'b1 : 1'b0;
assign RVALID = DRAM_valid;

endmodule
