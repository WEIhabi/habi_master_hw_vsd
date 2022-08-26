`include "AXI_define.svh"
`include "cpu.sv"

module CPU_wrapper(
    
    input clk,
    input rst_n,
    
    //WRITE ADDRESS
    output logic [`AXI_ID_BITS-1:0] AWID_M1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    output logic [1:0] AWBURST_M1,
    output logic AWVALID_M1,
    input AWREADY_M1,

    //WRITE DATA
    output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    output logic WLAST_M1,
    output logic WVALID_M1,
    input WREADY_M1,

    //WRITE RESPONSE
    input [`AXI_ID_BITS-1:0] BID_M1,
    input [1:0] BRESP_M1,
    input BVALID_M1,
    output logic BREADY_M1,

    //READ ADDRESS0
    output logic [`AXI_ID_BITS-1:0] ARID_M0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    output logic [1:0] ARBURST_M0,
    output logic ARVALID_M0,
    input ARREADY_M0,
    
    //READ DATA0
    input [`AXI_ID_BITS-1:0] RID_M0,
    input [`AXI_DATA_BITS-1:0] RDATA_M0,
    input [1:0] RRESP_M0,
    input RLAST_M0,
    input RVALID_M0,
    output logic RREADY_M0,
    
    //READ ADDRESS1
    output logic [`AXI_ID_BITS-1:0] ARID_M1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    output logic [1:0] ARBURST_M1,
    output logic ARVALID_M1,
    input ARREADY_M1,
    
    //READ DATA1
    input [`AXI_ID_BITS-1:0] RID_M1,
    input [`AXI_DATA_BITS-1:0] RDATA_M1,
    input [1:0] RRESP_M1,
    input RLAST_M1,
    input RVALID_M1,
    output logic RREADY_M1
);


logic [6:0]     opcode_M1;
logic [2:0]     funct3_M1;
logic [31:0]    PC_IF;
logic [31:0]    IM_out, IM_out_reg;
logic [31:0]    DM_out;
logic [1:0]     Read_Or_Write_M1;
logic [3:0]     stall_state;
logic           stall;
logic           AR_first;
logic [31:0]    ARADDR_M0_Reg;
logic [31:0] DM_data_in;

/////////////control M0, M1 status/////////////

//Read_Or_Write_M1  0:none, 1:read  2:write
always_comb begin
	case (opcode_M1)
		`OP_LOAD:  Read_Or_Write_M1 = 2'd1;
		`OP_STORE: Read_Or_Write_M1 = 2'd2;
		default:   Read_Or_Write_M1 = 2'd0;
	endcase
end

