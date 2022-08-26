`include "IDInstDef.svh"
module LOAD_signextend (
    input [31:0] DM_read_data,
    input [6:0] opcode7,
    input [2:0] func3,
    input [1:0] Byte_Address,
    output logic [31:0] DM_out
);
logic [7:0] LB_tmp00;
logic [7:0] LB_tmp01;
logic [7:0] LB_tmp10;
logic [7:0] LB_tmp11;
logic [15:0] LH_tmp00;
logic [15:0] LH_tmp10;
//assign LB_tmp00 = DM_read_data[7:0];// 1byte
//assign LB_tmp01 = DM_read_data[15:8];// 1byte
//assign LB_tmp10 = DM_read_data[23:16];// 1byte
//assign LB_tmp11 = DM_read_data[31:24];// 1byte
//assign LH_tmp00 = DM_read_data[15:0];// 2byte
//assign LH_tmp10 = DM_read_data[31:16];// 2byte
always_comb begin 
    if(opcode7 == `OP_LOAD) begin
        case(func3)
            `FUNCT3_LB:
            begin
                case(Byte_Address)
                    2'b00:DM_out = {{24{DM_read_data[7]}}, DM_read_data[7:0]};
                    2'b01:DM_out = {{16{DM_read_data[15]}}, DM_read_data[15:8], 8'b0};
                    2'b10:DM_out = {{8{DM_read_data[23]}}, DM_read_data[23:16], 16'b0};
                    default:DM_out = {DM_read_data[31:24], 24'b0};
                endcase
            end
            `FUNCT3_LH:
            begin
                case(Byte_Address)
                    2'b00:DM_out = {{16{DM_read_data[15]}}, DM_read_data[15:0]};
                    2'b10:DM_out = {DM_read_data[31:16], 16'b0};
                    default:DM_out = {{16{DM_read_data[15]}}, DM_read_data[15:0]};
                endcase
            end
            `FUNCT3_LBU:
            begin
                case(Byte_Address)
                    2'b00:DM_out = {24'b0, DM_read_data[7:0]};
                    2'b01:DM_out = {16'b0, DM_read_data[15:8], 8'b0};
                    2'b10:DM_out = {8'b0, DM_read_data[23:16], 16'b0};
                    default:DM_out = {DM_read_data[31:24], 24'b0};
                endcase
            end
            `FUNCT3_LHU:
            begin
                case(Byte_Address)
                    2'b00:DM_out = {16'b0, DM_read_data[15:0]};
                    2'b10:DM_out = {DM_read_data[31:16], 16'b0};
                    default:DM_out = {16'b0, DM_read_data[15:0]};
                endcase
            end
            default:
            begin
                DM_out = DM_read_data;
            end
        endcase
    end
    else
    begin
        DM_out = DM_read_data;
    end
end   
endmodule 
