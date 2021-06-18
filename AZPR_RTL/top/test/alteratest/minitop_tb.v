`timescale 1ns/1ps
//100.1 means 100ps
//basic headers
`include "../../include/nettype.h"
`include "../../include/stddef.h"
`include "../../include/global_config.h"
//headers
`include "../../../bus/include/bus.h"
`include "../../../cpu/include/cpu.h"
`include "../../../io/gpio/include/gpio.h"

`define SIM_CYCLE  100000 //3s=30000000
//simulation module
module minitop_tb;

	
	// clk and reset
	reg								clk_ref;
	reg								reset_sw;
	// UART
	`ifdef IMPLEMENT_UART // UART
	wire								uart_rx;	   // UART rx pin
	wire								uart_tx;	   // UART tx pin
	`endif
	// GPIO
	`ifdef IMPLEMENT_GPIO // GPIO
	`ifdef GPIO_IN_CH	 //input channel
	wire [`GPIO_IN_CH-1:0]		gpio_in = {`GPIO_IN_CH{1'b0}}; //pins
	`endif
	`ifdef GPIO_OUT_CH	 //output channel
	wire [`GPIO_OUT_CH-1:0] 	gpio_out;											 //pins
	`endif
	`ifdef GPIO_IO_CH	 	//input and output channel
	wire [`GPIO_IO_CH-1:0]		gpio_io = {`GPIO_IO_CH{1'bz}}; //pins
	`endif
	`endif

	//UART
	`ifdef IMPLEMENT_UART // UART
	wire					 			rx_busy;		  //
	wire					 			rx_end;		  //
	wire [`ByteDataBus]		 	rx_data;		  //
	`endif

	parameter				 		STEP = 100.0000;//100ns
	//10M clk to 100ns
	always #( STEP / 2 ) begin
		clk_ref <= ~clk_ref;
	end

	//chip_top
	chip_top chip_top (
		//clk reset
		.clk_ref	(clk_ref),
		.reset_sw	(reset_sw)
		//UART
		`ifdef IMPLEMENT_UART // UART
		, .uart_rx	(uart_rx)  // UART rx
		, .uart_tx	(uart_tx)  // UART tx
		`endif
		//GPIO
		`ifdef IMPLEMENT_GPIO // GPIO
		`ifdef GPIO_IN_CH						//4
		, .gpio_in	(gpio_in)
		`endif
		`ifdef GPIO_OUT_CH
		, .gpio_out (gpio_out)	//18
		`endif
		`ifdef GPIO_IO_CH	 					//16
		, .gpio_io	(gpio_io)  //
		`endif
		`endif
	);
	
	//GPIO
	`ifdef IMPLEMENT_GPIO
	`ifdef GPIO_IN_CH	// input 4
	always @(gpio_in) begin//if gpio_in changed , print it
		$display($time, " gpio_in changed  : %b", gpio_in);
	end
	`endif
	`ifdef GPIO_OUT_CH	//output 18
	always @(gpio_out) begin//if gpio_out changed , print it
		$display($time, " gpio_out changed : %b", gpio_out);
	end
	`endif
	`ifdef GPIO_IO_CH	 //input and output 16
	always @(gpio_io) begin//if gpio_io changed , print it
		$display($time, " gpio_io changed  : %b", gpio_io);
	end
	`endif
	`endif

	//UART
	`ifdef IMPLEMENT_UART
	assign uart_rx = `HIGH;
	//assign uart_rx = uart_tx;
	//UART
	uart_rx uart_model (
		.clk	  (chip_top.clk),
		.reset	  (chip_top.chip_reset),
		//rx
		.rx_busy  (rx_busy),
		.rx_end	  (rx_end),
		.rx_data  (rx_data),
		//tx Signal
		.rx		  (uart_tx)
	);

	//uart when you receive data, print it 8bits which is 1 byte
	always @(posedge chip_top.clk) begin
		if (rx_end == `ENABLE) begin
			$write("%c", rx_data);
		end
	end
	`endif


	initial begin
		# 0 begin
			clk_ref	 <= `HIGH;			
			reset_sw <= `RESET_ENABLE;//1'b0
		end
		# ( STEP / 2 )
		# ( STEP / 4 ) 
		# ( STEP * 20 ) begin
			reset_sw <= `RESET_DISABLE;//1'b1
		end
		# ( STEP * `SIM_CYCLE ) begin //how long it will run, then ends
			$finish;
		end
	end


endmodule
