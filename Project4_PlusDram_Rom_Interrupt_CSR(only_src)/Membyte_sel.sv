`include "Defines.svh"
`include "IDInstDef.svh"

// SH is to write the lowest 16-bit data of the rs2 register into the memory, 
// and SB is to write the lowest 8-bit data of the rs2 register into the memory

module  Membyte_sel(
    input memwrite,
    input [31:0] write_data,
    input [1:0] Byte_Address,
    input [2:0]func3,
    output logic [3:0] WEB,
    output logic [31:0] DI
);
always_comb 
begin
        if(memwrite)            
            case(func3)
                `FUNCT3_SB:
                begin
                    case(Byte_Address)
                        2'b00:
                        begin
                            WEB=4'b1110;
                            DI={24'd0,write_data[7:0]};                            
                        end
                        2'b01:
                        begin
                            WEB=4'b1101;
                            DI={16'd0,write_data[7:0],8'd0};
                        end
                        2'b10:
                        begin
                            WEB=4'b1011;
                            DI={8'd0,write_data[7:0],16'd0};
                        end
                        2'b11:
                        begin
                            WEB=4'b0111;
                            DI={write_data[7:0],24'd0};
                        end
                    endcase
                end
                `FUNCT3_SH:
                begin
                    case(Byte_Address)
                        2'b00:
                        begin
                            WEB =4'b1100;
                            DI={16'd0,write_data[15:0]};
                        end
                        2'b10:
                        begin
                            WEB=4'b0011;
                            DI = {write_data[15:0],16'd0};
                        end
                        default:
                        begin
                            WEB=4'b1111;
                            DI=32'b0;
                        end
                    endcase
                end
                `FUNCT3_SW:
                begin
                    WEB=4'b0000; //write a word = 4 byte
                    DI=write_data;
                end
                default:
                begin
                    WEB=4'b1111;
                    DI=32'b0;
                end
            endcase
        else
        begin
            WEB=4'b1111;
            DI=32'b0;
        end
end
endmodule
