//================================================
// Auther:      WEI Sheng-Ran
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "AXI_define.svh"
`include "IDInstDef.svh"
`include "def.svh"
`include "cpu.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"

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
    output logic RREADY_M1,

    input interrupt
);

logic [3:0]     system_state;   //bus_state
logic           stall;
logic [6:0]     opcode_M1;
logic [2:0]     funct3_M1;

// HW3 new add
logic [31:0]    I_core_addr, D_core_addr;     //IM/DM address.
logic [31:0]    I_core_out, D_core_out;             //IM/DM data.
logic [31:0]    D_core_in;                          //DM ready to write data.

logic [2:0]     D_core_type;                        //Collocation with S-type funct3(byte Hword word).
logic           D_core_write;                       //cache input(when opcode_M1 = S_type).
logic           I_core_req, D_core_req;             //CPU(core) send to I_cache/D_cache core_req.
logic           I_wait, D_wait;                     //cache receive from cpu wrapper(depend on bus stall).
logic           I_core_wait, D_core_wait;           //cache input receive, and to call (core_wait) for cpu stall.
logic           I_req, I_req_reg, D_req, D_req_reg; //cache output to call bus say, I need data from mem please(miss).
logic           I_write, D_write;                   //cache output to call bus say, I can enable you(mem) to write data to me(cache).
logic [31:0]    I_in;                               //empty connect(IM can't write data).
logic [2:0]     I_type, D_type;                     //cache output to bus say I want to write type is what. 
logic [31:0]    I_core_out_reg;
//

logic AR_handshake_M0, AR_handshake_M1;
logic R_handshake_M0,  R_handshake_M1;
logic AW_handshake_M1;
logic W_handshake_M1;
logic B_handshake_M1;

//AR
assign AR_handshake_M0 = ARVALID_M0 && ARREADY_M0;
assign AR_handshake_M1 = ARVALID_M1 && ARREADY_M1;
//R
assign R_handshake_M0 = RVALID_M0 && RREADY_M0;
assign R_handshake_M1 = RVALID_M1 && RREADY_M1;
//AW
assign AW_handshake_M1 = AWVALID_M1 && AWREADY_M1;
//W
assign W_handshake_M1 = WVALID_M1 && WREADY_M1;
//B
assign B_handshake_M1 = BVALID_M1 && BREADY_M1;

/////////////control M0, M1 status/////////////

//status 0: IDLE
//status 1: M0 AR | M1 --
//status 2: M0 R  | M1 --     -> M0 read(miss) M1 none or read(hit)
//-------------------------//
//status 1: M0 -- | M1 AW
//status 2: M0 -- | M1 W
//status 3: M0 -- | M1 B      -> M0 read(hit) M1 write
//-------------------------//
//status 1: M0 AR | M1 AW
//status 2: M0 R  | M1 W
//status 3: M0 -- | M1 B      -> M0 read(miss) M1 write
//-------------------------//
//status 1: M0 -- | M1 AR
//status 2: M0 -- | M1 R      -> M0 read(hit) M1 read(miss)
//-------------------------//
//status 1: M0 AR | M1 --
//status 2: M0 R  | M1 --
//status 3: M0 -- | M1 AR
//status 4: M0 -- | M1 R      -> M0 read(miss) M1 read(miss)

always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) system_state <= 4'd0;
    else
        case (system_state)
        	4'd0: system_state <= (I_req || D_req)? 4'd1 : 4'd0;
            4'd1:
            	case ({I_req_reg, D_req_reg})
            		2'b10: system_state <= (AR_handshake_M0)? 4'd2 : 4'd1;
            		2'b01: begin
            			if (D_write) system_state <= (AW_handshake_M1)? 4'd2 : 4'd1;
            			else         system_state <= (AR_handshake_M1)? 4'd2 : 4'd1;
            		end
            		2'b11: begin
            			if (D_write) begin
            				if (AR_handshake_M0 && AW_handshake_M1) system_state <= 4'd2;
            				else if (AR_handshake_M0)                        system_state <= 4'd5;
            				else if (AW_handshake_M1)                        system_state <= 4'd6;
            				else                                                      system_state <= 4'd1;
            			end
            			else system_state <= (AR_handshake_M0)? 4'd2 : 4'd1;
            		end
            		default: system_state <= 4'd0;
            	endcase
            4'd2:
            	case ({I_req_reg, D_req_reg})
            		2'b10: system_state <= (R_handshake_M0 && RLAST_M0)? 4'd0 : 4'd2;
            		2'b01: begin
            			if (D_write) system_state <= (W_handshake_M1)? 4'd3 : 4'd2;
            			else         system_state <= (R_handshake_M1 && RLAST_M1)? 4'd0 : 4'd2;
            		end
            		2'b11: begin
            			if (D_write) begin
            				if (R_handshake_M0 && RLAST_M0 && W_handshake_M1) system_state <= 4'd3;
            				else if (R_handshake_M0 && RLAST_M0)                      system_state <= 4'd7;
            				else if (W_handshake_M1)                                  system_state <= 4'd8;
                            else                                                              system_state <= 4'd2;
                        end
            			else system_state <= (R_handshake_M0 && RLAST_M0)? 4'd3 : 4'd2;
            		end
            		default: system_state <= 4'd0;
            	endcase
            4'd3:
                case ({I_req_reg, D_req_reg})
                    2'b01: system_state <= (B_handshake_M1)? 4'd0 : 4'd3;
                    2'b11: begin
                        if (D_write) system_state <= (B_handshake_M1)? 4'd0 : 4'd3;
                        else         system_state <= (AR_handshake_M1)? 4'd4 : 4'd3;
                    end
                    default: system_state <= 4'd0;
                endcase
            4'd4:    system_state <= (R_handshake_M1 && RLAST_M1)? 4'd0 : 4'd4;
			4'd5:    system_state <= (AW_handshake_M1)? 4'd2 : 4'd5; //wait for M1 AW
			4'd6:    system_state <= (AR_handshake_M0)? 4'd2 : 4'd6; //wait for M0 AR
			4'd7:    system_state <= (W_handshake_M1)? 4'd3 : 4'd7; //wait for M1 W
			4'd8:    system_state <= (R_handshake_M0 && RLAST_M0)? 4'd3 : 4'd8; //wait for M0 R
            default: system_state <= 4'd0;
        endcase
end




cpu cpu(
    .clk(clk),
    .rst(!rst_n),  
    //HW3 revise
    .IM_address(I_core_addr),    //32bit send to SRAM_wrapper decode
    .IM_out(I_core_out),    //cpu module input
    .ALU_result_MEM(D_core_addr),//32bit send to SRAM_wrapper decode
    .DM_input(D_core_in),           //cpu module output
    .DM_data(D_core_out),           //cpu module input
    //
    .opcode_MEM(opcode_M1),     //cpu module output
    .funct3_MEM(funct3_M1),     //cpu module output
    .stall(stall),               //cpu module input
    .interrupt(interrupt)
);

always_comb begin
    case({I_req, D_req})
        //{I_req, D_req} = 2'b00 is  IDLE state, because I_req D_req need one cycle to determine the value,
        //so in IDLE state need to pull the signal determine again.
        2'b00:      stall = (D_core_req)? D_core_wait | I_core_wait : I_core_wait;
        2'b10:      stall = I_core_wait;
        default:    stall = D_core_wait;//D_core_out is the last will keep the value.
                                       //(because I_core_out will when read state finish pull down to 0)
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) I_core_out_reg <= 32'b0;
    else       I_core_out_reg <= (RVALID_M0 && RREADY_M0 && RLAST_M0)? I_core_out : I_core_out_reg;
               //Change the reg value when the last data in(because I-cache must to once read four data).
end
//D-cache must to once write one data, but this data will duplicate four times,
// store in D-cache(because this is not afraid offset to write wrong value) 





/////////////-----------------wire of L1CI-----------------/////////////

L1C_inst L1CI(
.clk(clk),
.rst(!rst_n),
.core_addr(I_core_addr),//serach I-cache have correct data? if no send to bus to IM to get.
.core_req(I_core_req),  //cpu send req to ask I-cache
.core_write(1'b0),
.core_in(32'b0),
.core_type(`CACHE_WORD),
.I_out(RDATA_M0),//IM data transfer from bus to I-cache
.I_wait(I_wait),      //bus send to cpu wrapper then send to I-cache says wait.
.core_out(I_core_out),//IM don't write
.core_wait(I_core_wait),//output to core(cpu)
.I_req(I_req),
//if instuction is in cache and hit, I_req is 0 (mean's don't send to bus to get IM data).
//if I_req is 1 (have to bus to get IM data).
.I_addr(ARADDR_M0),
.I_write(I_write),//IM don't write
.I_in(I_in),      //IM don't write
.I_type(I_type)   //IM don't write
);

