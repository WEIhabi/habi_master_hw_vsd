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
logic [31:0] DO;
logic        R_first;
logic [31:0] RDATA_Reg;


// write control
logic AW_transfer, W_transfer, B_transfer;
logic [`AXI_IDS_BITS-1:0] BID_reg;

//read control
logic AR_transfer, R_transfer;
//logic [`AXI_DATA_BITS-1:0] RDATA_reg;
logic [`AXI_IDS_BITS-1:0] RID_reg;

//Burst condition
logic ARLEN_nonzero;
logic become_zero;
logic [3:0] ARLEN_counter;
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
.DO0  (DO[0]       ),
.DO1  (DO[1]       ),
.DO2  (DO[2]       ),
.DO3  (DO[3]       ),
.DO4  (DO[4]       ),
.DO5  (DO[5]       ),
.DO6  (DO[6]       ),
.DO7  (DO[7]       ),
.DO8  (DO[8]       ),
.DO9  (DO[9]       ),
.DO10 (DO[10]      ),
.DO11 (DO[11]      ),
.DO12 (DO[12]      ),
.DO13 (DO[13]      ),
.DO14 (DO[14]      ),
.DO15 (DO[15]      ),
.DO16 (DO[16]      ),
.DO17 (DO[17]      ),
.DO18 (DO[18]      ),
.DO19 (DO[19]      ),
.DO20 (DO[20]      ),
.DO21 (DO[21]      ),
.DO22 (DO[22]      ),
.DO23 (DO[23]      ),
.DO24 (DO[24]      ),
.DO25 (DO[25]      ),
.DO26 (DO[26]      ),
.DO27 (DO[27]      ),
.DO28 (DO[28]      ),
.DO29 (DO[29]      ),
.DO30 (DO[30]      ),
.DO31 (DO[31]      ),
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
//new add
/*
always_comb begin
	if ((ARVALID || RVALID) ) A = ARADDR[15:2];            //send read address.
	else if (AWVALID || WVALID) A = AWADDR[15:2];       //send write address.
	else A = 14'b0;
end
*/
//burst new add

//logic [31:0] ARADDR_reg;

always_ff @( posedge clk or negedge rst_n ) begin
	if(!rst_n)	
		ARLEN_nonzero <= 1'b0;  
	else if(ARBURST == 2'b01)//INCR mode
	begin
		if(ARLEN_reg != 4'd0)
		begin
			ARLEN_nonzero <= 1'b1;
			//ARADDR_reg <= ARADDR + 32'd4;
		end
		else 
		begin
			ARLEN_nonzero <= 1'b0;
			//ARADDR_reg <= ARADDR;
		end 
	end
	else
	begin
		ARLEN_nonzero <= 1'b0;  	
		//ARADDR_reg <= ARADDR;
	end
end



always_comb begin
	if ((ARVALID || RVALID) && ARLEN_nonzero)          //send read address.
		A = ARADDR[15:2] + 14'd1;
	else if(ARVALID || RVALID) 
		A = ARADDR[15:2];  
	else if (AWVALID || WVALID) 
		A = AWADDR[15:2];       //send write address.
	else A = 14'b0;
end

////



assign WEB = (WVALID && WREADY)? WSTRB : 4'b1111;

////----------- write -----------////
assign BRESP = `AXI_RESP_OKAY;		//think default slave RESP=DECERR?
//////////////
assign AW_transfer = AWVALID & AWREADY;
assign W_transfer = WVALID & WREADY & WLAST;
assign B_transfer = BVALID & BREADY;

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) AWREADY <= 1'b0;
	else begin
		if (AW_transfer) AWREADY <= 1'b0;	//Put AWREADY down after AW_transfer.
        else if (AWVALID) AWREADY <= 1'b1;	//Put AWREADY high when AWVALID=1 come.
		else AWREADY <= 1'b0;
	end
