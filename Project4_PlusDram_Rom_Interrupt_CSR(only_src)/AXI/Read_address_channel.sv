`include "AXI_define.svh"
`include "bus_define.svh"
module Read_address_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    ////Arbiter
    input [1:0] Aibiter_Read_State_control,
    input [3:0] Arbiter_ARID_control,
    //M to S
    //M0
    input [3:0]   ARID_M0,    //(because have two M IF stage and MEM stage)
    input [31:0]  ARADDR_M0,
    input [3:0]   ARLEN_M0,
    input [2:0]   ARSIZE_M0,
    input [1:0]   ARBURST_M0,
    input ARVALID_M0,
    //M1
    input [3:0]   ARID_M1,    
    input [31:0]  ARADDR_M1,
    input [3:0]   ARLEN_M1,
    input [2:0]   ARSIZE_M1,
    input [1:0]   ARBURST_M1,
    input ARVALID_M1,
    //read address channel output
    //S0(ROM)
    output logic [7:0]   ARID_S0,    
    output logic [31:0]  ARADDR_S0,
    output logic [3:0]   ARLEN_S0,
    output logic [2:0]   ARSIZE_S0,
    output logic [1:0]   ARBURST_S0,
    output logic ARVALID_S0,
    //S1(IM)
    output logic [7:0]   ARID_S1,    
    output logic [31:0]  ARADDR_S1,
    output logic [3:0]   ARLEN_S1,
    output logic [2:0]   ARSIZE_S1,
    output logic [1:0]   ARBURST_S1,
    output logic ARVALID_S1,
    //S2(DM)
    output logic [7:0]   ARID_S2,    
    output logic [31:0]  ARADDR_S2,
    output logic [3:0]   ARLEN_S2,
    output logic [2:0]   ARSIZE_S2,
    output logic [1:0]   ARBURST_S2,
    output logic ARVALID_S2,
    //S3(sensor ctrl)
    output logic [7:0]   ARID_S3,    
    output logic [31:0]  ARADDR_S3,
    output logic [3:0]   ARLEN_S3,
    output logic [2:0]   ARSIZE_S3,
    output logic [1:0]   ARBURST_S3,
    output logic ARVALID_S3,
    //S4(DRAM)
    output logic [7:0]   ARID_S4,    
    output logic [31:0]  ARADDR_S4,
    output logic [3:0]   ARLEN_S4,
    output logic [2:0]   ARSIZE_S4,
    output logic [1:0]   ARBURST_S4,
    output logic ARVALID_S4,
    
    //S to M
    input ARREADY_S0,
    input ARREADY_S1,
    input ARREADY_S2,
    input ARREADY_S3,
    input ARREADY_S4,
    output logic ARREADY_M0,
    output logic ARREADY_M1
    );
//Two Masters to two Slaves

logic [7:0]  ARID_reg;
logic [31:0] ARADDR_reg;
logic [3:0]  ARLEN_reg;
logic [2:0]  ARSIZE_reg;
logic [1:0]  ARBURST_reg;

