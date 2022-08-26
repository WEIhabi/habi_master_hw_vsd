`include "AXI_define.svh"
`include "bus_define.svh"
module Write_data_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    ////Arbiter
    input [1:0] Aibiter_Write_State_control,
    input [3:0] Arbiter_AWID_control,
    //M to S 
    //M0  
    input [31:0]  WDATA_M0,
    input [3:0]   WSTRB_M0,    
    input WLAST_M0,
    input WVALID_M0,
    //M1      
    input [31:0]  WDATA_M1,
    input [3:0]   WSTRB_M1,     
    input WLAST_M1,
    input WVALID_M1,
    //write data channel output
    //S0
	/*    
    output logic [31:0]  WDATA_S0,
    output logic [3:0]   WSTRB_S0,     
    output logic WLAST_S0,
    output logic WVALID_S0,
	*/
    //S1
    output logic [31:0]  WDATA_S1,
    output logic [3:0]   WSTRB_S1,     
    output logic WLAST_S1,
    output logic WVALID_S1,
	//S2
    output logic [31:0]  WDATA_S2,
    output logic [3:0]   WSTRB_S2,     
    output logic WLAST_S2,
    output logic WVALID_S2,
	//S3
    output logic [31:0]  WDATA_S3,
    output logic [3:0]   WSTRB_S3,     
    output logic WLAST_S3,
    output logic WVALID_S3,
	//S4
    output logic [31:0]  WDATA_S4,
    output logic [3:0]   WSTRB_S4,     
    output logic WLAST_S4,
    output logic WVALID_S4,

    //S to M 
    //input WREADY_S0,
    input WREADY_S1,
	input WREADY_S2,
	input WREADY_S3,
	input WREADY_S4,
    output logic WREADY_M0,
    output logic WREADY_M1
);


logic [31:0] WDATA_Reg;
logic [3:0] WSTRB_Reg;
logic WLAST_Reg;


always_ff @ (posedge ACLK or negedge ARESETn) begin
	if (!ARESETn) begin
	    WDATA_Reg <= 32'b0;
        WSTRB_Reg <= 4'b0;
        WLAST_Reg <= 1'b0;
	end
	else begin
	    if (WVALID_M0) begin
			WDATA_Reg <= WDATA_M0;
            WSTRB_Reg <= WSTRB_M0;
            WLAST_Reg <= WLAST_M0;
	    end
	    else if (WVALID_M1) begin
			WDATA_Reg <= WDATA_M1;
            WSTRB_Reg <= WSTRB_M1;
            WLAST_Reg <= WLAST_M1;
	    end
	    else begin
			WDATA_Reg <= WDATA_Reg;
        	WSTRB_Reg <= WSTRB_Reg;
        	WLAST_Reg <= WLAST_Reg;
	    end
	end
end

//we have 5 Slave need to distributed

// All Master to Slave0
/*
//M0 can't to write
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S0_ID, `M0_default_ID://M0_to_S0
		begin
			WVALID_S0 = WVALID_M0;
			WDATA_S0  = (WVALID_M0)? WDATA_M0 : WDATA_Reg;
			WSTRB_S0  = (WVALID_M0)? WSTRB_M0 : WSTRB_Reg;
			WLAST_S0  = (WVALID_M0)? WLAST_M0 : WLAST_Reg;
		end
		`M1_S0_ID, `M1_default_ID://M1_to_S0
		begin
			WVALID_S0 = WVALID_M1;
			WDATA_S0  = (WVALID_M1)? WDATA_M1 : WDATA_Reg;
			WSTRB_S0  = (WVALID_M1)? WSTRB_M1 : WSTRB_Reg;
			WLAST_S0  = (WVALID_M1)? WLAST_M1 : WLAST_Reg;
		end
		default:
		begin
			WVALID_S0 = 1'b0;
			WDATA_S0  = 32'b0;
			WSTRB_S0  = 4'b0;
			WLAST_S0  = 1'b0;
		end
	endcase
end
*/

