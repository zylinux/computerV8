
`ifndef __BUS_HEADER__
	`define __BUS_HEADER__
	/**********MASTER CHANNEL**********/
	`define BusOwnerBus		   		1:0	 //master bus 2 bits means 0 1 2 3 , masters
	`define BUS_OWNER_MASTER_0 	2'h0	 //master 0
	`define BUS_OWNER_MASTER_1 	2'h1	 //master 1
	`define BUS_OWNER_MASTER_2 	2'h2	 //master 2
	`define BUS_OWNER_MASTER_3 	2'h3	 //master 3

	/**********SLAVE CHANNEL**********/
	`define BusSlaveIndexBus   	2:0	 //slave need 3 bits to represent 8 channels
	`define BusSlaveIndexLoc   	29:27 //CPU address mapping to address only need the 27 28 29 bits to slave

	`define BUS_SLAVE_0		   		0	 //SLAVE 0
	`define BUS_SLAVE_1		   		1	 //SLAVE 1
	`define BUS_SLAVE_2		   		2	 //SLAVE 2
	`define BUS_SLAVE_3		   		3	 //SLAVE 3
	`define BUS_SLAVE_4		   		4	 //SLAVE 4
	`define BUS_SLAVE_5		   		5	 //SLAVE 5
	`define BUS_SLAVE_6		   		6	 //SLAVE 6
	`define BUS_SLAVE_7		   		7	 //SLAVE 7

`endif