//M to S
always_ff @ (posedge ACLK or negedge ARESETn) begin
    if(!ARESETn)
    begin
        ARID_reg <= 8'b0;
        ARADDR_reg <= 32'b0;
        ARLEN_reg <= 4'b0;
        ARSIZE_reg <= 3'b0;
        ARBURST_reg <= 2'b0;
    end
    else
    begin
        if (ARVALID_M0 && Aibiter_Read_State_control == 2'b00) 
        begin
            ARID_reg <= {4'b0,ARID_M0};
            ARADDR_reg <= ARADDR_M0;
            ARLEN_reg <= ARLEN_M0;
            ARSIZE_reg <= ARSIZE_M0;
            ARBURST_reg <= ARBURST_M0;
        end
        else if(ARVALID_M1 && Aibiter_Read_State_control == 2'b00)
        begin
            ARID_reg <= {4'b0,ARID_M1};
            ARADDR_reg <= ARADDR_M1;
            ARLEN_reg <= ARLEN_M1;
            ARSIZE_reg <= ARSIZE_M1;
            ARBURST_reg <= ARBURST_M1;
        end
        else    //When VALID=0, keep the data in the FF.  or  VALID != 0 || state=01/10
        begin
            ARID_reg <= ARID_reg;
            ARADDR_reg <= ARADDR_reg;
            ARLEN_reg <= ARLEN_reg;
            ARSIZE_reg <= ARSIZE_reg;
            ARBURST_reg <= ARBURST_reg;
        end
    end
end

//we have 5 Slave need to distributed

// All Master to Slave0
always_comb begin
    case(Arbiter_ARID_control)      //Using arbiter send the ID control.
        `M0_S0_ID, `M0_default_ID://M0_to_S0
        begin
            ARVALID_S0 = ARVALID_M0;
            ARID_S0     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M0} : ARID_reg;
            ARADDR_S0   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M0 : ARADDR_reg;
            ARLEN_S0    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M0 : ARLEN_reg;
            ARSIZE_S0   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M0 : ARSIZE_reg;
            ARBURST_S0  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M0 : ARBURST_reg;
        end
        //
        `M1_S0_ID, `M1_default_ID://M1_to_S0
        begin
            ARVALID_S0 = ARVALID_M1;
            ARID_S0     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M1} : ARID_reg;
            ARADDR_S0   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M1 : ARADDR_reg;
            ARLEN_S0    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M1 : ARLEN_reg;
            ARSIZE_S0   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M1 : ARSIZE_reg;
            ARBURST_S0  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M1 : ARBURST_reg;
        end
        default:
        begin
            ARVALID_S0 = 1'b0;
			ARID_S0 = 8'b0;
			ARADDR_S0 = 32'b0;
			ARLEN_S0 = 4'b0;
			ARSIZE_S0 = 3'b0;
			ARBURST_S0 = 2'b0;
        end
    endcase
end

// All Master to Slave1
always_comb begin
    case(Arbiter_ARID_control)
        `M0_S1_ID:
        begin
            ARVALID_S1 = ARVALID_M0;
            ARID_S1     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M0} : ARID_reg;
            ARADDR_S1   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M0 : ARADDR_reg;
            ARLEN_S1    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M0 : ARLEN_reg;
            ARSIZE_S1   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M0 : ARSIZE_reg;
            ARBURST_S1  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M0 : ARBURST_reg;
        end
        `M1_S1_ID:
        begin
            ARVALID_S1 = ARVALID_M1;
            ARID_S1     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M1} : ARID_reg;
            ARADDR_S1   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M1 : ARADDR_reg;
            ARLEN_S1    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M1 : ARLEN_reg;
            ARSIZE_S1   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M1 : ARSIZE_reg;
            ARBURST_S1  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M1 : ARBURST_reg;
        end
        default:
        begin
            ARVALID_S1 = 1'b0;
			ARID_S1 = 8'b0;
			ARADDR_S1 = 32'b0;
			ARLEN_S1 = 4'b0;
			ARSIZE_S1 = 3'b0;
			ARBURST_S1 = 2'b0;
        end
    endcase
end

// All Master to Slave2
always_comb begin
    case(Arbiter_ARID_control)
        `M0_S2_ID:
        begin
            ARVALID_S2 = ARVALID_M0;
            ARID_S2     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M0} : ARID_reg;
            ARADDR_S2   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M0 : ARADDR_reg;
            ARLEN_S2    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M0 : ARLEN_reg;
            ARSIZE_S2   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M0 : ARSIZE_reg;
            ARBURST_S2  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M0 : ARBURST_reg;
        end
        `M1_S2_ID:
        begin
            ARVALID_S2 = ARVALID_M1;
            ARID_S2     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M1} : ARID_reg;
            ARADDR_S2   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M1 : ARADDR_reg;
            ARLEN_S2    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M1 : ARLEN_reg;
            ARSIZE_S2   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M1 : ARSIZE_reg;
            ARBURST_S2  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M1 : ARBURST_reg;
        end
        default:
        begin
            ARVALID_S2 = 1'b0;
			ARID_S2 = 8'b0;
			ARADDR_S2 = 32'b0;
			ARLEN_S2 = 4'b0;
			ARSIZE_S2 = 3'b0;
			ARBURST_S2 = 2'b0;
        end
    endcase