always_ff @ (posedge clk or negedge rst_n) begin
    if (~rst_n) I_req_reg <= 1'b0;
    else        I_req_reg <= (system_state == 4'd0)? I_req : I_req_reg;
end

always_comb begin
	case (system_state)
		4'd0:             I_core_req = 1'b1;
		4'd1, 4'd2, 4'd8: I_core_req = (I_req_reg)? 1'b1 : 1'b0;
		default:          I_core_req = 1'b0;
	endcase
end

always_comb begin
	if (I_req_reg && (system_state == 4'd2 || system_state == 4'd8))
        I_wait = (RVALID_M0 && RREADY_M0)? 1'b0 : 1'b1;
    else
		I_wait = 1'b1;
end




/////////////-----------------wire of L1CD-----------------/////////////

L1C_data L1CD(
.clk(clk),
.rst(~rst_n),
.core_addr(D_core_addr),
.core_req(D_core_req),
.core_write(D_core_write),
.core_in(D_core_in),
.core_type(D_core_type),
.D_out(RDATA_M1),
.D_wait(D_wait),
.core_out(D_core_out),
.core_wait(D_core_wait),
.D_req(D_req),
.D_addr(ARADDR_M1),
.D_write(D_write),
.D_in(WDATA_M1),
.D_type(D_type)
);

always_ff @ (posedge clk or negedge rst_n) begin
    if (~rst_n) D_req_reg <= 1'b0;
    else        D_req_reg <= (system_state == 4'd0)? D_req : D_req_reg;
end

always_comb begin
    if(system_state ==  4'd0) 
        D_core_req = ((opcode_M1 == `OP_STORE) || (opcode_M1 == `OP_LOAD))? 1'b1 : 1'b0;
    else
        D_core_req = (D_req_reg)?  1'b1 : 1'b0;
        //When system_state !=  4'd0, D_core_req look D_req_reg to keep value 
end

always_comb begin
	if (opcode_M1 == `OP_STORE)
		case (funct3_M1)
			3'b000:  D_core_type = `CACHE_BYTE;
			3'b001:  D_core_type = `CACHE_HWORD;
			3'b010:  D_core_type = `CACHE_WORD;
			default: D_core_type = 3'b0;
		endcase
	else D_core_type = 3'b0;
end


always_comb begin
    if(D_req)begin
        if(D_write)begin
            if(system_state == 4'd3)
                D_wait = (BVALID_M1 && BREADY_M1)? 1'b0 : 1'b1;
            else
                D_wait = 1'b1;
        end
        else if(I_req)begin
            if(system_state == 4'd4)//M0 read(miss) M1 read(miss)
                D_wait = (RVALID_M1 && RREADY_M1)? 1'b0 : 1'b1;
            else
                D_wait = 1'b1;
        end
        else begin
            if(system_state == 4'd2)// M0 read(hit) M1 read(miss)
                D_wait = (RVALID_M1 && RREADY_M1)? 1'b0 : 1'b1;
            else
                D_wait = 1'b1;
        end
    end
    else        D_wait = 1'b1;
end

assign D_core_write = (opcode_M1 == `OP_STORE)? 1'b1 : 1'b0;




/////////////-----------------M0 control-----------------/////////////

////-----------No write -----------////

////----------- read -----------////
assign ARID_M0    =  `AXI_ID_BITS'b0;
assign ARLEN_M0   =  4'd3; //Burst up to 4
assign ARSIZE_M0  =  `AXI_SIZE_BITS'b0;
assign ARBURST_M0 =  2'd1;//INCR mode
assign ARVALID_M0 =  (I_req && (system_state == 4'd1 || system_state == 4'd6))? 1'b1 : 1'b0;
assign RREADY_M0  = 1'b1;


/////////////-----------------M1 control-----------------/////////////

////----------- write -----------////

assign AWID_M1 = `AXI_ID_BITS'b0; //no use in this work
assign AWADDR_M1 = ARADDR_M1;
assign AWLEN_M1 = `AXI_LEN_BITS'b0;
// D-cache must to once write one data, but this data will duplicate four times,
// store in D-cache(because this is not afraid offset to write wrong value) 

assign AWSIZE_M1 = `AXI_SIZE_BITS'b0;
assign AWBURST_M1 = (ARADDR_M0[31:10] == 22'b0001_0000_0000_0000_0000_00)? 2'd0 : 2'd1;
assign WLAST_M1 = 1'b1;
assign AWVALID_M1 = (D_req && D_write &&(system_state == 4'd1 || system_state == 4'd5) )? 1'b1 : 1'b0;
assign WVALID_M1 = (D_req && D_write &&(system_state == 4'd2 || system_state == 4'd7) )? 1'b1 : 1'b0;
assign BREADY_M1 = (system_state == 4'd8)? 1'b0 : 1'b1;//wait M0 to read correct value.(now M0 is miss)

always_comb begin
    case (D_type)
        //WDATA_M1 move to MEM stage do.
        `CACHE_BYTE:
        begin
            case (ARADDR_M1[1:0])
                2'b00:  WSTRB_M1 = 4'b1110;
                2'b01:  WSTRB_M1 = 4'b1101;
                2'b10:  WSTRB_M1 = 4'b1011;
                default:WSTRB_M1 = 4'b0111;
            endcase
        end
        `CACHE_HWORD:
        begin
            case (ARADDR_M1[1:0])
                2'b00:  WSTRB_M1 = 4'b1100;
                2'b10:  WSTRB_M1 = 4'b0011;
			    default:WSTRB_M1 = 4'b1111;
            endcase
        end
        `CACHE_WORD:    WSTRB_M1 = 4'b0000;
        default:        WSTRB_M1 = 4'b1111;
    endcase
end


////----------- read -----------////

assign ARID_M1    = `AXI_ID_BITS'b0; //no use in this work
assign ARLEN_M1   = 4'd3; //Burst up to 4
assign ARSIZE_M1  = `AXI_SIZE_BITS'b0;
assign ARBURST_M1 = (ARADDR_M1[31:10] == 22'b0001_0000_0000_0000_0000_00)? 2'd0 : 2'd1;
assign RREADY_M1 = 1'b1;

always_comb begin
    if (D_req) begin
        if (I_req_reg) ARVALID_M1 = (!D_write && system_state == 4'd3)? 1'b1 : 1'b0;
        else           ARVALID_M1 = (!D_write && system_state == 4'd1)? 1'b1 : 1'b0;
    end
    else ARVALID_M1 = 1'b0;
end

endmodule