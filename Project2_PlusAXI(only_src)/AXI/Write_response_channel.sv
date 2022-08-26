`include "AXI_define.svh"
module Write_response_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    ////Arbiter
    input [1:0] Aibiter_Write_State_control,
    input [3:0] Arbiter_AWID_control,
    //S to M
    //S0
    input [7:0] BID_S0,
    input [1:0] BRESP_S0,
    input BVALID_S0,
    //S1
    input [7:0] BID_S1,
    input [1:0] BRESP_S1,
    input BVALID_S1,
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
    output logic BREADY_S0,
    output logic BREADY_S1
);
//one M to one S

logic [3:0] BID_M0_Reg, BID_M1_Reg;
logic [1:0]  BRESP_M0_Reg, BRESP_M1_Reg;
//////////////////////////////////////////////////////////////////////////////////////////////
// save s0 s1 data to mo m1 register
always_ff @ (posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
		BID_M0_Reg <= 4'b0;
		BID_M1_Reg <= 4'b0;
        BRESP_M0_Reg <= 2'b0;
		BRESP_M1_Reg <= 2'b0;
    end
    else begin
		if (BVALID_S0) begin
		    BID_M0_Reg <= BID_S0[3:0];
		    BID_M1_Reg <= BID_S0[3:0];
	        BRESP_M0_Reg <= BRESP_S0;
		    BRESP_M1_Reg <= BRESP_S0;
		end
		else if (BVALID_S1) begin
		    BID_M0_Reg <= BID_S1[3:0];
		    BID_M1_Reg <= BID_S1[3:0];
	        BRESP_M0_Reg <= BRESP_S1;
		    BRESP_M1_Reg <= BRESP_S1;
		end
		else begin
		    BID_M0_Reg <= BID_M0_Reg;
		    BID_M1_Reg <= BID_M1_Reg;
	        BRESP_M0_Reg <= BRESP_M0_Reg;
		    BRESP_M1_Reg <= BRESP_M1_Reg;
		end
    end
end


always_comb begin
    case (Arbiter_AWID_control)
        4'b0001://M0_S0
        begin
	    	BVALID_M0 = BVALID_S0;
            BVALID_M1 = 1'b0;
		    if (BVALID_S0) begin
				BID_M0 = BID_S0[3:0];
				BID_M1 = 4'b0;
				BRESP_M0 = BRESP_S0;
            	BRESP_M1 = 2'b10;//RESP_SLVERR
	    	end
	    	else begin
				BID_M0 = BID_M0_Reg;
				BID_M1 = BID_M1_Reg;
				BRESP_M0 = BRESP_M0_Reg;
				BRESP_M1 = 2'b10;//RESP_SLVERR
  	    	end
        end
		4'b0010://M0_S1
        begin
			BVALID_M0 = BVALID_S1;
            BVALID_M1 = 1'b0;
			if (BVALID_S1) begin
				BID_M0 = BID_S1[3:0];
				BID_M1 = 4'b0;
				BRESP_M0 = BRESP_S1;
            	BRESP_M1 = 2'b10;//RESP_SLVERR
	    	end
			else begin
				BID_M0 = BID_M0_Reg;
				BID_M1 = BID_M1_Reg;
				BRESP_M0 = BRESP_M0_Reg;
				BRESP_M1 = 2'b10;//RESP_SLVERR
  	    	end
		end

		4'b0100://M0_Default_slave
        begin
			BVALID_M0 = BVALID_S0;
            BVALID_M1 = 1'b0;
		    if (BVALID_S0) begin
				BID_M0 = BID_S0[3:0];
				BID_M1 = 4'b0;
				BRESP_M0 = 2'b11;//RESP_DECERR;
            	BRESP_M1 = 2'b10;//RESP_SLVERR
	    	end
			else begin
				BID_M0 = BID_M0_Reg;
				BID_M1 = BID_M1_Reg;
				BRESP_M0 = 2'b11;//RESP_DECERR;
				BRESP_M1 = 2'b10;//RESP_SLVERR
  	    	end
		end

		4'b1001://M1_S0
        begin
			BVALID_M0 = 1'b0;
            BVALID_M1 = BVALID_S0;
			if (BVALID_S0) begin
				BID_M0 = 4'b0;
				BID_M1 = BID_S0[3:0];
				BRESP_M0 = 2'b10;//RESP_SLVERR
            	BRESP_M1 = BRESP_S0;
	    	end
			else begin
				BID_M0 = BID_M0_Reg;
				BID_M1 = BID_M1_Reg;
				BRESP_M0 = 2'b10;//RESP_SLVERR
				BRESP_M1 = BRESP_M1_Reg;
  	    	end
		end
        4'b1010://M1_S1
        begin
	    	BVALID_M0 = 1'b0;
            BVALID_M1 = BVALID_S1;
	    	if (BVALID_S1) begin
				BID_M0 = 4'b0;
				BID_M1 = BID_S1[3:0];
				BRESP_M0 = 2'b10;//RESP_SLVERR
				BRESP_M1 = BRESP_S1;
	    	end
	    	else begin
				BID_M0 = BID_M0_Reg;
				BID_M1 = BID_M1_Reg;
				BRESP_M0 = 2'b10;//RESP_SLVERR
				BRESP_M1 = BRESP_M1_Reg;
	    	end
        end

	    4'b1100:////M1_Default_slave
        begin
	        BVALID_M0 = 1'b0;
            BVALID_M1 = BVALID_S0;
	        if (BVALID_S0) begin
		        BID_M0 = 4'b0;
		        BID_M1 = BID_S0[3:0];
				BRESP_M0 = 2'b10;//RESP_SLVERR
            	BRESP_M1 = 2'b11;//RESP_DECERR;
	        end
	        else begin
		        BID_M0 = BID_M0_Reg;
		        BID_M1 = BID_M1_Reg;
				BRESP_M0 = 2'b10;//RESP_SLVERR
            	BRESP_M1 = 2'b11;//RESP_DECERR;
 	        end
	    end

        default:
        begin
			BVALID_M0 = 1'b0;
	        BVALID_M1 = 1'b0;
            BID_M0 = 4'b0;
	        BID_M1 = 4'b0;
            BRESP_M0 = 2'b11;//RESP_DECERR;
	        BRESP_M1 = 2'b11;//RESP_DECERR;
        end
    endcase
end



always_comb begin
    case (Arbiter_AWID_control)
    	4'b0001, 4'b0100: 
	  	begin
            BREADY_S0 = BREADY_M0;
            BREADY_S1 = 1'b0;
        end
	  	4'b0010: 
	  	begin
			BREADY_S0 = 1'b0;
            BREADY_S1 = BREADY_M0;
		end
	  	4'b1001, 4'b1100: 
	  	begin
			BREADY_S0 = BREADY_M1;
            BREADY_S1 = 1'b0;
		end
      	4'b1010: 
	  	begin
            BREADY_S0 = 1'b0;
            BREADY_S1 = BREADY_M1;
        end
        /*4'b0100, 4'b1100:
        begin
            BREADY_S0 = 1'b0;
            BREADY_S1 = 1'b0;
        end*/
        default: 
	  begin
            BREADY_S0 = 1'b0;
            BREADY_S1 = 1'b0;
        end
    endcase
end



endmodule
