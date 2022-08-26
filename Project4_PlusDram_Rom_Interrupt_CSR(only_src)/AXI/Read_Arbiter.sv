`include "AXI_define.svh"
`include "bus_define.svh"
module Read_Arbiter(
    //Global Signals
    input ACLK,
	input ARESETn,
    //read address
    input [31:0]  ARADDR_M0,   //addr
    input [31:0]  ARADDR_M1,
    input ARVALID_M0,          //valid
    input ARVALID_M1,
    //
    input RVALID_M0,           
    input RVALID_M1,
    input RREADY_M0,
    input RREADY_M1,
    //
    input ARREADY_M0,
    input ARREADY_M1,
    input [3:0] ARLEN_M0,
    input RLAST_M0,
    input [3:0] ARLEN_M1,
    input RLAST_M1,
    //
    output logic [1:0] Aibiter_Read_State_control,
    output logic [3:0] Arbiter_ARID_control   //add ID bit to slave
);
//Two Master to two slaves

logic [31:0] ARADDR_regtemp;
logic [3:0] ARLEN_M0_reg, ARLEN_M1_reg;

////////
//for burst to keep M0_len
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) 
    begin
        ARLEN_M0_reg <= 4'd0;
    end 
	else 
	begin
		if(ARVALID_M0 && ARREADY_M0)	
            		ARLEN_M0_reg <= ARLEN_M0;
		else
            		ARLEN_M0_reg <= ARLEN_M0_reg;
	end
end
//for burst to keep M1_len
always_ff @(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) 
    begin
        ARLEN_M1_reg <= 4'd0;
    end 
	else 
	begin
		if(ARVALID_M1 && ARREADY_M1)	
            		ARLEN_M1_reg <= ARLEN_M1;
		else
            		ARLEN_M1_reg <= ARLEN_M1_reg;
	end
end

