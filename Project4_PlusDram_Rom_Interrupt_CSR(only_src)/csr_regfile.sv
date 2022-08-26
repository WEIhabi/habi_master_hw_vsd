`include "Defines.svh"
`include "IDInstDef.svh"

module csr_regfile (
    input clk,rst,
    input [11:0] rs_address,
    input [11:0] rd_address,
    input [31:0] csr_writeback_data,    //WB stage write back csr data
    input [31:0] pc,                //when interrupt gives to mepc to store
    input        interrupt,
    input        MRET,
    input        reg_write_csr,     //regWrite for csr
    output logic [31:0] csr_rs,
    output logic        MEIE,
    output logic [31:0] mtvec_pc,
    output logic [31:0] mepc_pc
);
//address is 12 bit(hex 3 bit)    
//reg_mem[0]: mstatus   300     Machine status register
//reg_mem[1]: mie       304     Machine interrupt-enable register
//reg_mem[2]: mtvec     305     Machine Trap-Vector Base-Address register
//reg_mem[3]: mepc      341     Machine exception program counter
//reg_mem[4]: mip       344     Machine interrupt pending register
//reg_mem[5]: mcycle    B00     Lower 32bits of cycle counter               ---
//reg_mem[6]: minstret  B02     Lower 32bits of instruction-retired counter   |  ---
//reg_mem[7]: mcycleh   B80     Upper 32bits of cycle counter               ---    |
//reg_mem[8]: minstreth B82     Upper 32bits of instruction-retired counter      ---

logic [31:0] csr_mem [8:0];

//this block is to read data
always_comb begin
    case(rs_address)
        12'h300: csr_rs = csr_mem[0];   //mstatus
        12'h304: csr_rs = csr_mem[1];   //mie 
        12'h305: csr_rs = csr_mem[2];   //mtvec
        12'h341: csr_rs = csr_mem[3];   //mepc
        12'h344: csr_rs = csr_mem[4];   //mip
        12'hB00: csr_rs = csr_mem[5];   //mcycle
        12'hB02: csr_rs = csr_mem[6];   //minstret
        12'hB80: csr_rs = csr_mem[7];   //mcycleh
        12'hB82: csr_rs = csr_mem[8];   //minstreth
        default: csr_rs = 32'b0;
    endcase
end

//this block is to write back data
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        for(int i=0 ; i<9 ; i++)
            csr_mem[i] <= (i==2)? 32'h0001_0000 : 32'd0;    //mtvec is hardwire to 32'h0001_0000
    end    
    else begin
        if(reg_write_csr) begin    //when csr instuction write back except MRET or WFI.
            case(rd_address)
                12'h300:begin //mstatus
                    csr_mem[0][12:11] <= csr_writeback_data[12:11];
                    csr_mem[0][7]     <= csr_writeback_data[7];
                    csr_mem[0][3]     <= csr_writeback_data[3];
                end
                12'h304:      //mie
                    csr_mem[1][11]    <= csr_writeback_data[11];
                12'h341:      //mepc
                    csr_mem[3][31:2]  <= csr_writeback_data[31:2];
                12'h344:      //mip
                    csr_mem[2]        <= csr_mem[2];    //mip same as mtvec, I guess MEIP is Dispensable existence.
                12'hB00:      //mcycle
                    csr_mem[5]        <= csr_writeback_data;
                12'hB02:      //minstret
                    csr_mem[6]        <= csr_writeback_data;
                12'hB80:      //mcycleh
                    csr_mem[7]        <= csr_writeback_data;
                12'hB82:      //minstreth
                    csr_mem[8]        <= csr_writeback_data;
                default:      //12'h305 -> mtvec is hardwire to 32'h0001_0000
                    csr_mem[2]        <= csr_mem[2];
            endcase
        end
        else if(interrupt)begin
            csr_mem[0][12:11] <= 2'b11;         //[12:11] is MPP -> 2'b11 Machine mode
            csr_mem[0][7]     <= csr_mem[0][3]; //MPIE store MIE current state
            csr_mem[0][3]     <= 1'b0;          //when interrupt MIE give 0
            csr_mem[3]        <= pc;            //when interrupt gives to mepc to store
            csr_mem[4][11]    <= 1'b1;          //mip[11] is MEIP when interrupt give 1
        end
        else if(MRET)begin
            csr_mem[0][12:11] <= 2'b11;         //[12:11] is MPP -> 2'b11 Machine mode
            csr_mem[0][7]     <= 1'b1;          //When interrupt is finish MPIE get 1 
            csr_mem[0][3]     <= csr_mem[0][7]; //When interrupt is finish MIE get MPIE value
            csr_mem[4][11]    <= 1'b0;          //When interrupt is finish MEIP is 0
        end
        else 
            csr_mem[0] <= csr_mem[0];
    end
end

assign MEIE     =   csr_mem[1][11]; //mie[11] -> MEIE
assign mtvec_pc =   {csr_mem[2][31:2], 2'b00};
assign mepc_pc  =   {csr_mem[3][31:2], 2'b00} + 32'd4;
//WFI unaffect by global interrupt bit in mststus -> MIE 

endmodule