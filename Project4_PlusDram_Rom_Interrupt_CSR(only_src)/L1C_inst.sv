//================================================
// Auther:      WEI Sheng-Ran
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"

module L1C_inst(
    input clk,
    input rst,
    // Core to cpu wrapper
    input [31:0] core_addr,         //PAddress
    input        core_req,          //PStrobe
    input        core_write,        //IM can't write
    input [31:0] core_in,           //IM can't write
    input [2:0]  core_type,         //
    // Mem to cpu wrapper
    input [31:0] I_out,             //mem data pass to here(read miss)
    input        I_wait,            //wait to get mem data
    // Cpu wrapper to core
    output logic [31:0] core_out,   //connect to IM_out
    output logic core_wait,         //Stall
    // Cpu wrapper to mem 
    output logic I_req,             //output to cpu wrapper control there state machine
    output logic [31:0] I_addr,     //send to bus ARADDR
    output logic I_write,           //Similar to air connection, because IM can't write
    output logic [31:0] I_in,       //Similar to air connection, because IM can't write
    output logic [2:0] I_type       //write/read byte/(unsign), half word/(unsign), or word
);

//for tag/data array
logic [63:0] valid;
logic [5:0]  index;
logic TA_write, TA_read;
logic [21:0] TA_in, TA_out;
logic [15:0] DA_write;
logic DA_read;
logic [127:0] DA_in;
logic [127:0] DA_out;

logic [3:0]   offset;
logic [1:0]   cache_state;
logic         read_hit, read_miss;
logic [1:0]   wait_ctr;
logic [95:0]  DA_in_buffer;

/////////////////////////////////////////////------ask-----/////////////////////////////////////////////
//calculate the cache hit rate
integer I_read_hit_count;//32bit
integer I_read_miss_count; //32bit

always_ff @(posedge clk or posedge rst) begin
    if(rst)             I_read_hit_count <= 32'd0;
    else if(read_hit)   I_read_hit_count <= I_read_hit_count + 32'd1;
    else                I_read_hit_count <= I_read_hit_count;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)             
        I_read_miss_count <= 32'd0;
    else if(read_miss && cache_state == 2'd1)  
        I_read_miss_count <= I_read_miss_count + 32'd1;
    else                
        I_read_miss_count <= I_read_miss_count;
end


//address
// | 31     10 | 9     4 | 3      0
// |    tag    |  index  |  offset

//cache_state
//state 0: IDLE
//state 1: hit or miss
//state 2: read miss case

always_ff @( posedge clk or posedge rst ) begin
    if(rst)    cache_state <= 2'd0;
    else
        case(cache_state)
            2'd0:   cache_state <= (core_req)? 2'd1 : 2'd0;
            2'd1:begin
                //why decide core_req again? because cooperate cpu wrapper.
                if(core_req)    cache_state <= (read_miss)? 2'd2 : 2'd0;
                else            cache_state <= 2'd0;
            end
            2'd2:   cache_state <= (core_wait)? 2'd2 : 2'd0;
            default:cache_state <= 2'd0;
        endcase
end

always_comb begin
    if(core_req && cache_state != 2'd0)
    begin
        if(valid[index])begin
            if(TA_in == TA_out)begin
                read_hit  = 1'b1;
                read_miss = 1'b0;
            end
            else begin
                read_hit  = 1'b0;
                read_miss = 1'b1;
            end
        end
        else begin
            read_hit  = 1'b0;
            read_miss = 1'b1;
        end
    end
    else begin
        read_hit  = 1'b0;
        read_miss = 1'b0;
    end
end

// After reset valid = 64'b0, only after saving valid information, valid[index]=1.
always_ff @(posedge clk or posedge rst) begin
    if(rst) valid <= 64'd0;
    else    valid[index] <= (cache_state == 2'd2 && !core_wait)? 1'b1 : valid[index];
end

//wait to read 4 word data
always_comb begin
    case(cache_state)
        2'd1:   core_wait = (read_hit)? 1'b0 : 1'b1;
        2'd2:   core_wait = (wait_ctr == 2'd3)? 1'b0 : 1'b1;
        default:core_wait = 1'b1;
    endcase
end

always_ff @ (posedge clk or posedge rst) begin
    if (rst) wait_ctr <= 2'd0;
    else begin
        if (cache_state == 2'd2) wait_ctr <= (I_wait)? 2'd0 : wait_ctr + 2'd1;
        else                      wait_ctr <= 2'd0;
    end
end



//original
always_ff @ (posedge clk or posedge rst) begin
    if (rst) DA_in_buffer <= 96'b0;
    else begin
        if (cache_state == 2'd2 && !I_wait) begin
            DA_in_buffer[95:64] <= DA_in_buffer[63:32];
            DA_in_buffer[63:32] <= DA_in_buffer[31:0];
            DA_in_buffer[31:0] <= I_out;
        end
        else DA_in_buffer <= 96'b0;
    end
end

always_comb begin
    case (offset[3:2])
        2'b00:   core_out = (read_miss)? I_out : DA_out[31:0];
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
        if (cache_state == 2'd2 && !I_wait) begin
            DA_in_buffer[31:0] <= DA_in_buffer[63:32];
            DA_in_buffer[63:32] <= DA_in_buffer[95:64];
            DA_in_buffer[95:64] <= I_out;
        end
        else DA_in_buffer <= 96'b0;
    end
end

always_comb begin
    case (offset[3:2])
        2'b00:   core_out = (read_miss)? I_out : DA_out[31:0];
        2'b01:   core_out = (read_miss)? DA_in_buffer[31:0] : DA_out[63:32];
        2'b10:   core_out = (read_miss)? DA_in_buffer[63:32] : DA_out[95:64];
        default: core_out = (read_miss)? DA_in_buffer[95:64] : DA_out[127:96];
    endcase
end
//test to here
*/

assign I_req    = (read_miss)? core_req : 1'b0;
assign I_addr   = core_addr;
assign I_write  = core_write;
assign I_in     = core_in;
assign I_type   = core_type;
assign index    = core_addr[9:4];
assign offset   = core_addr[3:0];

//cooperate valid bit to write in data array
assign DA_write = (cache_state == 2'd2 && !core_wait)? 16'h0 : 16'hFFFF;

//in I-cache core_write will always is 1'b0!
assign DA_in    = (core_write)? {core_in, core_in, core_in, core_in} : {DA_in_buffer, I_out};
assign DA_read  = 1'b1;

assign TA_in    = core_addr[31:10];
assign TA_write = (cache_state == 2'd2 && !core_wait)? 1'b0 : 1'b1;
assign TA_read  = 1'b1;


data_array_wrapper DA(
.A(index),
.DO(DA_out),
.DI(DA_in),
.CK(clk),
.WEB(DA_write),
.OE(DA_read),
.CS(1'b1)
);

tag_array_wrapper TA(
.A(index),
.DO(TA_out),
.DI(TA_in),
.CK(clk),
.WEB(TA_write),
.OE(TA_read),
.CS(1'b1)
);

endmodule