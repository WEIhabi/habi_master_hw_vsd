//================================================
// Auther:      WEI Sheng-Ran
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "AXI_define.svh"

module SRAM_wrapper(
    //
    input clk,
    input rst_n,
	
	//WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	//WRITE DATA0
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	//WRITE RESPONSE0
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,
	
	//READ ADDRESS0
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	//READ DATA0
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY
);

//SRAM_wrapper to SRAM
logic [13:0] A;
logic [3:0]  WEB;
logic [1:0] take_more_address;


logic [31:0] DO;
logic        R_first;
//logic [31:0] RDATA_Reg;


// write control
logic AW_transfer, W_transfer, B_transfer;
logic [`AXI_IDS_BITS-1:0] BID_reg;

//read control
logic AR_transfer, R_transfer;
//logic [`AXI_DATA_BITS-1:0] RDATA_reg;
logic [`AXI_IDS_BITS-1:0] RID_reg;

//Burst condition

logic [1:0] ARLEN_counter;
logic [3:0] ARLEN_reg;


/////////////wire from SRAM/////////////

SRAM i_SRAM(
.A0   (A[0]        ),
.A1   (A[1]        ),
.A2   (A[2]        ),
.A3   (A[3]        ),
.A4   (A[4]        ),
.A5   (A[5]        ),
.A6   (A[6]        ),
.A7   (A[7]        ),
.A8   (A[8]        ),
.A9   (A[9]        ),
.A10  (A[10]       ),
.A11  (A[11]       ),
.A12  (A[12]       ),
.A13  (A[13]       ),
.DO0  (RDATA[0]    ),
.DO1  (RDATA[1]    ),
.DO2  (RDATA[2]    ),
.DO3  (RDATA[3]    ),
.DO4  (RDATA[4]    ),
.DO5  (RDATA[5]    ),
.DO6  (RDATA[6]    ),
.DO7  (RDATA[7]    ),
.DO8  (RDATA[8]    ),
.DO9  (RDATA[9]    ),
.DO10 (RDATA[10]   ),
.DO11 (RDATA[11]   ),
.DO12 (RDATA[12]   ),
.DO13 (RDATA[13]   ),
.DO14 (RDATA[14]   ),
.DO15 (RDATA[15]   ),
.DO16 (RDATA[16]   ),
.DO17 (RDATA[17]   ),
.DO18 (RDATA[18]   ),
.DO19 (RDATA[19]   ),
.DO20 (RDATA[20]   ),
.DO21 (RDATA[21]   ),
.DO22 (RDATA[22]   ),
.DO23 (RDATA[23]   ),
.DO24 (RDATA[24]   ),
.DO25 (RDATA[25]   ),
.DO26 (RDATA[26]   ),
.DO27 (RDATA[27]   ),
.DO28 (RDATA[28]   ),
.DO29 (RDATA[29]   ),
.DO30 (RDATA[30]   ),
.DO31 (RDATA[31]   ),
.DI0  (WDATA[0]    ),
.DI1  (WDATA[1]    ),
.DI2  (WDATA[2]    ),
.DI3  (WDATA[3]    ),
.DI4  (WDATA[4]    ),
.DI5  (WDATA[5]    ),
.DI6  (WDATA[6]    ),
.DI7  (WDATA[7]    ),
.DI8  (WDATA[8]    ),
.DI9  (WDATA[9]    ),
.DI10 (WDATA[10]   ),
.DI11 (WDATA[11]   ),
.DI12 (WDATA[12]   ),
.DI13 (WDATA[13]   ),
.DI14 (WDATA[14]   ),
.DI15 (WDATA[15]   ),
.DI16 (WDATA[16]   ),
.DI17 (WDATA[17]   ),
.DI18 (WDATA[18]   ),
.DI19 (WDATA[19]   ),
.DI20 (WDATA[20]   ),
.DI21 (WDATA[21]   ),
.DI22 (WDATA[22]   ),
.DI23 (WDATA[23]   ),
.DI24 (WDATA[24]   ),
.DI25 (WDATA[25]   ),
.DI26 (WDATA[26]   ),
.DI27 (WDATA[27]   ),
.DI28 (WDATA[28]   ),
.DI29 (WDATA[29]   ),
.DI30 (WDATA[30]   ),
.DI31 (WDATA[31]   ),
.CK   (clk         ),
.WEB0 (WEB[0]      ),
.WEB1 (WEB[1]      ),
.WEB2 (WEB[2]      ),
.WEB3 (WEB[3]      ),
.OE   (1'b1        ),
.CS   (1'b1        )
);



always_comb begin
	if (WVALID && WREADY) //write 
		A = AWADDR[15:2];
	else //read 
		A = (ARBURST == 2'd0)? ARADDR[15:2] : {ARADDR[15:4], ARLEN_counter};
end

assign WEB = (WVALID && WREADY)? WSTRB : 4'b1111;

////------------------------------------- write -------------------------------------////

assign BRESP = `AXI_RESP_OKAY;		//think default slave RESP=DECERR?
assign AWREADY = 1'b1;
assign WREADY = 1'b1;
assign BID = AWID;

/*	//HW3 don't need, but why? 
// I guess this homework doesn't need to verify cpu wrapper/sram wrapper.
// Only to verify bridge.
*/

assign AW_transfer = AWVALID & AWREADY;
assign W_transfer = WVALID & WREADY & WLAST;
assign B_transfer = BVALID & BREADY;


//B is SRAM send(Master), CPU receive(Slave).
//Actions similar to the above can be seen in CPU_wrapper, because Opposite direction.
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) BVALID <= 1'b0;
	else begin
		if (B_transfer) BVALID <= 1'b0;		//Need to wait W_transfer finish again.
		else if (W_transfer) BVALID <= 1'b1;
		//The write response channel depends on whether the write action is completed.
		else BVALID <= BVALID;
	end
