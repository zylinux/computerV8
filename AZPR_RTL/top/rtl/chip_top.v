/**********basic headers**********/
`include "../include/nettype.h"
`include "../include/stddef.h"
`include "../include/global_config.h"
/*********GPIO**********/
`include "../../io/gpio/include/gpio.h"
/**********top chip module**********/
module chip_top (
	input wire				   clk_ref,		  //main clock
	input wire				   reset_sw		  //main reset
	/********** UART **********/
`ifdef IMPLEMENT_UART // UART
	, input wire			   uart_rx		  // UART rx pin
	, output wire			   uart_tx		  // UART tx pin
`endif
	/**********3 type of gpio**********/
`ifdef IMPLEMENT_GPIO // GPIO
`ifdef GPIO_IN_CH	 // how many 4
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in  //gpio input only
`endif
`ifdef GPIO_OUT_CH	 //how many 18
	, output wire [`GPIO_OUT_CH-1:0] gpio_out //gpio out only
`endif
`ifdef GPIO_IO_CH	 //how many 16
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io  //gpio input or output
`endif
`endif
);

	/**********system clock and reset**********/
	wire					   clk;//system clock
	wire					   clk_;//180 system clock
	wire					   chip_reset;//system reset
	/**********clock genaration module**********/
	clk_gen clk_gen (
		//original clock from outside pin
		.clk_ref	  (clk_ref),		//referece clock from outside pin
		.reset_sw	  (reset_sw),	//reset from outside pin
		//generated clock for system other parts to use
		.clk		  (clk),				//normal clock
		.clk_		  (clk_),			//180 degree clock
		//generated reset for syttem other parts to use
		.chip_reset (chip_reset)
	);

	/**********chip soc init**********/
	chip chip (
		.clk	  (clk),					//clock genarated above
		.clk_	  (clk_),				//180 clock genarated above
		.reset	  (chip_reset)		//generated reset above
		/**********UART**********/
`ifdef IMPLEMENT_UART
		, .uart_rx	(uart_rx)		//UART rx
		, .uart_tx	(uart_tx)		//UART tx
`endif
		/**********GPIO**********/
`ifdef IMPLEMENT_GPIO
`ifdef GPIO_IN_CH//4
		, .gpio_in (gpio_in)//only input
`endif
`ifdef GPIO_OUT_CH//18
		, .gpio_out (gpio_out)// only output
`endif
`ifdef GPIO_IO_CH//16
		, .gpio_io	(gpio_io)//both input and output
`endif
`endif
	);

endmodule
