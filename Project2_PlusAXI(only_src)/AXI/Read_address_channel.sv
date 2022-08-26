`include "AXI_define.svh"
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
    //Burst length: ARLEN[3:0] and AWLEN[3:0] indicate this
    //The inside of a burst cannot be interrupted.
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
    //S0
    output logic [7:0]   ARID_S0,    //(because have two S IM and DM)
    output logic [31:0]  ARADDR_S0,
    output logic [3:0]   ARLEN_S0,
    output logic [2:0]   ARSIZE_S0,
    output logic [1:0]   ARBURST_S0,
    output logic ARVALID_S0,
    //S1
    output logic [7:0]   ARID_S1,    
    output logic [31:0]  ARADDR_S1,
    output logic [3:0]   ARLEN_S1,
    output logic [2:0]   ARSIZE_S1,
    output logic [1:0]   ARBURST_S1,
    output logic ARVALID_S1,
    //S to M
    input ARREADY_S0,
    input ARREADY_S1,
    output logic ARREADY_M0,
    output logic ARREADY_M1
    );
//Two Masters to two Slaves

logic [7:0]  ARID_S0_reg,ARID_S1_reg;
logic [31:0] ARADDR_S0_reg,ARADDR_S1_reg;
logic [3:0]  ARLEN_S0_reg,ARLEN_S1_reg;
logic [2:0]  ARSIZE_S0_reg,ARSIZE_S1_reg;
logic [1:0]  ARBURST_S0_reg,ARBURST_S1_reg;

//M to S
always_ff @ (posedge ACLK or negedge ARESETn) begin
    if(!ARESETn)
    begin
        ARID_S0_reg <= 8'b0;
        ARID_S1_reg <= 8'b0;
        ARADDR_S0_reg <= 32'b0;
        ARADDR_S1_reg <= 32'b0;
        ARLEN_S0_reg <= 4'b0;
        ARLEN_S1_reg <= 4'b0;
        ARSIZE_S0_reg <= 3'b0;
        ARSIZE_S1_reg <= 3'b0;
        ARBURST_S0_reg <= 2'b0;
        ARBURST_S1_reg <= 2'b0;
    end
    else
    begin
        if (ARVALID_M0 && Aibiter_Read_State_control == 2'b00) 
        begin
            ARID_S0_reg <= {4'b0,ARID_M0};
            ARID_S1_reg <= {4'b0,ARID_M0};
            ARADDR_S0_reg <= ARADDR_M0;
            ARADDR_S1_reg <= ARADDR_M0;
            ARLEN_S0_reg <= ARLEN_M0;
            ARLEN_S1_reg <= ARLEN_M0;
            ARSIZE_S0_reg <= ARSIZE_M0;
            ARSIZE_S1_reg <= ARSIZE_M0;
            ARBURST_S0_reg <= ARBURST_M0;
            ARBURST_S1_reg <= ARBURST_M0;
        end
        else if(ARVALID_M1 && Aibiter_Read_State_control == 2'b00)
        begin
            ARID_S0_reg <= {4'b0,ARID_M1};
            ARID_S1_reg <= {4'b0,ARID_M1};
            ARADDR_S0_reg <= ARADDR_M1;
            ARADDR_S1_reg <= ARADDR_M1;
            ARLEN_S0_reg <= ARLEN_M1;
            ARLEN_S1_reg <= ARLEN_M1;
            ARSIZE_S0_reg <= ARSIZE_M1;
            ARSIZE_S1_reg <= ARSIZE_M1;
            ARBURST_S0_reg <= ARBURST_M1;
            ARBURST_S1_reg <= ARBURST_M1;
        end
        else    //When VALID=0, keep the data in the FF.  or  VALID != 0 || state=01/10
        begin
            ARID_S0_reg <= ARID_S0_reg;
            ARID_S1_reg <= ARID_S1_reg;
            ARADDR_S0_reg <= ARADDR_S0_reg;
            ARADDR_S1_reg <= ARADDR_S1_reg;
            ARLEN_S0_reg <= ARLEN_S0_reg;
            ARLEN_S1_reg <= ARLEN_S1_reg;
            ARSIZE_S0_reg <= ARSIZE_S0_reg;
            ARSIZE_S1_reg <= ARSIZE_S1_reg;
            ARBURST_S0_reg <= ARBURST_S0_reg;
            ARBURST_S1_reg <= ARBURST_S1_reg;
        end
    end
end



always_comb begin
    case(Arbiter_ARID_control)      //Using arbiter send the ID control.
        4'b0001,4'b0100://M0_to_S0
        begin
            ARVALID_S0 = ARVALID_M0;
            ARVALID_S1 = 1'b0;
            if(Aibiter_Read_State_control == 2'b0)
            begin
                ARID_S0     = {4'b0,ARID_M0};
                ARID_S1     = 8'b0;
                ARADDR_S0   = ARADDR_M0;
                ARADDR_S1   = 32'b0;
                ARLEN_S0    = ARLEN_M0;
                ARLEN_S1    = 4'b0;
                ARSIZE_S0   = ARSIZE_M0;
                ARSIZE_S1   = 3'b0;
                ARBURST_S0  = ARBURST_M0;
                ARBURST_S1  = 2'b0; 
            end
            else
            begin//when state != 2'b00
                ARID_S0 = ARID_S0_reg;
                ARID_S1 = ARID_S1_reg;
                ARADDR_S0 = ARADDR_S0_reg;
                ARADDR_S1 = ARADDR_S1_reg;
                ARLEN_S0 = ARLEN_S0_reg;
                ARLEN_S1 = ARLEN_S1_reg;
                ARSIZE_S0 = ARSIZE_S0_reg;
                ARSIZE_S1 = ARSIZE_S1_reg;
                ARBURST_S0 = ARBURST_S0_reg;
                ARBURST_S1 = ARBURST_S1_reg;
            end
        end
        //
        4'b1001, 4'b1100://M1_to_S0
        begin
            ARVALID_S0 = ARVALID_M1;
            ARVALID_S1 = 1'b0;
            if(Aibiter_Read_State_control == 2'b0)
            begin
                ARID_S0     = {4'b0,ARID_M1};
                ARID_S1     = 8'b0;
                ARADDR_S0   = ARADDR_M1;
                ARADDR_S1   = 32'b0;
                ARLEN_S0    = ARLEN_M1;
                ARLEN_S1    = 4'b0;
                ARSIZE_S0   = ARSIZE_M1;
                ARSIZE_S1   = 3'b0;
                ARBURST_S0  = ARBURST_M1;
                ARBURST_S1  = 2'b0; 
            end
            else
            begin
                ARID_S0 = ARID_S0_reg;
                ARID_S1 = ARID_S1_reg;
                ARADDR_S0 = ARADDR_S0_reg;
                ARADDR_S1 = ARADDR_S1_reg;
                ARLEN_S0 = ARLEN_S0_reg;
                ARLEN_S1 = ARLEN_S1_reg;
                ARSIZE_S0 = ARSIZE_S0_reg;
                ARSIZE_S1 = ARSIZE_S1_reg;
                ARBURST_S0 = ARBURST_S0_reg;
                ARBURST_S1 = ARBURST_S1_reg;
            end
        end
        4'b0010://M0_to_S1
        begin
            ARVALID_S0 = 1'b0;
            ARVALID_S1 = ARVALID_M0;
            if(Aibiter_Read_State_control == 2'b0)
            begin
                ARID_S0     = 8'b0;
                ARID_S1     = {4'b0,ARID_M0};
                ARADDR_S0   = 32'b0;
                ARADDR_S1   = ARADDR_M0;
                ARLEN_S0    = 4'b0;
                ARLEN_S1    = ARLEN_M0;
                ARSIZE_S0   = 3'b0;
                ARSIZE_S1   = ARSIZE_M0;
                ARBURST_S0  = 2'b0;
                ARBURST_S1  = ARBURST_M0;
            end
            else
            begin
                ARID_S0 = ARID_S0_reg;
                ARID_S1 = ARID_S1_reg;
                ARADDR_S0 = ARADDR_S0_reg;
                ARADDR_S1 = ARADDR_S1_reg;
                ARLEN_S0 = ARLEN_S0_reg;
                ARLEN_S1 = ARLEN_S1_reg;
                ARSIZE_S0 = ARSIZE_S0_reg;
                ARSIZE_S1 = ARSIZE_S1_reg;
                ARBURST_S0 = ARBURST_S0_reg;
                ARBURST_S1 = ARBURST_S1_reg;
            end
        end
        4'b1010://M1_to_S1
        begin
            ARVALID_S0 = 1'b0;
            ARVALID_S1 = ARVALID_M1;
            if(Aibiter_Read_State_control == 2'b0)
            begin
                ARID_S0     = 8'b0;
                ARID_S1     = {4'b0,ARID_M1};
                ARADDR_S0   = 32'b0;
                ARADDR_S1   = ARADDR_M1;
                ARLEN_S0    = 4'b0;
                ARLEN_S1    = ARLEN_M1;
                ARSIZE_S0   = 3'b0;
                ARSIZE_S1   = ARSIZE_M1;
                ARBURST_S0  = 2'b0;
                ARBURST_S1  = ARBURST_M1;
            end
            else
            begin
                ARID_S0 = ARID_S0_reg;
                ARID_S1 = ARID_S1_reg;
                ARADDR_S0 = ARADDR_S0_reg;
                ARADDR_S1 = ARADDR_S1_reg;
                ARLEN_S0 = ARLEN_S0_reg;
                ARLEN_S1 = ARLEN_S1_reg;
                ARSIZE_S0 = ARSIZE_S0_reg;
                ARSIZE_S1 = ARSIZE_S1_reg;
                ARBURST_S0 = ARBURST_S0_reg;
                ARBURST_S1 = ARBURST_S1_reg;
            end
        end
/*
        4'b0100, 4'b1100:   //remind send RRESP ==2'b11(DECERR)
        begin
            ARVALID_S0 = 1'b0;
            ARVALID_S1 = 1'b0;
            ARID_S0 <= 8'b0;
            ARID_S1 <= 8'b0;
            ARADDR_S0 <= 32'b0;
            ARADDR_S1 <= 32'b0;
            ARLEN_S0 <= 4'b0;
            ARLEN_S1 <= 4'b0;
            ARSIZE_S0 <= 3'b0;
            ARSIZE_S1 <= 3'b0;
            ARBURST_S0 <= 2'b0;
            ARBURST_S1 <= 2'b0;
        end
*/
        default://Should not come here(No this Arbiter_ARID_control!!)
        begin
            ARVALID_S0 = 1'b0;
            ARVALID_S1 = 1'b0;
            ARID_S0 = 8'b0;
            ARID_S1 = 8'b0;
            ARADDR_S0 = 32'b0;
            ARADDR_S1 = 32'b0;
            ARLEN_S0 = 4'b0;
            ARLEN_S1 = 4'b0;
            ARSIZE_S0 = 3'b0;
            ARSIZE_S1 = 3'b0;
            ARBURST_S0 = 2'b0;
            ARBURST_S1 = 2'b0;
        end
    endcase
end


//S to M 
always_comb begin
    case(Arbiter_ARID_control)
        4'b0001, 4'b0100://S0_M0
        begin
            ARREADY_M0 = ARREADY_S0;
            ARREADY_M1 = 1'b0;
        end
        4'b1001, 4'b1100://S0_M1
        begin
            ARREADY_M0 = 1'b0;
            ARREADY_M1 = ARREADY_S0;
        end
        4'b0010://S1_M0
        begin
            ARREADY_M0 = ARREADY_S1;
            ARREADY_M1 = 1'b0;
        end
        4'b1010://S1_M1
        begin
            ARREADY_M0 = 1'b0;
            ARREADY_M1 = ARREADY_S1;
        end
        default:
        begin
            ARREADY_M0 = 1'b0;
            ARREADY_M1 = 1'b0;
        end
    endcase
end

endmodule
