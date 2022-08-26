`include "AXI_define.svh"
`include "bus_define.svh"

module Read_data_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    //Arbiter control
    input [1:0] Aibiter_Read_State_control,
    input [3:0] Arbiter_ARID_control,  
    //S to M
    //S0
    // The RESP of read Data is contained in its own channel
    // not like write data channel has write response channel to use 
    input [7:0]   RID_S0,       
    input [31:0]  RDATA_S0,
    input [1:0]   RRESP_S0,     
    input RLAST_S0,
    input RVALID_S0,
    //S1
    input [7:0]   RID_S1,       
    input [31:0]  RDATA_S1,
    input [1:0]   RRESP_S1,     
    input RLAST_S1,
    input RVALID_S1,
    //S2
    input [7:0]   RID_S2,       
    input [31:0]  RDATA_S2,
    input [1:0]   RRESP_S2,     
    input RLAST_S2,
    input RVALID_S2,
    //S3
    input [7:0]   RID_S3,       
    input [31:0]  RDATA_S3,
    input [1:0]   RRESP_S3,     
    input RLAST_S3,
    input RVALID_S3,
    //S4
    input [7:0]   RID_S4,       
    input [31:0]  RDATA_S4,
    input [1:0]   RRESP_S4,     
    input RLAST_S4,
    input RVALID_S4,

    //read data channel output
    //M0
    output logic [3:0]   RID_M0,       
    output logic [31:0]  RDATA_M0,
    output logic [1:0]   RRESP_M0,     
    output logic RLAST_M0,
    output logic RVALID_M0,
    //M1
    output logic [3:0]   RID_M1,      
    output logic [31:0]  RDATA_M1,
    output logic [1:0]   RRESP_M1,     
    output logic RLAST_M1,
    output logic RVALID_M1,
    //M to S
    input RREADY_M0,
    input RREADY_M1,
    output logic RREADY_S0,
    output logic RREADY_S1,
    output logic RREADY_S2,
    output logic RREADY_S3,
    output logic RREADY_S4
);
//Two Ms to two slaves

logic [`AXI_IDS_BITS-1:0]   RID_Reg;
logic [`AXI_DATA_BITS-1:0] RDATA_Reg;
logic [1:0]                RRESP_Reg;
logic                      RLAST_Reg;

always_ff @(posedge ACLK or negedge ARESETn) begin
    if(!ARESETn)
    begin
        RID_Reg   <= 8'b0;
        RDATA_Reg <= 32'b0;
        RRESP_Reg <= 2'b0;
        RLAST_Reg <= 1'b0;
    end
    else
    begin
        case({RVALID_S4, RVALID_S3, RVALID_S2, RVALID_S1, RVALID_S0})
            5'b00001: 
            begin
                RID_Reg <= RID_S0;
                RDATA_Reg <= RDATA_S0;
                RRESP_Reg <= RRESP_S0;
                RLAST_Reg <= RLAST_S0;
            end
            5'b00010: 
            begin
                RID_Reg <= RID_S1;
                RDATA_Reg <= RDATA_S1;
                RRESP_Reg <= RRESP_S1;
                RLAST_Reg <= RLAST_S1;
            end
            5'b00100: 
            begin
                RID_Reg <= RID_S2;
                RDATA_Reg <= RDATA_S2;
                RRESP_Reg <= RRESP_S2;
                RLAST_Reg <= RLAST_S2;
            end
            5'b01000: 
            begin
                RID_Reg <= RID_S3;
                RDATA_Reg <= RDATA_S3;
                RRESP_Reg <= RRESP_S3;
                RLAST_Reg <= RLAST_S3;
            end
            5'b10000: 
            begin
                RID_Reg <= RID_S4;
                RDATA_Reg <= RDATA_S4;
                RRESP_Reg <= RRESP_S4;
                RLAST_Reg <= RLAST_S4;
            end
            default: 
            begin
                RID_Reg <= RID_Reg;
                RDATA_Reg <= RDATA_Reg;
                RRESP_Reg <= RRESP_Reg;
                RLAST_Reg <= RLAST_Reg;
            end
    endcase
   end