end

// All Master to Slave3
always_comb begin
    case(Arbiter_ARID_control)
        `M0_S3_ID:
        begin
            ARVALID_S3 = ARVALID_M0;
            ARID_S3     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M0} : ARID_reg;
            ARADDR_S3   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M0 : ARADDR_reg;
            ARLEN_S3    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M0 : ARLEN_reg;
            ARSIZE_S3   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M0 : ARSIZE_reg;
            ARBURST_S3  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M0 : ARBURST_reg;
        end
        `M1_S3_ID:
        begin
            ARVALID_S3 = ARVALID_M1;
            ARID_S3     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M1} : ARID_reg;
            ARADDR_S3   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M1 : ARADDR_reg;
            ARLEN_S3    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M1 : ARLEN_reg;
            ARSIZE_S3   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M1 : ARSIZE_reg;
            ARBURST_S3  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M1 : ARBURST_reg;
        end
        default:
        begin
            ARVALID_S3 = 1'b0;
			ARID_S3 = 8'b0;
			ARADDR_S3 = 32'b0;
			ARLEN_S3 = 4'b0;
			ARSIZE_S3 = 3'b0;
			ARBURST_S3 = 2'b0;
        end
    endcase
end
// All Master to Slave4
always_comb begin
    case(Arbiter_ARID_control)
        `M0_S4_ID:
        begin
            ARVALID_S4 = ARVALID_M0;
            ARID_S4     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M0} : ARID_reg;
            ARADDR_S4   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M0 : ARADDR_reg;
            ARLEN_S4    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M0 : ARLEN_reg;
            ARSIZE_S4   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M0 : ARSIZE_reg;
            ARBURST_S4  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M0 : ARBURST_reg;
        end
        `M1_S4_ID:
        begin
            ARVALID_S4 = ARVALID_M1;
            ARID_S4     = (Aibiter_Read_State_control == 2'b0)? {4'b0,ARID_M1} : ARID_reg;
            ARADDR_S4   = (Aibiter_Read_State_control == 2'b0)? ARADDR_M1 : ARADDR_reg;
            ARLEN_S4    = (Aibiter_Read_State_control == 2'b0)? ARLEN_M1 : ARLEN_reg;
            ARSIZE_S4   = (Aibiter_Read_State_control == 2'b0)? ARSIZE_M1 : ARSIZE_reg;
            ARBURST_S4  = (Aibiter_Read_State_control == 2'b0)? ARBURST_M1 : ARBURST_reg;
        end
        default:
        begin
            ARVALID_S4 = 1'b0;
			ARID_S4 = 8'b0;
			ARADDR_S4 = 32'b0;
			ARLEN_S4 = 4'b0;
			ARSIZE_S4 = 3'b0;
			ARBURST_S4 = 2'b0;
        end
    endcase
end
///////////////////////////////////



//Slave return ready to Master 
always_comb begin
    case(Arbiter_ARID_control)
        `M0_S0_ID, `M0_default_ID://S0_M0
            ARREADY_M0 = ARREADY_S0;
        `M0_S1_ID:           //S1_M0
            ARREADY_M0 = ARREADY_S1;
        `M0_S2_ID:           //S2_M0
            ARREADY_M0 = ARREADY_S2;
        `M0_S3_ID:           //S3_M0
            ARREADY_M0 = ARREADY_S3;
        `M0_S4_ID:           //S4_M0
            ARREADY_M0 = ARREADY_S4;
        default:
            ARREADY_M0 = 1'b0;
    endcase
end

always_comb begin
    case(Arbiter_ARID_control)
        `M1_S0_ID, `M1_default_ID://S0_M1
            ARREADY_M1 = ARREADY_S0;
        `M1_S1_ID:           //S1_M1
            ARREADY_M1 = ARREADY_S1;
        `M1_S2_ID:           //S2_M1
            ARREADY_M1 = ARREADY_S2;
        `M1_S3_ID:           //S3_M1
            ARREADY_M1 = ARREADY_S3;
        `M1_S4_ID:           //S4_M1
            ARREADY_M1 = ARREADY_S4;
        default:
            ARREADY_M1 = 1'b0;
    endcase
end

endmodule
