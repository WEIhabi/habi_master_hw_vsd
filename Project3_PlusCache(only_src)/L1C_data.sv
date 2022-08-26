//================================================
// Auther:      WEI Sheng-Ran
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"

module L1C_data(
    input clk,
    input rst,
    input [31:0] core_addr,
    input core_req,
    input core_write,
    input [31:0] core_in,
    input [2:0] core_type,
    input [31:0] D_out,
    input D_wait,
    output logic [31:0] core_out,   //
    output logic core_wait,         //
    output logic D_req,             //
    output logic [31:0] D_addr,     //
    output logic D_write,           //
    output logic [31:0] D_in,       //
    output logic [2:0] D_type       //
);

logic [63:0]  valid;
logic [5:0]   index;
logic         TA_write, TA_read;
logic [21:0]  TA_in, TA_out;
logic [15:0]  DA_write;
logic         DA_read;
logic [127:0] DA_in;
logic [127:0] DA_out;
//
logic [3:0]   offset;
logic [1:0]   cache_state;
logic         read_hit, read_miss, write_hit, write_miss;
logic [1:0]   wait_ctr;
logic [95:0]  DA_in_buffer;

/////////////////////////////////////////////------ask-----/////////////////////////////////////////////
//calculate the cache hit rate
integer D_read_hit_count;//32bit
integer D_read_miss_count; //32bit
integer D_write_hit_count;//32bit
integer D_write_miss_count; //32bit