// All Master to Slave1
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S1_ID, `M0_default_ID://M0_to_S1
		begin
			WVALID_S1 = WVALID_M0;
			WDATA_S1  = (WVALID_M0)? WDATA_M0 : WDATA_Reg;
			WSTRB_S1  = (WVALID_M0)? WSTRB_M0 : WSTRB_Reg;
			WLAST_S1  = (WVALID_M0)? WLAST_M0 : WLAST_Reg;
		end
		`M1_S1_ID, `M1_default_ID://M1_to_S1
		begin
			WVALID_S1 = WVALID_M1;
			WDATA_S1  = (WVALID_M1)? WDATA_M1 : WDATA_Reg;
			WSTRB_S1  = (WVALID_M1)? WSTRB_M1 : WSTRB_Reg;
			WLAST_S1  = (WVALID_M1)? WLAST_M1 : WLAST_Reg;
		end
		default:
		begin
			WVALID_S1 = 1'b0;
			WDATA_S1  = 32'b0;
			WSTRB_S1  = 4'b0;
			WLAST_S1  = 1'b0;
		end
	endcase
end


// All Master to Slave2
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S2_ID, `M0_default_ID://M0_to_S2
		begin
			WVALID_S2 = WVALID_M0;
			WDATA_S2  = (WVALID_M0)? WDATA_M0 : WDATA_Reg;
			WSTRB_S2  = (WVALID_M0)? WSTRB_M0 : WSTRB_Reg;
			WLAST_S2  = (WVALID_M0)? WLAST_M0 : WLAST_Reg;
		end
		`M1_S2_ID, `M1_default_ID://M1_to_S2
		begin
			WVALID_S2 = WVALID_M1;
			WDATA_S2  = (WVALID_M1)? WDATA_M1 : WDATA_Reg;
			WSTRB_S2  = (WVALID_M1)? WSTRB_M1 : WSTRB_Reg;
			WLAST_S2  = (WVALID_M1)? WLAST_M1 : WLAST_Reg;
		end
		default:
		begin
			WVALID_S2 = 1'b0;
			WDATA_S2  = 32'b0;
			WSTRB_S2  = 4'b0;
			WLAST_S2  = 1'b0;
		end
	endcase
end

// All Master to Slave3
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S3_ID, `M0_default_ID://M0_to_S3
		begin
			WVALID_S3 = WVALID_M0;
			WDATA_S3  = (WVALID_M0)? WDATA_M0 : WDATA_Reg;
			WSTRB_S3  = (WVALID_M0)? WSTRB_M0 : WSTRB_Reg;
			WLAST_S3  = (WVALID_M0)? WLAST_M0 : WLAST_Reg;
		end
		`M1_S3_ID, `M1_default_ID://M1_to_S3
		begin
			WVALID_S3 = WVALID_M1;
			WDATA_S3  = (WVALID_M1)? WDATA_M1 : WDATA_Reg;
			WSTRB_S3  = (WVALID_M1)? WSTRB_M1 : WSTRB_Reg;
			WLAST_S3  = (WVALID_M1)? WLAST_M1 : WLAST_Reg;
		end
		default:
		begin
			WVALID_S3 = 1'b0;
			WDATA_S3  = 32'b0;
			WSTRB_S3  = 4'b0;
			WLAST_S3  = 1'b0;
		end
	endcase
end


// All Master to Slave4
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S4_ID, `M0_default_ID://M0_to_S4
		begin
			WVALID_S4 = WVALID_M0;
			WDATA_S4  = (WVALID_M0)? WDATA_M0 : WDATA_Reg;
			WSTRB_S4  = (WVALID_M0)? WSTRB_M0 : WSTRB_Reg;
			WLAST_S4  = (WVALID_M0)? WLAST_M0 : WLAST_Reg;
		end
		`M1_S4_ID, `M1_default_ID://M1_to_S4
		begin
			WVALID_S4 = WVALID_M1;
			WDATA_S4  = (WVALID_M1)? WDATA_M1 : WDATA_Reg;
			WSTRB_S4  = (WVALID_M1)? WSTRB_M1 : WSTRB_Reg;
			WLAST_S4  = (WVALID_M1)? WLAST_M1 : WLAST_Reg;
		end
		default:
		begin
			WVALID_S4 = 1'b0;
			WDATA_S4  = 32'b0;
			WSTRB_S4  = 4'b0;
			WLAST_S4  = 1'b0;
		end
	endcase
end


//Slave return ready to Master 
always_comb begin
    case(Arbiter_AWID_control)
        `M0_S1_ID, `M0_default_ID: //S1_M0
            WREADY_M0 = WREADY_S1;
        `M0_S2_ID:           //S2_M0
            WREADY_M0 = WREADY_S2;
        `M0_S3_ID:           //S3_M0
            WREADY_M0 = WREADY_S3;
        `M0_S4_ID:           //S4_M0
            WREADY_M0 = WREADY_S4;
        default:
            WREADY_M0 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_AWID_control)
        `M1_S1_ID, `M1_default_ID://S1_M1
            WREADY_M1 = WREADY_S1;
        `M1_S2_ID:           //S2_M1
            WREADY_M1 = WREADY_S2;
        `M1_S3_ID:           //S3_M1
            WREADY_M1 = WREADY_S3;
        `M1_S4_ID:           //S4_M1
            WREADY_M1 = WREADY_S4;
        default:
            WREADY_M1 = 1'b0;
    endcase
end





endmodule