end

//All Slave to Master0
always_comb begin
    case (Arbiter_ARID_control)
        `M0_S0_ID: begin
            RVALID_M0 = RVALID_S0;
            RID_M0 = (RVALID_S0)? RID_S0[3:0] : RID_Reg[3:0];
            RDATA_M0 = (RVALID_S0)? RDATA_S0 : RDATA_Reg;
            RRESP_M0 = (RVALID_S0)? RRESP_S0 : RRESP_Reg;
            RLAST_M0 = (RVALID_S0)? RLAST_S0 : RLAST_Reg;
        end
        `M0_S1_ID: begin
        	RVALID_M0 = RVALID_S1;
            RID_M0 = (RVALID_S1)? RID_S1[3:0] : RID_Reg[3:0];
            RDATA_M0 = (RVALID_S1)? RDATA_S1 : RDATA_Reg;
            RRESP_M0 = (RVALID_S1)? RRESP_S1 : RRESP_Reg;
            RLAST_M0 = (RVALID_S1)? RLAST_S1 : RLAST_Reg;
        end
        `M0_S2_ID: begin
        	RVALID_M0 = RVALID_S2;
            RID_M0 = (RVALID_S2)? RID_S2[3:0] : RID_Reg[3:0];
            RDATA_M0 = (RVALID_S2)? RDATA_S2 : RDATA_Reg;
            RRESP_M0 = (RVALID_S2)? RRESP_S2 : RRESP_Reg;
            RLAST_M0 = (RVALID_S2)? RLAST_S2 : RLAST_Reg;
        end
        `M0_S3_ID: begin
        	RVALID_M0 = RVALID_S3;
            RID_M0 = (RVALID_S3)? RID_S3[3:0] : RID_Reg[3:0];
            RDATA_M0 = (RVALID_S3)? RDATA_S3 : RDATA_Reg;
            RRESP_M0 = (RVALID_S3)? RRESP_S3 : RRESP_Reg;
            RLAST_M0 = (RVALID_S3)? RLAST_S3 : RLAST_Reg;
        end
        `M0_S4_ID: begin
        	RVALID_M0 = RVALID_S4;
            RID_M0 = (RVALID_S4)? RID_S4[3:0] : RID_Reg[3:0];
            RDATA_M0 = (RVALID_S4)? RDATA_S4 : RDATA_Reg;
            RRESP_M0 = (RVALID_S4)? RRESP_S4 : RRESP_Reg;
            RLAST_M0 = (RVALID_S4)? RLAST_S4 : RLAST_Reg;
        end
        `M0_default_ID: begin //default slave
        	RVALID_M0 = RVALID_S0;
            RID_M0 = (RVALID_S0)? RID_S0[3:0] : RID_Reg[3:0];
            RDATA_M0 = (RVALID_S0)? RDATA_S0 : RDATA_Reg;
            RRESP_M0 = `AXI_RESP_DECERR;
            RLAST_M0 = (RVALID_S0)? RLAST_S0 : RLAST_Reg;
        end
        default: begin
        	RVALID_M0 = 1'b0;
            RID_M0 = `AXI_ID_BITS'b0;
            RDATA_M0 = `AXI_DATA_BITS'b0;
            RRESP_M0 = `AXI_RESP_DECERR;
            RLAST_M0 = 1'b0;
        end
    endcase
end

