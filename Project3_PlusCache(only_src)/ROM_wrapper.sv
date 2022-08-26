//================================================
// Auther:      WEI Sheng-Ran
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "AXI_define.svh"

module ROM_wrapper(
    input        clk,
    input        rst_n,             //ROM does not reset
    input [31:0] ROM_out,           //ROM(DO)
    output logic        ROM_read,   //ROM(CS)
    output logic        ROM_enable, //ROM(OE)
    output logic [13:0] ROM_address,//ROM(A)
    
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
    input RREADY
    );

logic [1:0] take_more_address;

//Burst condition
logic become_zero;
logic [1:0] ARLEN_counter;
logic [3:0] ARLEN_reg;



assign ROM_read = 1'b1;     //CS
assign ROM_enable = 1'b1;   //OE
//ARBURST mode:00(FIXED) 01(INCR) 10(WRAP) 11(Reserved)
assign ROM_address = (ARBURST == 2'd0)? ARADDR[15:2] :{ARADDR[15:4],ARLEN_counter};

assign RRESP = `AXI_RESP_OKAY;		
assign RDATA = ROM_out;

//No to keep this two data(no like in SRAM wrapper)
assign ARREADY = 1'b1;
assign RID = ARID;

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


always_ff @ (posedge clk or negedge rst_n) begin
	if (~rst_n) RVALID <= 1'b0;
	else begin
		if (RVALID && RREADY && RLAST)
			RVALID <= 1'b0;
		else if (ARVALID && ARREADY)
			RVALID <= 1'b1;
		else
			RVALID <= RVALID;
	end
end



endmodule
