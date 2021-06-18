
`ifndef __TIMER_HEADER__
	`define __TIMER_HEADER__

	/**********bus**********/
	//`define TIMER_ADDR_W		2
	`define TimerAddrBus		1:0	//	control registers address
	`define TimerAddrLoc		1:0
	/**********control registers**********/
	`define TIMER_ADDR_CTRL		2'h0 // control register 0 : control start and mode etc
	`define TIMER_ADDR_INTR		2'h1 // control register 1 : interrupt
	`define TIMER_ADDR_EXPR		2'h2 // control register 2 : max number
	`define TIMER_ADDR_COUNTER	2'h3 // control register 3 : counter
	/**********mode and start**********/
	`define TimerStartLoc		0	 //start bit position
	`define TimerModeLoc		1	 //mode bit position
	`define TIMER_MODE_ONE_SHOT 1'b0 //one shot
	`define TIMER_MODE_PERIODIC 1'b1 //periodic
	//interrupt
	`define TimerIrqLoc			0	 //interrupt bit position

`endif