//All Slave to Master1
always_comb begin
    case (Arbiter_ARID_control)
        `M1_S0_ID: begin
            RVALID_M1 = RVALID_S0;
            RID_M1 = (RVALID_S0)? RID_S0[3:0] : RID_Reg[3:0];
            RDATA_M1 = (RVALID_S0)? RDATA_S0 : RDATA_Reg;
            RRESP_M1 = (RVALID_S0)? RRESP_S0 : RRESP_Reg;
            RLAST_M1 = (RVALID_S0)? RLAST_S0 : RLAST_Reg;
        end
        `M1_S1_ID: begin
        	RVALID_M1 = RVALID_S1;
            RID_M1 = (RVALID_S1)? RID_S1[3:0] : RID_Reg[3:0];
            RDATA_M1 = (RVALID_S1)? RDATA_S1 : RDATA_Reg;
            RRESP_M1 = (RVALID_S1)? RRESP_S1 : RRESP_Reg;
            RLAST_M1 = (RVALID_S1)? RLAST_S1 : RLAST_Reg;
        end
        `M1_S2_ID: begin
        	RVALID_M1 = RVALID_S2;
            RID_M1 = (RVALID_S2)? RID_S2[3:0] : RID_Reg[3:0];
            RDATA_M1 = (RVALID_S2)? RDATA_S2 : RDATA_Reg;
            RRESP_M1 = (RVALID_S2)? RRESP_S2 : RRESP_Reg;
            RLAST_M1 = (RVALID_S2)? RLAST_S2 : RLAST_Reg;
        end
        `M1_S3_ID: begin
        	RVALID_M1 = RVALID_S3;
            RID_M1 = (RVALID_S3)? RID_S3[3:0] : RID_Reg[3:0];
            RDATA_M1 = (RVALID_S3)? RDATA_S3 : RDATA_Reg;
            RRESP_M1 = (RVALID_S3)? RRESP_S3 : RRESP_Reg;
            RLAST_M1 = (RVALID_S3)? RLAST_S3 : RLAST_Reg;
        end
        `M1_S4_ID: begin
        	RVALID_M1 = RVALID_S4;
            RID_M1 = (RVALID_S4)? RID_S4[3:0] : RID_Reg[3:0];
            RDATA_M1 = (RVALID_S4)? RDATA_S4 : RDATA_Reg;
            RRESP_M1 = (RVALID_S4)? RRESP_S4 : RRESP_Reg;
            RLAST_M1 = (RVALID_S4)? RLAST_S4 : RLAST_Reg;
        end
        `M1_default_ID: begin //default slave
        	RVALID_M1 = RVALID_S0;
            RID_M1 = (RVALID_S0)? RID_S0[3:0] : RID_Reg[3:0];
            RDATA_M1 = (RVALID_S0)? RDATA_S0 : RDATA_Reg;
            RRESP_M1 = `AXI_RESP_DECERR;
            RLAST_M1 = (RVALID_S0)? RLAST_S0 : RLAST_Reg;
        end
        default: begin
        	RVALID_M1 = 1'b0;
            RID_M1 = `AXI_ID_BITS'b0;
            RDATA_M1 = `AXI_DATA_BITS'b0;
            RRESP_M1 = `AXI_RESP_DECERR;
            RLAST_M1 = 1'b0;
        end
    endcase
end



/////////////////////////////////////////
//Master to all Slave

always_comb begin
    case(Arbiter_ARID_control)
        `M0_S0_ID, `M0_default_ID://M0_S0
            RREADY_S0 = RREADY_M0;
        `M1_S0_ID, `M1_default_ID://M1_S0
            RREADY_S0 = RREADY_M1;
        default:
            RREADY_S0 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_ARID_control)
        `M0_S1_ID://M0_S0
            RREADY_S1 = RREADY_M0;
        `M1_S1_ID, `M1_default_ID://M1_S0
            RREADY_S1 = RREADY_M1;
        default:
            RREADY_S1 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_ARID_control)
        `M0_S2_ID://M0_S0
            RREADY_S2 = RREADY_M0;
        `M1_S2_ID://M1_S0
            RREADY_S2 = RREADY_M1;
        default:
            RREADY_S2 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_ARID_control)
        `M0_S3_ID://M0_S0
            RREADY_S3 = RREADY_M0;
        `M1_S3_ID://M1_S0
            RREADY_S3 = RREADY_M1;
        default:
            RREADY_S3 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_ARID_control)
        `M0_S4_ID://M0_S0
            RREADY_S4 = RREADY_M0;
        `M1_S4_ID://M1_S0
            RREADY_S4 = RREADY_M1;
        default:
            RREADY_S4 = 1'b0;
    endcase
end

endmodule