end

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) WREADY <= 1'b0;
	else begin
		if (W_transfer) WREADY <= 1'b0;		//Put WREADY down after W_transfer.
		else if (WVALID) WREADY <= 1'b1;	//Put WREADY high when WVALID=1 come.
		else WREADY <= 1'b0;
	end
end

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

//store AWID when AW_transfer and give it to BID
always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) BID_reg <= `AXI_IDS_BITS'b0;//8bit
    else begin
        if (AW_transfer) BID_reg <= AWID;
        else BID_reg <= BID_reg;
    end
end

assign BID = BID_reg;

////----------- read -----------////

assign RRESP = `AXI_RESP_OKAY;		//think default slave RESP=DECERR?
assign RDATA = (RVALID && !R_first)? DO : RDATA_Reg;




//Because VIP will send randomly address, this block only catch the first cycle address.
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) R_first <= 1'b0;
	else begin
		if (RVALID && RREADY) R_first <= 1'b0;
		else if (RVALID) R_first <= 1'b1;
		else R_first <= R_first;
	end
end

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) RDATA_Reg <= 32'b0;
	else RDATA_Reg <= (RVALID && !R_first)? DO : RDATA_Reg;
end
////////////////
assign AR_transfer = ARVALID & ARREADY;
assign R_transfer = RVALID & RREADY & RLAST;
 
//assign RLAST = 1'b1;				// if burst up to 2, this one may change!

//new add
//logic RLAST_reg;


always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) ARLEN_reg <= 4'd0;
	else 
	begin
		if(ARREADY && ARVALID)	ARLEN_reg <= ARLEN;
		else ARLEN_reg <= ARLEN_reg;
	end
end



always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) ARLEN_counter <= 4'd0;
	else if(become_zero) ARLEN_counter <= 4'd0;
	else if(ARLEN_counter != ARLEN_reg)
	begin
		if(RVALID & RREADY)//handshake
			ARLEN_counter <= ARLEN_counter + 4'd1;
		else  ARLEN_counter <= ARLEN_counter;
	end
	else if(ARLEN_counter == ARLEN_reg) ARLEN_counter <= ARLEN_counter;
	else
		ARLEN_counter <= 4'd0;
end


always_comb begin
	if(ARLEN_reg == 4'b0) 
	begin	
		become_zero = 1'b1;
		if(RVALID)	RLAST = 1'b1;
		else		RLAST = 1'b0;
	end
	else if (ARLEN_counter == ARLEN_reg) 
	begin
		if (RVALID /*& RREADY*/)
		begin
			RLAST = 1'b1;
			become_zero = 1'b1;
		end		
		else 
		begin
			RLAST = 1'b0;
			become_zero = 1'b0;
		end
	end
	else
	begin
		RLAST = 1'b0;
		become_zero = 1'b0;
	end
end


////////////////////new add to here////////////////////

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) ARREADY <= 1'b0;
	else begin
		if (AR_transfer) ARREADY <= 1'b0;		//Put ARREADY down after AR_transfer finish.
        else if (ARVALID) ARREADY <= 1'b1;		//Put AREADY high when ARVALID=1 come.
		else ARREADY <= 1'b0;
	end
end



always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) RVALID <= 1'b0;
	else 
	begin
		if (RVALID & RREADY/*R_transfer*/) RVALID <= 1'b0;			//Put RVALID down after R_transfer finish.(Need to wait AR_transfer again)
		else if (AR_transfer) RVALID <= 1'b1;
		//The read data channel depends on whether the read address action is completed.
		else RVALID <= RVALID;					//Master send VALID should keep high, until Slave return READY(handshake). 
	end
end

//store RID when AR_transfer and give it to RID
always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) RID_reg <= `AXI_IDS_BITS'b0;
    else begin
        if (AR_transfer) RID_reg <= ARID;
        else RID_reg <= RID_reg;
    end
end

assign RID = RID_reg;



endmodule
