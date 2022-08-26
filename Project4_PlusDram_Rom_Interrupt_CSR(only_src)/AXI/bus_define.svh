//ID:1 bit(master) + 3 bit(slave) 

`define Maser_to_Slave_ID_BITS 4
`define Default_ID `Maser_to_Slave_ID_BITS'b0000 //when bus is not working

`define M0_S0_ID `Maser_to_Slave_ID_BITS'b0001
`define M0_S1_ID `Maser_to_Slave_ID_BITS'b0010
`define M0_S2_ID `Maser_to_Slave_ID_BITS'b0011
`define M0_S3_ID `Maser_to_Slave_ID_BITS'b0100
`define M0_S4_ID `Maser_to_Slave_ID_BITS'b0101
`define M0_default_ID `Maser_to_Slave_ID_BITS'b0111

`define M1_S0_ID `Maser_to_Slave_ID_BITS'b1001
`define M1_S1_ID `Maser_to_Slave_ID_BITS'b1010
`define M1_S2_ID `Maser_to_Slave_ID_BITS'b1011
`define M1_S3_ID `Maser_to_Slave_ID_BITS'b1100
`define M1_S4_ID `Maser_to_Slave_ID_BITS'b1101
`define M1_default_ID `Maser_to_Slave_ID_BITS'b1111