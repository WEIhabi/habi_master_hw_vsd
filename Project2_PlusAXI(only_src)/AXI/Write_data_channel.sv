`include "AXI_define.svh"
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
    input [3:0]   WSTRB_M0,    // for narrow transfers
    input WLAST_M0,
    input WVALID_M0,
    //M1      
    input [31:0]  WDATA_M1,
    input [3:0]   WSTRB_M1,     
    input WLAST_M1,
    input WVALID_M1,
    //write data channel output
    //S0    
    output logic [31:0]  WDATA_S0,
    output logic [3:0]   WSTRB_S0,     
    output logic WLAST_S0,
    output logic WVALID_S0,
    //S1
    output logic [31:0]  WDATA_S1,
    output logic [3:0]   WSTRB_S1,     
    output logic WLAST_S1,
    output logic WVALID_S1,
    //S to M 
    input WREADY_S0,
    input WREADY_S1,
    output logic WREADY_M0,
    output logic WREADY_M1
);


logic [31:0] WDATA_S0_Reg, WDATA_S1_Reg;
logic [3:0] WSTRB_S0_Reg, WSTRB_S1_Reg;
logic WLAST_S0_Reg, WLAST_S1_Reg;




always_ff @ (posedge ACLK or negedge ARESETn) begin
	if (!ARESETn) begin
	    WDATA_S0_Reg <= 32'b0;
		WDATA_S1_Reg <= 32'b0;
        WSTRB_S0_Reg <= 4'b0;
        WSTRB_S1_Reg <= 4'b0;
        WLAST_S0_Reg <= 1'b0;
        WLAST_S1_Reg <= 1'b0;
	end
	else begin
	    if (WVALID_M0) begin
			WDATA_S0_Reg <= WDATA_M0;
			WDATA_S1_Reg <= WDATA_M0;
            WSTRB_S0_Reg <= WSTRB_M0;
            WSTRB_S1_Reg <= WSTRB_M0;
            WLAST_S0_Reg <= WLAST_M0;
            WLAST_S1_Reg <= WLAST_M0;
	    end
	    else if (WVALID_M1) begin
			WDATA_S0_Reg <= WDATA_M1;
			WDATA_S1_Reg <= WDATA_M1;
            WSTRB_S0_Reg <= WSTRB_M1;
            WSTRB_S1_Reg <= WSTRB_M1;
            WLAST_S0_Reg <= WLAST_M1;
            WLAST_S1_Reg <= WLAST_M1;
	    end
	    else begin
			WDATA_S0_Reg <= WDATA_S0_Reg;
			WDATA_S1_Reg <= WDATA_S1_Reg;
        	WSTRB_S0_Reg <= WSTRB_S0_Reg;
        	WSTRB_S1_Reg <= WSTRB_S1_Reg;
        	WLAST_S0_Reg <= WLAST_S0_Reg;
        	WLAST_S1_Reg <= WLAST_S1_Reg;
	    end
	end
end

always_comb begin
    case (Arbiter_AWID_control)
        4'b0001, 4'b0100://M0_S0
        begin
		WVALID_S0 = WVALID_M0;
        	WVALID_S1 = 1'b0;
	    	if (WVALID_M0) begin
				WDATA_S0 = WDATA_M0;
				WDATA_S1 = 32'b0;
            	WSTRB_S0 = WSTRB_M0;
            	WSTRB_S1 = 4'b0;
            	WLAST_S0 = WLAST_M0;
            	WLAST_S1 = 1'b0;
	    	end
	    	else begin
				WDATA_S0 = WDATA_S0_Reg;
				WDATA_S1 = WDATA_S1_Reg;
            	WSTRB_S0 = WSTRB_S0_Reg; 
            	WSTRB_S1 = WSTRB_S1_Reg;
            	WLAST_S0 = WLAST_S0_Reg; 
            	WLAST_S1 = WLAST_S1_Reg;
 	    	end
        end
		4'b0010: //M0_S1
        begin
		WVALID_S0 = 1'b0;
        	WVALID_S1 = WVALID_M0;
			if (WVALID_M0) begin
				WDATA_S0 = 32'b0;
				WDATA_S1 = WDATA_M0;
            	WSTRB_S0 = 4'b0;
            	WSTRB_S1 = WSTRB_M0;
            	WLAST_S0 = 1'b0;
            	WLAST_S1 = WLAST_M0;
			end
			else begin
				WDATA_S0 = WDATA_S0_Reg;
				WDATA_S1 = WDATA_S1_Reg;
            	WSTRB_S0 = WSTRB_S0_Reg; 
            	WSTRB_S1 = WSTRB_S1_Reg;
            	WLAST_S0 = WLAST_S0_Reg;
            	WLAST_S1 = WLAST_S1_Reg;
 	    	end
		end
		4'b1001, 4'b1100: //M1_S0
        begin
		WVALID_S0 = WVALID_M1;
        	WVALID_S1 = 1'b0;
			if (WVALID_M1) begin
				WDATA_S0 = WDATA_M1;
				WDATA_S1 = 32'b0;
            	WSTRB_S0 = WSTRB_M1;
            	WSTRB_S1 = 4'b0;
            	WLAST_S0 = WLAST_M1;
            	WLAST_S1 = 1'b0;
			end
			else begin
				WDATA_S0 = WDATA_S0_Reg;
				WDATA_S1 = WDATA_S1_Reg;
            	WSTRB_S0 = WSTRB_S0_Reg; 
            	WSTRB_S1 = WSTRB_S1_Reg;
            	WLAST_S0 = WLAST_S0_Reg;
            	WLAST_S1 = WLAST_S1_Reg;
 	    	end
		end
        4'b1010://M1_S1
        begin
		WVALID_S0 = 1'b0;
        	WVALID_S1 = WVALID_M1;
	    	if (WVALID_M1) begin
				WDATA_S0 = 32'b0;
            	WDATA_S1 = WDATA_M1;
            	WSTRB_S0 = 4'b0;
            	WSTRB_S1 = WSTRB_M1;
            	WLAST_S0 = 1'b0;
            	WLAST_S1 = WLAST_M1;
	    	end
	    	else begin
		    	WDATA_S0 = WDATA_S0_Reg;
				WDATA_S1 = WDATA_S1_Reg;
            	WSTRB_S0 = WSTRB_S0_Reg; 
            	WSTRB_S1 = WSTRB_S1_Reg;
            	WLAST_S0 = WLAST_S0_Reg; 
            	WLAST_S1 = WLAST_S1_Reg;
	    	end
        end
/*
        4'b0100, 4'b1100:
        begin
            WVALID_S0 = 1'b0;
            WVALID_S1 = 1'b0;
            WDATA_S0 = `AXI_DATA_BITS'b0;
            WDATA_S1 = `AXI_DATA_BITS'b0;
            WSTRB_S0 = `AXI_STRB_BITS'b0;
            WSTRB_S1 = `AXI_STRB_BITS'b0;
            WLAST_S0 = 1'b0;
            WLAST_S1 = 1'b0;
        end
*/
		default: begin
		WVALID_S0 = 1'b0;
            WVALID_S1 = 1'b0;
            WDATA_S0 = `AXI_DATA_BITS'b0;
            WDATA_S1 = `AXI_DATA_BITS'b0;
            WSTRB_S0 = `AXI_STRB_BITS'b0;
            WSTRB_S1 = `AXI_STRB_BITS'b0;
            WLAST_S0 = 1'b0;
            WLAST_S1 = 1'b0;
        end

    endcase
end

always_comb begin
    case (Arbiter_AWID_control)
        4'b0001, 4'b0100://M0_S0
        begin
			WREADY_M0 = WREADY_S0;
            WREADY_M1 = 1'b0;
        end
		4'b0010://M0_S1
        begin
			WREADY_M0 = WREADY_S1;
			WREADY_M1 = 1'b0;
		end
		4'b1001, 4'b1100://M1_S0
        begin
			WREADY_M0 = 1'b0;
            WREADY_M1 = WREADY_S0;
        end
		4'b1010://M1_S1
        begin
			WREADY_M0 = 1'b0;
            WREADY_M1 = WREADY_S1;
		end
/*
        4'b0100, 4'b1100:
        begin
            WREADY_M0 = 1'b0;
            WREADY_M1 = 1'b0;
        end
*/
        default: begin
	    	WREADY_M0 = 1'b0;
            WREADY_M1 = 1'b0;
        end
    endcase
end


endmodule