//status 0: IDLE
//status 1: M0 AR | M1 --
//status 2: M0 R  | M1 --     -> M0 read M1 none
//-------------------------//
//status 1: M0 AR | M1 AW
//status 2: M0 R  | M1 W
//status 3: M0 -- | M1 B      -> M0 read M1 write
//-------------------------//
//status 1: M0 AR | M1 --
//status 2: M0 R  | M1 --
//status 3: M0 -- | M1 AR
//status 4: M0 -- | M1 R      -> M0 read M1 read

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) stall_state <= 4'd0;
    else
    begin
        case(stall_state)
            4'd1:
            begin
                if(Read_Or_Write_M1 == 2'd2)//M1 store, need write 
                begin
                    //M0 is read address, M1 write address
                    if(ARVALID_M0 && ARREADY_M0 && AWVALID_M1 && AWREADY_M1) stall_state <= 4'd2;
                    else if(ARVALID_M0 && ARREADY_M0)   stall_state <= 4'd5;//M0 is read address
                    else if(AWVALID_M1 && AWREADY_M1)   stall_state <= 4'd6;//M1 is write address
                    else    stall_state <= 4'd1;
                end
                else 
                begin
                    if(ARVALID_M0 && ARREADY_M0)
                        stall_state <= 4'd2;
                    else
                        stall_state <= 4'd1;
                end
            end
            4'd2:
            begin
                case(Read_Or_Write_M1)
                    2'd1:
                    begin
                        if(RVALID_M0 && RREADY_M0)
                        begin
                            stall_state <= 4'd3;
                        end
                        else stall_state <= 4'd2;
                    end
                    2'd2:
                    begin
                        if(RVALID_M0 && RREADY_M0 && WVALID_M1 && WREADY_M1)
                            stall_state <= 4'd3;
                        else if(RVALID_M0 && RREADY_M0)
                            stall_state <= 4'd7;//M0 Read data finish
                        else if(WVALID_M1 && WREADY_M1)
                            stall_state <= 4'd8;//M1 write data finish
                        else
                            stall_state <= 4'd2;
                    end
                    default:
                    begin
                        if(RVALID_M0 && RREADY_M0)//M0 IDLE finish.(M1 is have not instruction now)
                            stall_state <= 4'd1;
                        else 
                            stall_state <= 4'd2;
                    end
                endcase
            end
            4'd3:
            begin
                if(Read_Or_Write_M1 == 2'd2)
                begin
                    if(BVALID_M1 && BREADY_M1)
                        stall_state <= 4'd1;
                    else
                        stall_state <= 4'd3;
                end
                else
                begin
                    if(ARVALID_M1 && ARREADY_M1)
                        stall_state <= 4'd4;
                    else
                        stall_state <= 4'd3;
                end
            end
            4'd4:
            begin
                if(RVALID_M1 && RREADY_M1)
                    stall_state <= 4'd1;
                else
                    stall_state <= 4'd4;
            end
            4'd5:
            begin
                if(AWVALID_M1 && AWREADY_M1)
                    stall_state <= 4'd2;
                else
                    stall_state <= 4'd5;
            end
            4'd6:
            begin
                if(ARVALID_M0 && ARREADY_M0)
                    stall_state <= 4'd2;
                else
                    stall_state <= 4'd6;
            end
            4'd7:
            begin
                if(WVALID_M1 && WREADY_M1)
                    stall_state <= 4'd3;
                else
                    stall_state <= 4'd7;
            end
            4'd8:
            begin
                if(RVALID_M0 && RREADY_M0)
                    stall_state <= 4'd3;
                else
                    stall_state <= 4'd8;
            end
            default:
                stall_state <= 4'd1;
        endcase
    end
end

//give cpu stall
always_comb begin
    case(stall_state)
        4'd1:stall = 1'b1;
        4'd2:
        begin
            if(Read_Or_Write_M1 == 2'd0)
            begin
                if(RVALID_M0 && RREADY_M0 && RRESP_M0 == 2'h0)
                    stall = 1'b0;
                else
                    stall = 1'b1;
            end
            else    stall = 1'b1;
        end
        4'd3:
        begin
            if(Read_Or_Write_M1 == 2'd2)
            begin
                if(BVALID_M1 && BREADY_M1 && BRESP_M1 == 2'h0)
                    stall = 1'b0;
                else
                    stall = 1'b1;
            end
            else    stall = 1'b1;
        end
        4'd4:
        begin
            if(RVALID_M1 && RREADY_M1 && RRESP_M1 == 2'h0)
            begin
                stall = 1'b0;
            end
            else stall = 1'b1;
        end
        default:stall = 1'b1;
    endcase
end




cpu cpu(
    .clk(clk),
    .rst(!rst_n),  
    .IM_address(PC_IF),         //32bit send to SRAM_wrapper decode
    .IM_Instruction(IM_out),    //cpu module input
    .ALU_result_MEM(AWADDR_M1), //32bit send to SRAM_wrapper decode
    .DM_input(DM_data_in),        //cpu module output
    .DM_data(DM_out),           //cpu module input
    .opcode_MEM(opcode_M1),     //cpu module output
    .funct3_MEM(funct3_M1),     //cpu module output
    .stall(stall)               //cpu module input
);


//Because VIP will send randomly address, this block only catch the first cycle address.
always_ff @( posedge clk or negedge rst_n) begin
    if(!rst_n)
        AR_first <= 1'b0;
    else
    begin
        if(RVALID_M0 && RREADY_M0)
            AR_first <= 1'b0;
        else if(ARVALID_M0)
            AR_first <= 1'b1;
        else
            AR_first <= AR_first;
    end
end

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) ARADDR_M0_Reg <= 32'b0;
    else ARADDR_M0_Reg <= (stall_state == 4'd1 && ARVALID_M0 && !AR_first)? PC_IF : ARADDR_M0_Reg;
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        IM_out_reg <= 32'b0;
    else 
    begin
        if(RVALID_M0 && RREADY_M0)
            IM_out_reg <= RDATA_M0;
        else
            IM_out_reg <= IM_out_reg;
    end
end

assign IM_out = (RVALID_M0 && RREADY_M0)? RDATA_M0 : IM_out_reg;
assign DM_out = (RVALID_M1 && RREADY_M1)? RDATA_M1 : 32'b0;


/////////////M0 control/////////////

////-----------No write -----------////

////----------- read -----------////
assign ARID_M0    =  `AXI_ID_BITS'b0;
assign ARADDR_M0  =  (stall_state == 4'd1 && ARVALID_M0 && !AR_first)? PC_IF : ARADDR_M0_Reg;
assign ARLEN_M0   =  `AXI_LEN_BITS'b0;//Burst up to 2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
assign ARSIZE_M0  =  `AXI_SIZE_BITS'b0;
assign ARBURST_M0 =  2'd1;//INCR mode
assign ARVALID_M0 =  (stall_state == 4'd1 || stall_state == 4'd6)? 1'b1 : 1'b0;

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) 
        RREADY_M0 <= 1'b0;
	else begin
		if (RVALID_M0 && RREADY_M0)//when transaction end, RREADY set 0.
            RREADY_M0 <= 1'b0;
		else if (RVALID_M0) 
            RREADY_M0 <= 1'b1;//handshake
		else 
            RREADY_M0 <= 1'b0;
	end
end

/////////////M1 control/////////////

////----------- write -----------////

assign AWID_M1 = `AXI_ID_BITS'b0; //no use in this work
assign AWLEN_M1 = `AXI_LEN_BITS'b0;//Burst up to 2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
assign AWSIZE_M1 = `AXI_SIZE_BITS'b0;
assign AWBURST_M1 = 2'd1;//INCR
assign WLAST_M1 = 1'b1;
assign AWVALID_M1 = ((stall_state == 4'd1 || stall_state == 4'd5) && Read_Or_Write_M1 == 2'd2)? 1'b1 : 1'b0;
assign WVALID_M1 = ((stall_state == 4'd2 || stall_state == 4'd7) && Read_Or_Write_M1 == 2'd2)? 1'b1 : 1'b0;
//check have error?
always_comb begin
    if (opcode_M1 == `OP_STORE)
        case (funct3_M1)
            3'b000:
                case (AWADDR_M1[1:0])
                    2'b00:   
                    begin
                        WSTRB_M1 = 4'b1110;
                        WDATA_M1 = {24'd0, DM_data_in[7:0]}; 
                    end
                    2'b01:   
                    begin
                        WSTRB_M1 = 4'b1101;
                        WDATA_M1 = {16'd0, DM_data_in[7:0],8'd0}; 
                    end 
                    2'b10:
                    begin
                        WSTRB_M1 = 4'b1011;
                        WDATA_M1 = {8'd0, DM_data_in[7:0],16'd0}; 
                    end   
                    default:
                    begin
                        WSTRB_M1 = 4'b0111;
                        WDATA_M1 = {DM_data_in[7:0],24'd0};
                    end 
                endcase
            3'b001:
                //WSTRB_M1 = (AWADDR_M1[1:0] == 2'b00)? 4'b1100 : 4'b0011;
                case (AWADDR_M1[1:0])
                    2'b00:
                    begin
                        WSTRB_M1 = 4'b1100;
                        WDATA_M1 = {16'd0,DM_data_in[15:0]};
                    end
                    2'b10:
                    begin
                        WSTRB_M1 = 4'b0011;
                        WDATA_M1 = {DM_data_in[15:0],16'd0};
                    end
			 default:
			 begin
				WSTRB_M1 = 4'b1111;
                        WDATA_M1 = 32'd0;
			 end
                endcase
            3'b010:
            begin
                WSTRB_M1 = 4'b0000;
                WDATA_M1 = DM_data_in;
            end
            default:
            begin
                WSTRB_M1 = 4'b1111;
                WDATA_M1 = 32'b0;
            end        
        endcase
    else
    begin
        WSTRB_M1 = 4'b1111;
        WDATA_M1 = 32'b0;
    end
end

//Corresponding to SRAM_wrapper
always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) 
        BREADY_M1 <= 1'b0;
	else begin
		if (BVALID_M1 && BREADY_M1) //BVALID is MEM send(Master), BREADY is CPU send(Slave).
            BREADY_M1 <= 1'b0;      //Put BREADY down after B_transfer(BVALID_M1 && BREADY_M1).
		else if (BVALID_M1) 
            BREADY_M1 <= 1'b1;      //Put BREADY high when BVALID=1 come.
		else 
            BREADY_M1 <= 1'b0;
	end
end

////----------- read -----------////

assign ARID_M1 = `AXI_ID_BITS'b0; //no use in this work
assign ARADDR_M1 = AWADDR_M1;
assign ARLEN_M1 = `AXI_LEN_BITS'b0;
assign ARSIZE_M1 = `AXI_SIZE_BITS'b0;
assign ARBURST_M1 = 2'd1;
assign ARVALID_M1 = (stall_state == 4'd3 && Read_Or_Write_M1 == 2'd1)? 1'b1 : 1'b0;

always_ff @ (posedge clk or negedge rst_n) begin
	if (!rst_n) RREADY_M1 <= 1'b0;
	else begin
		if (RVALID_M1 && RREADY_M1) //RVALID is MEM send(Master), RREADY is CPU send(Slave).
            RREADY_M1 <= 1'b0;      //Put RREADY down after R_transfer(RVALID_M1 && RREADY_M1).
		else if (RVALID_M1) 
            RREADY_M1 <= 1'b1;      //Put RREADY high when RVALID=1 come.
		else 
            RREADY_M1 <= 1'b0;
	end
end

endmodule
