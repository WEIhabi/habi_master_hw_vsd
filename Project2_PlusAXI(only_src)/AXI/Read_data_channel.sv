`include "AXI_define.svh"

module Read_data_channel(
    //Global Signals
    input ACLK,
	input ARESETn,
    //Arbiter control
    input [1:0] Aibiter_Read_State_control,
    input [3:0] Arbiter_ARID_control,  
    //S to M
    //S0
    input [7:0]   RID_S0,       
    input [31:0]  RDATA_S0,
    input [1:0]   RRESP_S0,     
    // The RESP of read Data is contained in its own channel
    // not like write data channel has write response channel to use 
    input RLAST_S0,
    input RVALID_S0,
    //S1
    input [7:0]   RID_S1,       
    input [31:0]  RDATA_S1,
    input [1:0]   RRESP_S1,     
    input RLAST_S1,
    input RVALID_S1,
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
    output logic RREADY_S1
);
//Two Ms to two slaves

logic [`AXI_ID_BITS-1:0]   RID_M0_reg, RID_M1_reg;
logic [`AXI_DATA_BITS-1:0] RDATA_M0_reg, RDATA_M1_reg;
logic [1:0]                RRESP_M0_reg, RRESP_M1_reg;
logic                      RLAST_M0_reg, RLAST_M1_reg;

always_ff @(posedge ACLK or negedge ARESETn) begin
   if(!ARESETn)
   begin
        RID_M0_reg   <= 4'b0;
        RID_M1_reg   <= 4'b0;
        RDATA_M0_reg <= 32'b0;
        RDATA_M1_reg <= 32'b0;
        RRESP_M0_reg <= 2'b0;
        RRESP_M1_reg <= 2'b0;
        RLAST_M0_reg <= 1'b0;
        RLAST_M1_reg <= 1'b0;
   end
   else
   begin
       if(RVALID_S0 && Aibiter_Read_State_control == 2'b0)
       begin
            RID_M0_reg   <= RID_S0[3:0];
            RID_M1_reg   <= RID_S0[3:0];
            RDATA_M0_reg <= RDATA_S0;
            RDATA_M1_reg <= RDATA_S0;
            RRESP_M0_reg <= RRESP_S0;
            RRESP_M1_reg <= RRESP_S0;
            RLAST_M0_reg <= RLAST_S0;
            RLAST_M1_reg <= RLAST_S0;
       end
       else if(RVALID_S1 && Aibiter_Read_State_control == 2'b0)
       begin
            RID_M0_reg   <= RID_S1[3:0];
            RID_M1_reg   <= RID_S1[3:0];
            RDATA_M0_reg <= RDATA_S1;
            RDATA_M1_reg <= RDATA_S1;
            RRESP_M0_reg <= RRESP_S1;
            RRESP_M1_reg <= RRESP_S1;
            RLAST_M0_reg <= RLAST_S1;
            RLAST_M1_reg <= RLAST_S1;
       end
       else
       begin
            RID_M0_reg   <= RID_M0_reg;
            RID_M1_reg   <= RID_M1_reg;
            RDATA_M0_reg <= RDATA_M0_reg;
            RDATA_M1_reg <= RDATA_M1_reg;
            RRESP_M0_reg <= RRESP_M0_reg;
            RRESP_M1_reg <= RRESP_M1_reg;
            RLAST_M0_reg <= RLAST_M0_reg;
            RLAST_M1_reg <= RLAST_M1_reg;
       end
   end
end



always_comb begin
    case(Arbiter_ARID_control)
        4'b0001://M0_to_S0
        begin
            RVALID_M0 = RVALID_S0;
            RVALID_M1 = 1'b0;
            if(RVALID_S0)
            begin
                RID_M0     = RID_S0[3:0];
                RID_M1     = 4'b0;
                RDATA_M0   = RDATA_S0;
                RDATA_M1   = 32'b0;
                RRESP_M0   = RRESP_S0;
                RRESP_M1   = 2'b10;//RESP_SLVERR
                RLAST_M0   = RLAST_S0;
                RLAST_M1   = 1'b0;
            end
            else
            begin//when state != 2'b00
                RID_M0 = RID_M0_reg;
                RID_M1 = RID_M1_reg;
                RDATA_M0 = RDATA_M0_reg;
                RDATA_M1 = RDATA_M1_reg;
                RRESP_M0 = RRESP_M0_reg;
                RRESP_M1 = 2'b10;//RESP_SLVERR
                RLAST_M0 = RLAST_M0_reg;
                RLAST_M1 = RLAST_M1_reg;
            end
        end
        4'b0010://M0_to_S1
        begin
            RVALID_M0 = RVALID_S1;
            RVALID_M1 = 1'b0;
            //
            if(RVALID_S1)
            begin
                RID_M0     = RID_S1[3:0];
                RID_M1     = 4'b0;
                RDATA_M0   = RDATA_S1;
                RDATA_M1   = 32'b0;
                RRESP_M0   = RRESP_S1;
                RRESP_M1   = 2'b10;//RESP_SLVERR
                RLAST_M0   = RLAST_S1;
                RLAST_M1   = 1'b0;
            end
            else
            begin
                RID_M0 = RID_M0_reg;
                RID_M1 = RID_M1_reg;
                RDATA_M0 = RDATA_M0_reg;
                RDATA_M1 = RDATA_M1_reg;
                RRESP_M0 = RRESP_M0_reg;
                RRESP_M1 = 2'b10;//RESP_SLVERR
                RLAST_M0 = RLAST_M0_reg;
                RLAST_M1 = RLAST_M1_reg;
            end           
        end
        4'b1001://M1_to_S0
        begin
            RVALID_M0 = 1'b0;
            RVALID_M1 = RVALID_S0;
            if(RVALID_S0)
            begin
                RID_M0     = 4'b0;
                RID_M1     = RID_S0[3:0];
                RDATA_M0   = 32'b0;
                RDATA_M1   = RDATA_S0;
                RRESP_M0   = 2'b10;//RESP_SLVERR
                RRESP_M1   = RRESP_S0;
                RLAST_M0   = 1'b0;
                RLAST_M1   = RLAST_S0;
            end
            else
            begin
                RID_M0 = RID_M0_reg;
                RID_M1 = RID_M1_reg;
                RDATA_M0 = RDATA_M0_reg;
                RDATA_M1 = RDATA_M1_reg;
                RRESP_M0 = 2'b10;//RESP_SLVERR
                RRESP_M1 = RRESP_M1_reg;
                RLAST_M0 = RLAST_M0_reg;
                RLAST_M1 = RLAST_M1_reg;
            end
            
        end
        4'b1010://M1_to_S1
        begin
            RVALID_M0 = 1'b0;
            RVALID_M1 = RVALID_S1;
            if(RVALID_S1)
            begin
                RID_M0     = 4'b0;
                RID_M1     = RID_S1[3:0];
                RDATA_M0   = 32'b0;
                RDATA_M1   = RDATA_S1;
                RRESP_M0    = 2'b10;//RESP_SLVERR
                RRESP_M1    = RRESP_S1;
                RLAST_M0   = 1'b0;
                RLAST_M1   = RLAST_S1;
            end
            else
            begin
                RID_M0 = RID_M0_reg;
                RID_M1 = RID_M1_reg;
                RDATA_M0 = RDATA_M0_reg;
                RDATA_M1 = RDATA_M1_reg;
                RRESP_M0 = 2'b10;//RESP_SLVERR
                RRESP_M1 = RRESP_M1_reg;
                RLAST_M0 = RLAST_M0_reg;
                RLAST_M1 = RLAST_M1_reg;
            end
        end

        4'b0100://M0_to_Default_slave
        begin
            RVALID_M0 = RVALID_S0;
            RVALID_M1 = 1'b0;
            if(RVALID_S0)
            begin
                RID_M0 = RID_S0[3:0];
                RID_M1 = 4'b0;
                RDATA_M0 = RDATA_S0;
                RDATA_M1 = 32'b0;
                RRESP_M0 = 2'b11;//DECERR
                RRESP_M1 = 2'b10;//RESP_SLVERR
                RLAST_M0 = RLAST_S0;;
                RLAST_M1 = 1'b0;
            end
            else
            begin
                RID_M0 = RID_M0_reg;
                RID_M1 = RID_M1_reg;
                RDATA_M0 = RDATA_M0_reg;
                RDATA_M1 = RDATA_M1_reg;
                RRESP_M0 = 2'b11;//DECERR
                RRESP_M1 = 2'b10;//RESP_SLVERR
                RLAST_M0 = RLAST_M0_reg;
                RLAST_M1 = RLAST_M1_reg;
            end
            
        end
        4'b1100://M1_to_Default_slave
        begin
            RVALID_M0 = 1'b0;
            RVALID_M1 = RVALID_S0;
            if(RVALID_S0)
            begin
                RID_M0 = 4'b0;
                RID_M1 = RID_S0[3:0];
                RDATA_M0 = 32'b0;
                RDATA_M1 = RDATA_S0;
                RRESP_M0 = 2'b10;//RESP_SLVERR
                RRESP_M1 = 2'b11;//DECERR
                RLAST_M0 = 1'b0;
                RLAST_M1 = RLAST_S0;
            end
            else
            begin
                RID_M0 = RID_M0_reg;
                RID_M1 = RID_M1_reg;
                RDATA_M0 = RDATA_M0_reg;
                RDATA_M1 = RDATA_M1_reg;
                RRESP_M0 = 2'b10;//RESP_SLVERR
                RRESP_M1 = 2'b11;//DECERR
                RLAST_M0 = RLAST_M0_reg;
                RLAST_M1 = RLAST_M1_reg;
            end
            
        end

        default://Should not come here(No this Arbiter_AWID_control!!)
        begin
            RVALID_M0 = 1'b0;
            RVALID_M1 = 1'b0;
            RID_M0 = 4'b0;
            RID_M1 = 4'b0;
            RDATA_M0 = 32'b0;
            RDATA_M1 = 32'b0;
            RRESP_M0 = 2'b11;
            RRESP_M1 = 2'b11;
            RLAST_M0 = 1'b0;
            RLAST_M1 = 1'b0;
        end
    endcase
end
/////////////////////////////////////////
//M(SRAM) to S(CPU)
always_comb begin
    case(Arbiter_ARID_control)
        4'b0001, 4'b0100://M0_S0
        begin
            RREADY_S0 = RREADY_M0;
            RREADY_S1 = 1'b0;
        end
        4'b1001, 4'b1100://M1_S0
        begin
            RREADY_S0 = RREADY_M1;
            RREADY_S1 = 1'b0;
        end
        4'b0010://M0_S1
        begin
            RREADY_S0 = 1'b0;
            RREADY_S1 = RREADY_M0;
        end
        4'b1010://M1_S1
        begin
            RREADY_S0 = 1'b0;
            RREADY_S1 = RREADY_M1;
        end
        default:
        begin
            RREADY_S0 = 1'b0;
            RREADY_S1 = 1'b0;
        end
    endcase
end


endmodule