//state machine control
always_ff @(posedge ACLK or negedge ARESETn) 
begin
    if(!ARESETn)
    begin
        Aibiter_Read_State_control <= 2'b00;//only after rst or prestate is read data, control ==2'b00
    end
    //Indicates that the read address of the previous stage was successful, because RVALID has to wait for (ARVALID＆＆ARREADY)=1 before it will be pulled to 1
    //Do the state machine all over again
    else if((RVALID_M0 && RREADY_M0 && RLAST_M0) || (RVALID_M1 && RREADY_M1 && RLAST_M1))//maybe have to add Rlast(after added burst)
        Aibiter_Read_State_control <= 2'b00;
    else if(Aibiter_Read_State_control == 2'b00)
    begin
        case({ARVALID_M0,ARVALID_M1})     //polling arbiter
            2'b00:Aibiter_Read_State_control <= 2'b00;
            2'b01:Aibiter_Read_State_control <= 2'b10;   //M1 is 1,next M0 is 1.
            default:Aibiter_Read_State_control <= 2'b01; //default( (M0=1 & M1=1) or (M0=1 & M1=0))
	  endcase
    end
    else Aibiter_Read_State_control <= Aibiter_Read_State_control;
end

always_ff @ (posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) ARADDR_regtemp <= 32'd0;
    else begin
		if (ARVALID_M0 && Aibiter_Read_State_control == 2'b00) ARADDR_regtemp <= ARADDR_M0;
		else if (ARVALID_M1 && Aibiter_Read_State_control == 2'b00) ARADDR_regtemp <= ARADDR_M1;
		else ARADDR_regtemp <= ARADDR_regtemp;      //Keep the address when Slave is busy.
    end
end

//HW3 distribute Master to Slave
always_comb begin
    case(Aibiter_Read_State_control)
        2'b00:
        begin
            if(ARVALID_M0)
            begin
                if(ARADDR_M0 [31:16] == 16'h0000)        //ROM                                
                    Arbiter_ARID_control = `M0_S0_ID;
                else if(ARADDR_M0  [31:16] == 16'h0001)   //IM
                    Arbiter_ARID_control = `M0_S1_ID;
                else if(ARADDR_M0  [31:16] == 16'h0002)   //DM
                    Arbiter_ARID_control = `M0_S2_ID;
                else if (ARADDR_M0 [31:10] == 22'b0001_0000_0000_0000_0000_00)//sensor ctrl
                    Arbiter_ARID_control = `M0_S3_ID;      
                else if (ARADDR_M0 [31:21] == 11'b0010_0000_000)//DRAM              
                    Arbiter_ARID_control = `M0_S4_ID;
                else
                Arbiter_ARID_control = `M0_default_ID;
            end
            //
            else if(ARVALID_M1)
            begin
                if(ARADDR_M1 [31:16] == 16'h0000)        //ROM                                
                    Arbiter_ARID_control = `M1_S0_ID;
                else if(ARADDR_M1 [31:16] == 16'h0001)   //IM
                    Arbiter_ARID_control = `M1_S1_ID;
                else if(ARADDR_M1 [31:16] == 16'h0002)   //DM
                    Arbiter_ARID_control = `M1_S2_ID;
                else if (ARADDR_M1 [31:10] == 22'b0001_0000_0000_0000_0000_00)//sensor ctrl
                    Arbiter_ARID_control = `M1_S3_ID;      
                else if (ARADDR_M1 [31:21] == 11'b0010_0000_000)//DRAM              
                    Arbiter_ARID_control = `M1_S4_ID;
                else
                Arbiter_ARID_control = `M1_default_ID;
            end
            //
            else    Arbiter_ARID_control = `Default_ID;        //Means {ARVALID_M0,ARVALID_M1}=2'b00. No Master have valid.
        end

        2'b01://M0
        begin
            if(ARADDR_M0 [31:16] == 16'h0000)        //ROM                                
                    Arbiter_ARID_control = `M0_S0_ID;
                else if(ARADDR_M0  [31:16] == 16'h0001)   //IM
                    Arbiter_ARID_control = `M0_S1_ID;
                else if(ARADDR_M0  [31:16] == 16'h0002)   //DM
                    Arbiter_ARID_control = `M0_S2_ID;
                else if (ARADDR_M0 [31:10] == 22'b0001_0000_0000_0000_0000_00)//sensor ctrl
                    Arbiter_ARID_control = `M0_S3_ID;      
                else if (ARADDR_M0 [31:21] == 11'b0010_0000_000)//DRAM              
                    Arbiter_ARID_control = `M0_S4_ID;
                else
                Arbiter_ARID_control = `M0_default_ID;
        end
        2'b10://M1
        begin
            if(ARADDR_M1 [31:16] == 16'h0000)        //ROM                                
                    Arbiter_ARID_control = `M1_S0_ID;
                else if(ARADDR_M1 [31:16] == 16'h0001)   //IM
                    Arbiter_ARID_control = `M1_S1_ID;
                else if(ARADDR_M1 [31:16] == 16'h0002)   //DM
                    Arbiter_ARID_control = `M1_S2_ID;
                else if (ARADDR_M1 [31:10] == 22'b0001_0000_0000_0000_0000_00)//sensor ctrl
                    Arbiter_ARID_control = `M1_S3_ID;      
                else if (ARADDR_M1 [31:21] == 11'b0010_0000_000)//DRAM              
                    Arbiter_ARID_control = `M1_S4_ID;
                else
                Arbiter_ARID_control = `M1_default_ID;
        end
        default:
            Arbiter_ARID_control = `Default_ID;                //Should not come here(No this state!!)
    endcase    
end



/*  HW2 AXI
always_comb begin
    case(Aibiter_Read_State_control)
        2'b00:
        begin
            if(ARVALID_M0)
            begin
                Arbiter_ARID_control[3] = 1'b0;
                if(ARADDR_M0[31:17] == 15'b0)      //check Slave1 address is correct?
                begin
                    if(ARADDR_M0[16] == 1'b0)
                        Arbiter_ARID_control[2:0] = 3'b001;//M0_S0
                    else
                        Arbiter_ARID_control[2:0] = 3'b010;//M0_S1
                end
                else    Arbiter_ARID_control[2:0] = 3'b100;//M0_Default_Slave
            end
            //
            else if(ARVALID_M1)
            begin
                Arbiter_ARID_control[3] = 1'b1;
                if(ARADDR_M1[31:17] == 15'b0)      //check Slave2 address is correct?
                begin
                    if(ARADDR_M1[16] == 1'b0)
                        Arbiter_ARID_control[2:0] = 3'b001;//M1_S0
                    else
                        Arbiter_ARID_control[2:0] = 3'b010;//M1_S1
                end
                else    Arbiter_ARID_control[2:0] = 3'b100;//M1_Default_Slave
            end
            //
            else    Arbiter_ARID_control = 4'b0;        //Means {ARVALID_M0,ARVALID_M1}=2'b00. No Master have valid.
        end
        2'b01://M0
        begin
            Arbiter_ARID_control[3] = 1'b0;
            if(ARADDR_regtemp[31:17] == 15'b0)      //check Slave1 address is correct?
            begin
                if(ARADDR_regtemp[16] == 1'b0)
                    Arbiter_ARID_control[2:0] = 3'b001;//M0_S0
                else
                    Arbiter_ARID_control[2:0] = 3'b010;//M0_S1
            end
            else    Arbiter_ARID_control[2:0] = 3'b100;//M0_Default_Slave
        end
        2'b10://M1
        begin
            Arbiter_ARID_control[3] = 1'b1;
            if(ARADDR_regtemp[31:17] == 15'b0)      //check Slave2 address is correct?
            begin
                if(ARADDR_regtemp[16] == 1'b0)
                    Arbiter_ARID_control[2:0] = 3'b001;//M1_S0
                else
                    Arbiter_ARID_control[2:0] = 3'b010;//M1_S1
            end
            else    Arbiter_ARID_control[2:0] = 3'b100;//M1_Default_Slave
        end
        default:
            Arbiter_ARID_control = 4'b0000;                //Should not come here(No this state!!)
    endcase    
end
*/



//DECERR:Default slave ➔ Response ERROR when Ms access (RRESP == DECERR) it

endmodule
