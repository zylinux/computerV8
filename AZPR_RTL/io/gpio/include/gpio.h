`ifndef __GPIO_HEADER__
   `define __GPIO_HEADER__
	//register 0x8000_0000 - 0x9FFF_FFFF
	/**********channel**********/
	`define GPIO_IN_CH		   4	//input gpio channel
	`define GPIO_OUT_CH		   18	//output gpio channel
	`define GPIO_IO_CH		   16	//input and output gpio channel
	`define GpioAddrBus		   1:0	//
	//`define GPIO_ADDR_W		   2		//
	`define GpioAddrLoc		   1:0	//
	/**********registers 0x8000_0000 - 0x9FFF_FFFF********/
	`define GPIO_ADDR_IN_DATA  2'h0	//offset 0 when you need a input gpio
	`define GPIO_ADDR_OUT_DATA 2'h1 	//offset 1 when you need a output gpio
	`define GPIO_ADDR_IO_DATA  2'h2 	//offset 2 when you need a in or out put gpio
	`define GPIO_ADDR_IO_DIR   2'h3 	//offset 3 when you need set in or out gpio
	/**********for Input and Output channel**********/
	`define GPIO_DIR_IN		   1'b0 	//input direction
	`define GPIO_DIR_OUT	   	1'b1 	//output direction

`endif
