`include "AXI_define.svh"
`include "bus_define.svh"
module Write_response_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    ////Arbiter
    input [1:0] Aibiter_Write_State_control,
    input [3:0] Arbiter_AWID_control,
    //S to M

	//ROM(S0) can't be write!!
    //S0
	/*
    input [7:0] BID_S0,
    input [1:0] BRESP_S0,
    input BVALID_S0,
    */
	//S1
    input [7:0] BID_S1,
    input [1:0] BRESP_S1,
    input BVALID_S1,
	//S2
    input [7:0] BID_S2,
    input [1:0] BRESP_S2,
    input BVALID_S2,
	//S3
    input [7:0] BID_S3,
    input [1:0] BRESP_S3,
    input BVALID_S3,
	//S4
    input [7:0] BID_S4,
    input [1:0] BRESP_S4,
    input BVALID_S4,

    //write response channel output
    //M0
    output logic [3:0] BID_M0,
    output logic [1:0] BRESP_M0,
    output logic BVALID_M0,
    //M1
    output logic [3:0] BID_M1,
    output logic [1:0] BRESP_M1,
    output logic BVALID_M1,

    //M to S
    input BREADY_M0,
    input BREADY_M1,
    //output logic BREADY_S0,
    output logic BREADY_S1,
	output logic BREADY_S2,
	output logic BREADY_S3,
	output logic BREADY_S4
);
//one M to one S

logic [3:0] BID_Reg;
logic [1:0] BRESP_Reg;
//////////////////////////////////////////////////////////////////////////////////////////////

