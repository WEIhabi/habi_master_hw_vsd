`include "AXI_define.svh"
`include "bus_define.svh"
module Write_address_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    ////Arbiter
    input [1:0] Aibiter_Write_State_control,
    input [3:0] Arbiter_AWID_control,
    //M to S
    //M0
    input [3:0]   AWID_M0,    //(because have two M IF stage and MEM stage)
    input [31:0]  AWADDR_M0,
    input [3:0]   AWLEN_M0,
    //Burst length: AWLEN[3:0] and AWLEN[3:0] indicate this
    //The inside of a burst cannot be interrupted.
    input [2:0]   AWSIZE_M0,   // 8 condition (1，2，4，8，16，32，64，128)
    input [1:0]   AWBURST_M0,
    input AWVALID_M0,
    //M1
    input [3:0]   AWID_M1,    //M1 is M1
    input [31:0]  AWADDR_M1,
    input [3:0]   AWLEN_M1,
    input [2:0]   AWSIZE_M1,
    input [1:0]   AWBURST_M1,
    input AWVALID_M1,
    //write address channel output
    //S0(ROM)
    /*
    output logic [7:0]   AWID_S0,    //(because have two S IM and DM)
    output logic [31:0]  AWADDR_S0,
    output logic [3:0]   AWLEN_S0,
    output logic [2:0]   AWSIZE_S0,
    output logic [1:0]   AWBURST_S0,
    output logic AWVALID_S0,
    */
    //S1(IM)
    output logic [7:0]   AWID_S1,    
    output logic [31:0]  AWADDR_S1,
    output logic [3:0]   AWLEN_S1,
    output logic [2:0]   AWSIZE_S1,
    output logic [1:0]   AWBURST_S1,
    output logic AWVALID_S1,
    //S2(DM)
    output logic [7:0]   AWID_S2,    
    output logic [31:0]  AWADDR_S2,
    output logic [3:0]   AWLEN_S2,
    output logic [2:0]   AWSIZE_S2,
    output logic [1:0]   AWBURST_S2,
    output logic AWVALID_S2,
    //S3(sensor ctrl)
    output logic [7:0]   AWID_S3,    
    output logic [31:0]  AWADDR_S3,
    output logic [3:0]   AWLEN_S3,
    output logic [2:0]   AWSIZE_S3,
    output logic [1:0]   AWBURST_S3,
    output logic AWVALID_S3,
    //S4(DRAM)
    output logic [7:0]   AWID_S4,    
    output logic [31:0]  AWADDR_S4,
    output logic [3:0]   AWLEN_S4,
    output logic [2:0]   AWSIZE_S4,
    output logic [1:0]   AWBURST_S4,
    output logic AWVALID_S4,


    //S to M
    //input AWREADY_S0,
    input AWREADY_S1,
    input AWREADY_S2,
    input AWREADY_S3,
    input AWREADY_S4,
    output logic AWREADY_M0,
    output logic AWREADY_M1
);
//Two M to two S
logic [7:0]  AWID_reg;
logic [31:0] AWADDR_reg;
logic [3:0]  AWLEN_reg;
logic [2:0]  AWSIZE_reg;
logic [1:0]  AWBURST_reg;

