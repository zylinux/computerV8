
/**********basic**********/
`include "../../../top/include/nettype.h"
`include "../../../top/include/stddef.h"
`include "../../../top/include/global_config.h"


`include "../include/uart.h"
//if you use 50M clock, you will need to divie 50M by 260 = 192000
/**********UART module**********/
module uart (
	input  wire				   clk,
	input  wire				   reset,
	/**********uart slave bus**********/
	input  wire				   cs_,		 //
	input  wire				   as_,		 //
	input  wire				   rw,		 // Read / Write
	input  wire [`UartAddrBus] addr,	 //
	input  wire [`WordDataBus] wr_data,	 //
	output wire [`WordDataBus] rd_data,	 //
	output wire				   rdy_,	 //
	/**********cpu core irq**********/
	output wire				   irq_rx,	//
	output wire				   irq_tx,	//
	/********** UART pin**********/
	input  wire				   rx,		//rx pin
	output wire				   tx		 	//tx pin
);

	/**********internal signals**********/
	// rx to ctrl
	wire					   rx_busy;	 //uart_rx module connect to uart_ctrl modue
	wire					   rx_end;	 //uart_rx module connect to uart_ctrl module
	wire [`ByteDataBus]	rx_data;
	// tx to ctrl
	wire					   tx_busy;	 //uart_tx module connect to uart_ctrl module
	wire					   tx_end;	 //uart_tx module connect to uart_ctrl module
	wire					   tx_start;
	wire [`ByteDataBus]	tx_data;

	/**********UART control**********/
	uart_ctrl uart_ctrl (
		.clk	  (clk),
		.reset	  (reset),
		/********** Host Interface slave bus related**********/
		.cs_	  (cs_),	   	//
		.as_	  (as_),	   	//
		.rw		  (rw),		//
		.addr	  (addr),	   //
		.wr_data  (wr_data), //
		.rd_data  (rd_data), //
		.rdy_	  (rdy_),	   //
		/********** Interrupt  **********/
		.irq_rx	  (irq_rx),	   // to cpu core
		.irq_tx	  (irq_tx),	   // to cpu core
		/**********rx and tx **********/
		//rx
		.rx_busy  (rx_busy),   //
		.rx_end	  (rx_end),	  //
		.rx_data  (rx_data),   //
		//tx
		.tx_busy  (tx_busy),   //
		.tx_end	  (tx_end),	  //
		.tx_start (tx_start),  //
		.tx_data  (tx_data)	  //
	);

	/********** UART tx module**********/
	uart_tx uart_tx (
		.clk	  (clk),
		.reset	  (reset),
		/********************/
		.tx_start (tx_start),  //start send
		.tx_data  (tx_data),   //data to send
		.tx_busy  (tx_busy),   //send is busy?
		.tx_end	  (tx_end),	  //send is finished ?
		/********** Transmit Signal **********/
		.tx		  (tx)		   // UART tx pin
	);

	/********** UART rx module**********/
	uart_rx uart_rx (
		.clk	  (clk),
		.reset	  (reset),
		/********************/
		.rx_busy  (rx_busy),   	//receive is busy ?
		.rx_end	  (rx_end),	   //receive end
		.rx_data  (rx_data),   	//receive data
		/********** Receive Signal **********/
		.rx		  (rx)		   // UART rx pin
	);

endmodule