always_ff @ (posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
		BID_Reg <= 4'b0;
        BRESP_Reg <= 2'b0;
    end
    else begin
		case({BVALID_S4, BVALID_S3, BVALID_S2, BVALID_S1})
			4'b0001:
			begin
				BID_Reg <= BID_S1[3:0];
				BRESP_Reg <= BRESP_S1;
			end
			4'b0010:
			begin
				BID_Reg <= BID_S2[3:0];
				BRESP_Reg <= BRESP_S2;
			end
			4'b0100:
			begin
				BID_Reg <= BID_S3[3:0];
				BRESP_Reg <= BRESP_S3;
			end
			4'b1000:
			begin
				BID_Reg <= BID_S4[3:0];
				BRESP_Reg <= BRESP_S4;
			end
			default:
			begin
				BID_Reg <= 4'b0;
				BRESP_Reg <= 2'b0;
			end
		endcase
    end
end


//All Slave to Master0
always_comb begin
	case(Arbiter_AWID_control)
		//M0_SO should not to here, because ROM can't be write!!
		/*
		`M0_S0_ID:
		begin
			BVALID_M0 = BVALID_S0;
			BID_M0	  = (BVALID_S0)? BID_S0[3:0] : BID_M0_Reg;
			BRESP_M0  = (BVALID_S0)? BRESP_S0	 :BRESP_M0_Reg;
		end
		*/
		//write to IM
		`M0_S1_ID:
		begin
			BVALID_M0 = BVALID_S1;
			BID_M0	  = (BVALID_S1)? BID_S1[3:0] : BID_Reg;
			BRESP_M0  = (BVALID_S1)? BRESP_S1	 :BRESP_Reg;
		end
		//write to DM
		`M0_S2_ID:
		begin
			BVALID_M0 = BVALID_S2;
			BID_M0	  = (BVALID_S2)? BID_S2[3:0] : BID_Reg;
			BRESP_M0  = (BVALID_S2)? BRESP_S2	 :BRESP_Reg;
		end
		//write to sensor ctrl
		`M0_S3_ID:
		begin
			BVALID_M0 = BVALID_S3;
			BID_M0	  = (BVALID_S3)? BID_S3[3:0] : BID_Reg;
			BRESP_M0  = (BVALID_S3)? BRESP_S3	 :BRESP_Reg;
		end
		//write to DRAM
		`M0_S4_ID:
		begin
			BVALID_M0 = BVALID_S4;
			BID_M0	  = (BVALID_S4)? BID_S4[3:0] : BID_Reg;
			BRESP_M0  = (BVALID_S4)? BRESP_S4	 :BRESP_Reg;
		end
		`M0_default_ID:
		begin
			BVALID_M0 = BVALID_S1;
			BID_M0	  = (BVALID_S1)? BID_S4[3:0] : BID_Reg;
			BRESP_M0  = `AXI_RESP_DECERR;
		end
		default:
		begin
			BVALID_M0 = 1'b0;
			BID_M0	  = 4'b0;
			BRESP_M0  = `AXI_RESP_DECERR;
		end
	endcase
end


//All Slave to Master1
always_comb begin
	case(Arbiter_AWID_control)
		//M1_SO should not to here, because ROM can't be write!!
		/*
		`M1_S0_ID:
		begin
			BVALID_M1 = BVALID_S0;
			BID_M1	  = (BVALID_S0)? BID_S0[3:0] : BID_Reg;
			BRESP_M1  = (BVALID_S0)? BRESP_S0	 :BRESP_Reg;
		end
		*/
		//write to IM
		`M1_S1_ID:
		begin
			BVALID_M1 = BVALID_S1;
			BID_M1	  = (BVALID_S1)? BID_S1[3:0] : BID_Reg;
			BRESP_M1  = (BVALID_S1)? BRESP_S1	 :BRESP_Reg;
		end
		//write to DM
		`M1_S2_ID:
		begin
			BVALID_M1 = BVALID_S2;
			BID_M1	  = (BVALID_S2)? BID_S2[3:0] : BID_Reg;
			BRESP_M1  = (BVALID_S2)? BRESP_S2	 :BRESP_Reg;
		end
		//write to sensor ctrl
		`M1_S3_ID:
		begin
			BVALID_M1 = BVALID_S3;
			BID_M1	  = (BVALID_S3)? BID_S3[3:0] : BID_Reg;
			BRESP_M1  = (BVALID_S3)? BRESP_S3	 :BRESP_Reg;
		end
		//write to DRAM
		`M1_S4_ID:
		begin
			BVALID_M1 = BVALID_S4;
			BID_M1	  = (BVALID_S4)? BID_S4[3:0] : BID_Reg;
			BRESP_M1  = (BVALID_S4)? BRESP_S4	 :BRESP_Reg;
		end
		`M1_default_ID:
		begin
			BVALID_M1 = BVALID_S1;
			BID_M1	  = (BVALID_S1)? BID_S4[3:0] : BID_Reg;
			BRESP_M1  = `AXI_RESP_DECERR;
		end
		default:
		begin
			BVALID_M1 = 1'b0;
			BID_M1	  = 4'b0;
			BRESP_M1  = `AXI_RESP_DECERR;
		end
	endcase
end


/////////////////////////////////////////
//Master to all Slave
//to S1
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S1_ID, `M0_default_ID:
			BREADY_S1 = BREADY_M0;
		`M1_S1_ID, `M1_default_ID:	
			BREADY_S1 = BREADY_M1;
		default:
			BREADY_S1 = 1'b0;
	endcase
end

//to S2
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S2_ID:
			BREADY_S2 = BREADY_M0;
		`M1_S2_ID:	
			BREADY_S2 = BREADY_M1;
		default:
			BREADY_S2 = 1'b0;
	endcase
end

//to S3
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S3_ID:
			BREADY_S3 = BREADY_M0;
		`M1_S3_ID:	
			BREADY_S3 = BREADY_M1;
		default:
			BREADY_S3 = 1'b0;
	endcase
end

//to S4
always_comb begin
	case(Arbiter_AWID_control)
		`M0_S4_ID:
			BREADY_S4 = BREADY_M0;
		`M1_S4_ID:	
			BREADY_S4 = BREADY_M1;
		default:
			BREADY_S4 = 1'b0;
	endcase
end



endmodule
