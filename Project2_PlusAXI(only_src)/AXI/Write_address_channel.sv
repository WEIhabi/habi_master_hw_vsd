`include "AXI_define.svh"
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
    //S0
    output logic [7:0]   AWID_S0,    //(because have two S IM and DM)
    output logic [31:0]  AWADDR_S0,
    output logic [3:0]   AWLEN_S0,
    output logic [2:0]   AWSIZE_S0,
    output logic [1:0]   AWBURST_S0,
    output logic AWVALID_S0,
    //S1
    output logic [7:0]   AWID_S1,    
    output logic [31:0]  AWADDR_S1,
    output logic [3:0]   AWLEN_S1,
    output logic [2:0]   AWSIZE_S1,
    output logic [1:0]   AWBURST_S1,
    output logic AWVALID_S1,
    //S to M
    input AWREADY_S0,
    input AWREADY_S1,
    output logic AWREADY_M0,
    output logic AWREADY_M1
);
//Two M to two S
logic [7:0]  AWID_S0_reg,AWID_S1_reg;
logic [31:0] AWADDR_S0_reg,AWADDR_S1_reg;
logic [3:0]  AWLEN_S0_reg,AWLEN_S1_reg;
logic [2:0]  AWSIZE_S0_reg,AWSIZE_S1_reg;
logic [1:0]  AWBURST_S0_reg,AWBURST_S1_reg;

always_ff @ (posedge ACLK or negedge ARESETn) begin
    if(!ARESETn)
    begin
        AWID_S0_reg <= 8'b0;
        AWID_S1_reg <= 8'b0;
        AWADDR_S0_reg <= 32'b0;
        AWADDR_S1_reg <= 32'b0;
        AWLEN_S0_reg <= 4'b0;
        AWLEN_S1_reg <= 4'b0;
        AWSIZE_S0_reg <= 3'b0;
        AWSIZE_S1_reg <= 3'b0;
        AWBURST_S0_reg <= 2'b0;
        AWBURST_S1_reg <= 2'b0;
    end
    else
    begin
        if (AWVALID_M0 && Aibiter_Write_State_control == 2'b00) 
        begin
            AWID_S0_reg <= {4'b0,AWID_M0};
            AWID_S1_reg <= {4'b0,AWID_M0};
            AWADDR_S0_reg <= AWADDR_M0;
            AWADDR_S1_reg <= AWADDR_M0;
            AWLEN_S0_reg <= AWLEN_M0;
            AWLEN_S1_reg <= AWLEN_M0;
            AWSIZE_S0_reg <= AWSIZE_M0;
            AWSIZE_S1_reg <= AWSIZE_M0;
            AWBURST_S0_reg <= AWBURST_M0;
            AWBURST_S1_reg <= AWBURST_M0;
        end
        else if(AWVALID_M1 && Aibiter_Write_State_control == 2'b00)
        begin
            AWID_S0_reg <= {4'b0,AWID_M1};
            AWID_S1_reg <= {4'b0,AWID_M1};
            AWADDR_S0_reg <= AWADDR_M1;
            AWADDR_S1_reg <= AWADDR_M1;
            AWLEN_S0_reg <= AWLEN_M1;
            AWLEN_S1_reg <= AWLEN_M1;
            AWSIZE_S0_reg <= AWSIZE_M1;
            AWSIZE_S1_reg <= AWSIZE_M1;
            AWBURST_S0_reg <= AWBURST_M1;
            AWBURST_S1_reg <= AWBURST_M1;
        end
        else    //When VALID=0, keep the data in the FF.  or  VALID != 0 || state=01/10
        begin
            AWID_S0_reg <= AWID_S0_reg;
            AWID_S1_reg <= AWID_S1_reg;
            AWADDR_S0_reg <= AWADDR_S0_reg;
            AWADDR_S1_reg <= AWADDR_S1_reg;
            AWLEN_S0_reg <= AWLEN_S0_reg;
            AWLEN_S1_reg <= AWLEN_S1_reg;
            AWSIZE_S0_reg <= AWSIZE_S0_reg;
            AWSIZE_S1_reg <= AWSIZE_S1_reg;
            AWBURST_S0_reg <= AWBURST_S0_reg;
            AWBURST_S1_reg <= AWBURST_S1_reg;
        end
    end
end



always_comb begin
    case(Arbiter_AWID_control)      //Using AWbiter send the ID control.
        4'b0001, 4'b0100://M0_to_S0
        begin
            AWVALID_S0 = AWVALID_M0;
            AWVALID_S1 = 1'b0;
            if(Aibiter_Write_State_control == 2'b0)
            begin
                AWID_S0     = {4'b0,AWID_M0};
                AWID_S1     = 8'b0;
                AWADDR_S0   = AWADDR_M0;
                AWADDR_S1   = 32'b0;
                AWLEN_S0    = AWLEN_M0;
                AWLEN_S1    = 4'b0;
                AWSIZE_S0   = AWSIZE_M0;
                AWSIZE_S1   = 3'b0;
                AWBURST_S0  = AWBURST_M0;
                AWBURST_S1  = 2'b0; 
            end
            else
            begin//when state != 2'b00
                AWID_S0 = AWID_S0_reg;
                AWID_S1 = AWID_S1_reg;
                AWADDR_S0 = AWADDR_S0_reg;
                AWADDR_S1 = AWADDR_S1_reg;
                AWLEN_S0 = AWLEN_S0_reg;
                AWLEN_S1 = AWLEN_S1_reg;
                AWSIZE_S0 = AWSIZE_S0_reg;
                AWSIZE_S1 = AWSIZE_S1_reg;
                AWBURST_S0 = AWBURST_S0_reg;
                AWBURST_S1 = AWBURST_S1_reg;
            end
        end
        //
        4'b1001, 4'b1100://M1_to_S0
        begin
            AWVALID_S0 = AWVALID_M1;
            AWVALID_S1 = 1'b0;
            if(Aibiter_Write_State_control == 2'b0)
            begin
                AWID_S0     = {4'b0,AWID_M1};
                AWID_S1     = 8'b0;
                AWADDR_S0   = AWADDR_M1;
                AWADDR_S1   = 32'b0;
                AWLEN_S0    = AWLEN_M1;
                AWLEN_S1    = 4'b0;
                AWSIZE_S0   = AWSIZE_M1;
                AWSIZE_S1   = 3'b0;
                AWBURST_S0  = AWBURST_M1;
                AWBURST_S1  = 2'b0; 
            end
            else
            begin
                AWID_S0 = AWID_S0_reg;
                AWID_S1 = AWID_S1_reg;
                AWADDR_S0 = AWADDR_S0_reg;
                AWADDR_S1 = AWADDR_S1_reg;
                AWLEN_S0 = AWLEN_S0_reg;
                AWLEN_S1 = AWLEN_S1_reg;
                AWSIZE_S0 = AWSIZE_S0_reg;
                AWSIZE_S1 = AWSIZE_S1_reg;
                AWBURST_S0 = AWBURST_S0_reg;
                AWBURST_S1 = AWBURST_S1_reg;
            end
        end
        4'b0010://M0_to_S1
        begin
            AWVALID_S0 = 1'b0;
            AWVALID_S1 = AWVALID_M0;
            if(Aibiter_Write_State_control == 2'b0)
            begin
                AWID_S0     = 8'b0;
                AWID_S1     = {4'b0,AWID_M0};
                AWADDR_S0   = 32'b0;
                AWADDR_S1   = AWADDR_M0;
                AWLEN_S0    = 4'b0;
                AWLEN_S1    = AWLEN_M0;
                AWSIZE_S0   = 3'b0;
                AWSIZE_S1   = AWSIZE_M0;
                AWBURST_S0  = 2'b0;
                AWBURST_S1  = AWBURST_M0;
            end
            else
            begin
                AWID_S0 = AWID_S0_reg;
                AWID_S1 = AWID_S1_reg;
                AWADDR_S0 = AWADDR_S0_reg;
                AWADDR_S1 = AWADDR_S1_reg;
                AWLEN_S0 = AWLEN_S0_reg;
                AWLEN_S1 = AWLEN_S1_reg;
                AWSIZE_S0 = AWSIZE_S0_reg;
                AWSIZE_S1 = AWSIZE_S1_reg;
                AWBURST_S0 = AWBURST_S0_reg;
                AWBURST_S1 = AWBURST_S1_reg;
            end
        end
        4'b1010://M1_to_S1
        begin
            AWVALID_S0 = 1'b0;
            AWVALID_S1 = AWVALID_M1;
            if(Aibiter_Write_State_control == 2'b0)
            begin
                AWID_S0     = 8'b0;
                AWID_S1     = {4'b0,AWID_M1};
                AWADDR_S0   = 32'b0;
                AWADDR_S1   = AWADDR_M1;
                AWLEN_S0    = 4'b0;
                AWLEN_S1    = AWLEN_M1;
                AWSIZE_S0   = 3'b0;
                AWSIZE_S1   = AWSIZE_M1;
                AWBURST_S0  = 2'b0;
                AWBURST_S1  = AWBURST_M1;
            end
            else
            begin
                AWID_S0 = AWID_S0_reg;
                AWID_S1 = AWID_S1_reg;
                AWADDR_S0 = AWADDR_S0_reg;
                AWADDR_S1 = AWADDR_S1_reg;
                AWLEN_S0 = AWLEN_S0_reg;
                AWLEN_S1 = AWLEN_S1_reg;
                AWSIZE_S0 = AWSIZE_S0_reg;
                AWSIZE_S1 = AWSIZE_S1_reg;
                AWBURST_S0 = AWBURST_S0_reg;
                AWBURST_S1 = AWBURST_S1_reg;
            end
        end
/*
        4'b0100, 4'b1100:   //remind send RRESP ==2'b11(DECERR)
        begin
            AWVALID_S0 = 1'b0;
            AWVALID_S1 = 1'b0;
            AWID_S0 <= 8'b0;
            AWID_S1 <= 8'b0;
            AWADDR_S0 <= 32'b0;
            AWADDR_S1 <= 32'b0;
            AWLEN_S0 <= 4'b0;
            AWLEN_S1 <= 4'b0;
            AWSIZE_S0 <= 3'b0;
            AWSIZE_S1 <= 3'b0;
            AWBURST_S0 <= 2'b0;
            AWBURST_S1 <= 2'b0;
        end
*/
        default://Should not come here(No this AWbiter_AWID_control!!)
        begin
            AWVALID_S0 = 1'b0;
            AWVALID_S1 = 1'b0;
            AWID_S0 = 8'b0;
            AWID_S1 = 8'b0;
            AWADDR_S0 = 32'b0;
            AWADDR_S1 = 32'b0;
            AWLEN_S0 = 4'b0;
            AWLEN_S1 = 4'b0;
            AWSIZE_S0 = 3'b0;
            AWSIZE_S1 = 3'b0;
            AWBURST_S0 = 2'b0;
            AWBURST_S1 = 2'b0;
        end
    endcase
end


//S to M 
always_comb begin
    case(Arbiter_AWID_control)
        4'b0001, 4'b0100://S0_M0
        begin
            AWREADY_M0 = AWREADY_S0;
            AWREADY_M1 = 1'b0;
        end
        4'b1001, 4'b1100://S0_M1
        begin
            AWREADY_M0 = 1'b0;
            AWREADY_M1 = AWREADY_S0;
        end
        4'b0010://S1_M0
        begin
            AWREADY_M0 = AWREADY_S1;
            AWREADY_M1 = 1'b0;
        end
        4'b1010://S1_M1
        begin
            AWREADY_M0 = 1'b0;
            AWREADY_M1 = AWREADY_S1;
        end
/*
        4'b0100, 4'b1100:
        begin
            AWREADY_M0 = 1'b0;
            AWREADY_M1 = 1'b0;
        end
*/
        default:
        begin
            AWREADY_M0 = 1'b0;
            AWREADY_M1 = 1'b0;
        end
    endcase
end


endmodule