always_ff @ (posedge ACLK or negedge ARESETn) begin
    if(!ARESETn)
    begin
        AWID_reg <= 8'b0;
        AWADDR_reg <= 32'b0;
        AWLEN_reg <= 4'b0;
        AWSIZE_reg <= 3'b0;
        AWBURST_reg <= 2'b0;
    end
    else
    begin
        if (AWVALID_M0 && Aibiter_Write_State_control == 2'b00) 
        begin
            AWID_reg <= {4'b0,AWID_M0};
            AWADDR_reg <= AWADDR_M0;
            AWLEN_reg <= AWLEN_M0;
            AWSIZE_reg <= AWSIZE_M0;
            AWBURST_reg <= AWBURST_M0;
        end
        else if(AWVALID_M1 && Aibiter_Write_State_control == 2'b00)
        begin
            AWID_reg <= {4'b0,AWID_M1};
            AWADDR_reg <= AWADDR_M1;
            AWLEN_reg <= AWLEN_M1;
            AWSIZE_reg <= AWSIZE_M1;
            AWBURST_reg <= AWBURST_M1;
        end
        else    //When VALID=0, keep the data in the FF.  or  VALID != 0 || state=01/10
        begin
            AWID_reg <= AWID_reg;
            AWADDR_reg <= AWADDR_reg;
            AWLEN_reg <= AWLEN_reg;
            AWSIZE_reg <= AWSIZE_reg;
            AWBURST_reg <= AWBURST_reg;
        end
    end
end


//we have 5 Slave need to distributed

// All Master to Slave0
//S0 can't write
/*
always_comb begin
    case(Arbiter_AWID_control)      //Using arbiter send the ID control.
        `M0_S0_ID, `M0_default_ID://M0_to_S0
        begin
            AWVALID_S0 = AWVALID_M0;
            AWID_S0     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M0} : AWID_reg;
            AWADDR_S0   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M0 : AWADDR_reg;
            AWLEN_S0    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M0 : AWLEN_reg;
            AWSIZE_S0   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M0 : AWSIZE_reg;
            AWBURST_S0  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M0 : AWBURST_reg;
        end
        //
        `M1_S0_ID, `M1_default_ID://M1_to_S0
        begin
            AWVALID_S0 = AWVALID_M1;
            AWID_S0     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M1} : AWADDR_reg;
            AWADDR_S0   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M1 : AWADDR_reg;
            AWLEN_S0    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M1 : AWLEN_reg;
            AWSIZE_S0   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M1 : AWSIZE_reg;
            AWBURST_S0  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M1 : AWBURST_reg;
        end
        default:
        begin
            AWVALID_S0 = 1'b0;
			AWID_S0 = 8'b0;
			AWADDR_S0 = 32'b0;
			AWLEN_S0 = 4'b0;
			AWSIZE_S0 = 3'b0;
			AWBURST_S0 = 2'b0;
        end
    endcase
end
*/

// All Master to Slave1
always_comb begin
    case(Arbiter_AWID_control)
        `M0_S1_ID:
        begin
            AWVALID_S1 = AWVALID_M0;
            AWID_S1     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M0} : AWID_reg;
            AWADDR_S1   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M0 : AWADDR_reg;
            AWLEN_S1    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M0 : AWLEN_reg;
            AWSIZE_S1   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M0 : AWSIZE_reg;
            AWBURST_S1  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M0 : AWBURST_reg;
        end
        `M1_S1_ID:
        begin
            AWVALID_S1 = AWVALID_M1;
            AWID_S1     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M1} : AWID_reg;
            AWADDR_S1   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M1 : AWADDR_reg;
            AWLEN_S1    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M1 : AWLEN_reg;
            AWSIZE_S1   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M1 : AWSIZE_reg;
            AWBURST_S1  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M1 : AWBURST_reg;
        end
        default:
        begin
            AWVALID_S1 = 1'b0;
			AWID_S1 = 8'b0;
			AWADDR_S1 = 32'b0;
			AWLEN_S1 = 4'b0;
			AWSIZE_S1 = 3'b0;
			AWBURST_S1 = 2'b0;
        end
    endcase
end


// All Master to Slave2
always_comb begin
    case(Arbiter_AWID_control)
        `M0_S2_ID:
        begin
            AWVALID_S2 = AWVALID_M0;
            AWID_S2     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M0} : AWID_reg;
            AWADDR_S2   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M0 : AWADDR_reg;
            AWLEN_S2    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M0 : AWLEN_reg;
            AWSIZE_S2   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M0 : AWSIZE_reg;
            AWBURST_S2  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M0 : AWBURST_reg;
        end
        `M1_S2_ID:
        begin
            AWVALID_S2 = AWVALID_M1;
            AWID_S2     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M1} : AWID_reg;
            AWADDR_S2   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M1 : AWADDR_reg;
            AWLEN_S2    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M1 : AWLEN_reg;
            AWSIZE_S2   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M1 : AWSIZE_reg;
            AWBURST_S2  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M1 : AWBURST_reg;
        end
        default:
        begin
            AWVALID_S2 = 1'b0;
			AWID_S2 = 8'b0;
			AWADDR_S2 = 32'b0;
			AWLEN_S2 = 4'b0;
			AWSIZE_S2 = 3'b0;
			AWBURST_S2 = 2'b0;
        end
    endcase
end

// All Master to Slave3
always_comb begin
    case(Arbiter_AWID_control)
        `M0_S3_ID:
        begin
            AWVALID_S3 = AWVALID_M0;
            AWID_S3     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M0} : AWID_reg;
            AWADDR_S3   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M0 : AWADDR_reg;
            AWLEN_S3    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M0 : AWLEN_reg;
            AWSIZE_S3   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M0 : AWSIZE_reg;
            AWBURST_S3  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M0 : AWBURST_reg;
        end
        `M1_S3_ID:
        begin
            AWVALID_S3 = AWVALID_M1;
            AWID_S3     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M1} : AWID_reg;
            AWADDR_S3   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M1 : AWADDR_reg;
            AWLEN_S3    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M1 : AWLEN_reg;
            AWSIZE_S3   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M1 : AWSIZE_reg;
            AWBURST_S3  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M1 : AWBURST_reg;
        end
        default:
        begin
            AWVALID_S3 = 1'b0;
			AWID_S3 = 8'b0;
			AWADDR_S3 = 32'b0;
			AWLEN_S3 = 4'b0;
			AWSIZE_S3 = 3'b0;
			AWBURST_S3 = 2'b0;
        end
    endcase
end
// All Master to Slave4
always_comb begin
    case(Arbiter_AWID_control)
        `M0_S4_ID:
        begin
            AWVALID_S4 = AWVALID_M0;
            AWID_S4     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M0} : AWID_reg;
            AWADDR_S4   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M0 : AWADDR_reg;
            AWLEN_S4    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M0 : AWLEN_reg;
            AWSIZE_S4   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M0 : AWSIZE_reg;
            AWBURST_S4  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M0 : AWBURST_reg;
        end
        `M1_S4_ID:
        begin
            AWVALID_S4 = AWVALID_M1;
            AWID_S4     = (Aibiter_Write_State_control == 2'b0)? {4'b0,AWID_M1} : AWID_reg;
            AWADDR_S4   = (Aibiter_Write_State_control == 2'b0)? AWADDR_M1 : AWADDR_reg;
            AWLEN_S4    = (Aibiter_Write_State_control == 2'b0)? AWLEN_M1 : AWLEN_reg;
            AWSIZE_S4   = (Aibiter_Write_State_control == 2'b0)? AWSIZE_M1 : AWSIZE_reg;
            AWBURST_S4  = (Aibiter_Write_State_control == 2'b0)? AWBURST_M1 : AWBURST_reg;
        end
        default:
        begin
            AWVALID_S4 = 1'b0;
			AWID_S4 = 8'b0;
			AWADDR_S4 = 32'b0;
			AWLEN_S4 = 4'b0;
			AWSIZE_S4 = 3'b0;
			AWBURST_S4 = 2'b0;
        end
    endcase
end


//Slave return ready to Master 
always_comb begin
    case(Arbiter_AWID_control)
        `M0_S1_ID, `M0_default_ID://S1_M0
            AWREADY_M0 = AWREADY_S1;
        `M0_S2_ID:           //S2_M0
            AWREADY_M0 = AWREADY_S2;
        `M0_S3_ID:           //S3_M0
            AWREADY_M0 = AWREADY_S3;
        `M0_S4_ID:           //S4_M0
            AWREADY_M0 = AWREADY_S4;
        default:
            AWREADY_M0 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_AWID_control)
        `M1_S1_ID, `M1_default_ID://S1_M1
            AWREADY_M1 = AWREADY_S1;
        `M1_S2_ID:           //S2_M1
            AWREADY_M1 = AWREADY_S2;
        `M1_S3_ID:           //S3_M1
            AWREADY_M1 = AWREADY_S3;
        `M1_S4_ID:           //S4_M1
            AWREADY_M1 = AWREADY_S4;
        default:
            AWREADY_M1 = 1'b0;
    endcase
end


endmodule