end



////------------------------------------- read -------------------------------------////

assign ARREADY = 1'b1;
assign RRESP = `AXI_RESP_OKAY;		
assign RID = ARID;


assign AR_transfer = ARVALID & ARREADY;
assign R_transfer = RVALID & RREADY & RLAST;
 


//new test

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) ARLEN_reg <= 4'd0;
	else begin
		if(ARREADY && ARVALID)	ARLEN_reg <= ARLEN;
		else ARLEN_reg <= ARLEN_reg;
	end
end

always_comb begin
    if(ARBURST == 2'b0) 
        RLAST = 1'b1;
    else                
        RLAST = (ARLEN_counter == ARLEN_reg)? 1'b1 : 1'b0;
end

always_ff @( posedge clk or negedge rst_n) begin
    if(!rst_n)  
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
//

///////////////////////////////////////////////////////////////////////////
/*
always_comb begin
    if(ARBURST == 2'b0) 
        RLAST = 1'b1;
    else                
        RLAST = (take_more_address == 2'd3)? 1'b1 : 1'b0;
end

always_ff @( posedge clk or negedge rst_n) begin
    if(!rst_n)  
        take_more_address <= 2'd3;
    else if(take_more_address == 2'd0)
        take_more_address <= 2'd3;
    else if(ARVALID && ARREADY)
        take_more_address <= take_more_address - 2'd1;
    else if(RVALID && RREADY)
        take_more_address <= (RLAST)? 2'd3 : take_more_address- 2'd1;
    else
        take_more_address <= take_more_address;
end
*/
///////////////////////////////////////////////////////////////////////////
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) RVALID <= 1'b0;
	else 
	begin
		if (RVALID & RREADY & RLAST) RVALID <= 1'b0;			//Put RVALID down after R_transfer finish.(Need to wait AR_transfer again)
		else if (AR_transfer) RVALID <= 1'b1;
		//The read data channel depends on whether the read address action is completed.
		else RVALID <= RVALID;					//Master send VALID should keep high, until Slave return READY(handshake). 
	end
end



endmodule