//don't change
always_ff @(posedge clk or posedge rst) begin
    if(rst)             D_read_hit_count <= 32'd0;
    else if(read_hit)   D_read_hit_count <= D_read_hit_count + 32'd1;
    else                D_read_hit_count <= D_read_hit_count;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)             D_read_miss_count <= 32'd0;
    else if(read_miss && cache_state == 2'd1)  
    D_read_miss_count <= D_read_miss_count + 32'd1;
    else                D_read_miss_count <= D_read_miss_count;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)             D_write_hit_count <= 32'd0;
    else if(write_hit  && cache_state == 2'd1)   
        D_write_hit_count <= D_write_hit_count + 32'd1;
    else                D_write_hit_count <= D_write_hit_count;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)             D_write_miss_count <= 32'd0;
    else if(write_miss  && cache_state == 2'd1)  
        D_write_miss_count <= D_write_miss_count + 32'd1;
    else                D_write_miss_count <= D_write_miss_count;
end


//address
// | 31     10 | 9     4 | 3      0
// |    tag    |  index  |  offset

//cache status
//status 0: IDLE
//status 1: decide hit or miss
//status 2: read miss
//status 3: write hit or miss


//outside cpu wrapper will send core_req(D_core_req) to here
always_ff @ (posedge clk or posedge rst) begin
    if (rst) cache_state <= 2'd0;
    else
        case (cache_state)
            2'd0: cache_state <= (core_req)? 2'd1 : cache_state;
            2'd1: begin
                if (core_req) begin
                    if (core_write)  cache_state <= 2'd3;
                    else if (read_miss) cache_state <= 2'd2;
                    else             cache_state <= 2'd0;
                end
                else cache_state <= 2'd0;
            end
            2'd2:    cache_state <= (core_wait)? cache_state : 2'd0;
            default: cache_state <= (core_wait)? cache_state : 2'd0;
        endcase
end


always_comb begin
    if (core_req && cache_state != 2'd0) begin
		if (valid[index]) begin
        	if (TA_in == TA_out) begin
                read_hit = (core_write)? 1'b0 : 1'b1;
                read_miss = 1'b0;
                write_hit = (core_write)? 1'b1 : 1'b0;
                write_miss = 1'b0;
            end
            else begin
				read_hit = 1'b0;
				read_miss = (core_write)? 1'b0 : 1'b1;
				write_hit = 1'b0;
				write_miss = (core_write)? 1'b1 : 1'b0;
			end
        end
        else begin
			read_hit = 1'b0;
			read_miss = (core_write)? 1'b0 : 1'b1;
			write_hit = 1'b0;
			write_miss = (core_write)? 1'b1 : 1'b0;
		end
	end
    else begin
        read_hit = 1'b0;
        read_miss = 1'b0;
        write_hit = 1'b0;
        write_miss = 1'b0;
    end
end

always_ff @ (posedge clk or posedge rst) begin
    if (rst) valid <= 64'b0;
    else     valid[index] <= (cache_state == 2'd2 && !core_wait)? 1'b1 : valid[index];
end

always_comb begin
    case (cache_state)
        2'd1:    core_wait = (read_hit)? 1'b0 : 1'b1;
        2'd2:    core_wait = (wait_ctr == 2'd3 && !D_wait)? 1'b0 : 1'b1;
        2'd3:    core_wait = D_wait;
        default: core_wait = 1'b1;
    endcase
end

always_ff @ (posedge clk or posedge rst) begin
    if (rst) wait_ctr <= 2'd0;
    else begin
        if (cache_state == 2'd2 || cache_state == 2'd3) wait_ctr <= (D_wait)? wait_ctr : wait_ctr + 2'd1;
        else                                              wait_ctr <= 2'd0;
    end
end



//original
always_ff @ (posedge clk or posedge rst) begin
    if (rst) DA_in_buffer <= 96'b0;
    else begin
        if (cache_state == 2'd2 ) begin
            if(D_wait)
                DA_in_buffer <= DA_in_buffer;
            else
            begin
                DA_in_buffer[95:64] <= DA_in_buffer[63:32];
                DA_in_buffer[63:32] <= DA_in_buffer[31:0];
                DA_in_buffer[31:0] <= D_out;
            end
        end
        else DA_in_buffer <= 96'b0;
    end
end

always_comb begin
    case (offset[3:2])
        2'b00:   core_out = (read_miss)? D_out : DA_out[31:0];
        2'b01:   core_out = (read_miss)? DA_in_buffer[31:0] : DA_out[63:32];
        2'b10:   core_out = (read_miss)? DA_in_buffer[63:32] : DA_out[95:64];
        default: core_out = (read_miss)? DA_in_buffer[95:64] : DA_out[127:96];
    endcase
end
//original to here


/*
//test
//Different deposit order
always_ff @ (posedge clk or posedge rst) begin
    if (rst) DA_in_buffer <= 96'b0;
    else begin
        if (cache_state == 2'd2 && ~D_wait) begin
            DA_in_buffer[31:0] <= DA_in_buffer[63:32];
            DA_in_buffer[63:32] <= DA_in_buffer[95:64];
            DA_in_buffer[95:64] <= D_out;
        end
        else DA_in_buffer <= 96'b0;
    end
end

always_comb begin
    case (offset[3:2])
        2'b00:   core_out = (read_miss)? D_out : DA_out[31:0];
        2'b01:   core_out = (read_miss)? DA_in_buffer[31:0] : DA_out[63:32];
        2'b10:   core_out = (read_miss)? DA_in_buffer[63:32] : DA_out[95:64];
        default: core_out = (read_miss)? DA_in_buffer[95:64] : DA_out[127:96];
    endcase
end
//test to here
*/


assign D_req = (read_miss || write_hit || write_miss)? core_req : 1'b0;
assign D_addr = core_addr;
assign D_write = core_write;
assign D_in = core_in;
assign D_type = core_type;
assign index = core_addr[9:4];
assign offset = core_addr[3:0];
assign DA_in = (core_write)? {core_in, core_in, core_in, core_in} : {DA_in_buffer, D_out};
assign DA_read = 1'b1;
assign TA_in = core_addr[31:10];
assign TA_read = 1'b1;

always_comb begin
    case (cache_state)
        2'd2: begin
            //last cycle of read miss
            DA_write = (core_wait)? 16'b1111_1111_1111_1111 : 16'b0;//when core_wait = 0, write data into Data array
            TA_write = (core_wait)? 1'b1 : 1'b0;
        end
        2'd3: begin
            if (write_hit && !core_wait) //last cycle of write hit
                case (core_type)
                    `CACHE_BYTE:
                        case (offset[3:2])
                            2'b00: begin
                                DA_write[15:4] = 12'b1111_1111_1111;
                                case (offset[1:0])
                                    2'b00:   DA_write[3:0] = 4'b1110;
                                    2'b01:   DA_write[3:0] = 4'b1101;
                                    2'b10:   DA_write[3:0] = 4'b1011;
                                    default: DA_write[3:0] = 4'b0111;
                                endcase
                            end
                            2'b01: begin
                                DA_write[15:8] = 8'b1111_1111;
                                DA_write[3:0] = 4'b1111;
                                case (offset[1:0])
                                    2'b00:   DA_write[7:4] = 4'b1110;
                                    2'b01:   DA_write[7:4] = 4'b1101;
                                    2'b10:   DA_write[7:4] = 4'b1011;
                                    default: DA_write[7:4] = 4'b0111;
                                endcase
                            end
                            2'b10: begin
                                DA_write[15:12] = 4'b1111;
                                DA_write[7:0] = 8'b1111_1111;
                                case (offset[1:0])
                                    2'b00:   DA_write[11:8] = 4'b1110;
                                    2'b01:   DA_write[11:8] = 4'b1101;
                                    2'b10:   DA_write[11:8] = 4'b1011;
                                    default: DA_write[11:8] = 4'b0111;
                                endcase
                            end
                            default: begin
                                DA_write[11:0] = 12'b1111_1111_1111;
                                case (offset[1:0])
                                    2'b00:   DA_write[15:12] = 4'b1110;
                                    2'b01:   DA_write[15:12] = 4'b1101;
                                    2'b10:   DA_write[15:12] = 4'b1011;
                                    default: DA_write[15:12] = 4'b0111;
                                endcase
                            end
                        endcase
                    `CACHE_HWORD:
                        case (offset[3:2])
                            2'b00: begin
                                DA_write[15:4] = 12'b1111_1111_1111;
                                DA_write[3:2] = (offset[1:0] == 2'b00)? 2'b11 : 2'b00;
                                DA_write[1:0] = (offset[1:0] == 2'b00)? 2'b00 : 2'b11;
                            end
                            2'b01: begin
                                DA_write[15:8] = 8'b1111_1111;
                                DA_write[3:0] = 4'b1111;
                                DA_write[7:6] = (offset[1:0] == 2'b00)? 2'b11 : 2'b00;
                                DA_write[5:4] = (offset[1:0] == 2'b00)? 2'b00 : 2'b11;
                            end
                            2'b10: begin
                                DA_write[15:12] = 4'b1111;
                                DA_write[7:0] = 8'b1111_1111;
                                DA_write[11:10] = (offset[1:0] == 2'b00)? 2'b11 : 2'b00;
                                DA_write[9:8] = (offset[1:0] == 2'b00)? 2'b00 : 2'b11;
                            end
                            default: begin
                                DA_write[11:0] = 12'b1111_1111_1111;
                                DA_write[15:14] = (offset[1:0] == 2'b00)? 2'b11 : 2'b00;
                                DA_write[13:12] = (offset[1:0] == 2'b00)? 2'b00 : 2'b11;
                            end
                        endcase
                    `CACHE_WORD:
                        case (offset[3:2])
                            2'b00: begin
                                DA_write[15:4] = 12'b1111_1111_1111;
                                DA_write[3:0] = 4'b0000;
                            end
                            2'b01: begin
                                DA_write[15:8] = 8'b1111_1111;
                                DA_write[3:0] = 4'b1111;
                                DA_write[7:4] = 4'b0000;
                            end
                            2'b10: begin
                                DA_write[15:12] = 4'b1111;
                                DA_write[7:0] = 8'b1111_1111;
                                DA_write[11:8] = 4'b0000;
                            end
                            default: begin
                                DA_write[11:0] = 12'b1111_1111_1111;
                                DA_write[15:12] = 4'b0000;
                            end
                        endcase
                    default: DA_write = 16'b1111_1111_1111_1111;
                endcase
            else DA_write = 16'b1111_1111_1111_1111;
            TA_write = 1'b1;
        end
        default: begin
            DA_write = 16'b1111_1111_1111_1111;
            TA_write = 1'b1;
        end
    endcase
end


data_array_wrapper DA(
.A(index),
.DO(DA_out),
.DI(DA_in),
.CK(clk),
.WEB(DA_write),
.OE(DA_read),
.CS(1'b1)
);
   
tag_array_wrapper  TA(
.A(index),
.DO(TA_out),
.DI(TA_in),
.CK(clk),
.WEB(TA_write),
.OE(TA_read),
.CS(1'b1)
);

endmodule