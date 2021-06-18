/**********basic headers**********/
`include "../../../top/include/nettype.h"
`include "../../../top/include/stddef.h"
`include "../../../top/include/global_config.h"
/**********uart header**********/
`include "../include/uart.h"

module uart_tx (
	input  wire				   clk,		 //system clock
	input  wire				   reset,	 //system reset
	/********** tx related**********/
	input  wire				   tx_start, 	//
	input  wire [`ByteDataBus] tx_data,	//
	output wire				   tx_busy,	 	//
	output reg				   tx_end,	 	//
	/********** UART tx**********/
	output reg				   tx		 		//UART TX pin
);

	reg [`UartStateBus]		   state;	 	 //status
	reg [`UartDivCntBus]	   div_cnt;	 //divider count
	reg [`UartBitCntBus]	   bit_cnt;	 //bit count
	reg [`ByteDataBus]		   sh_reg;	 // shit register

	/**********busy or not**********/
	assign tx_busy = (state == `UART_STATE_TX) ? `ENABLE : `DISABLE;

	/********** send **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin//reset
			state	<= #1 `UART_STATE_IDLE;
			div_cnt <= #1 `UART_DIV_RATE;
			bit_cnt <= #1 `UART_BIT_CNT_START;
			sh_reg	<= #1 `BYTE_DATA_W'h0;
			tx_end	<= #1 `DISABLE;
			tx		<= #1 `UART_STOP_BIT;
		end else begin
			//
			case (state)
				`UART_STATE_IDLE : begin //IDLE
					if (tx_start == `ENABLE) begin //start sending
						state	<= #1 `UART_STATE_TX;
						sh_reg	<= #1 tx_data;
						tx		<= #1 `UART_START_BIT;
					end
					tx_end	<= #1 `DISABLE;
				end
				`UART_STATE_TX	 : begin //in sending
					//baudrate control
					if (div_cnt == {`UART_DIV_CNT_W{1'b0}}) begin //couter arrives
						//next bit
						case (bit_cnt)
							`UART_BIT_CNT_MSB  : begin //send stop
								bit_cnt <= #1 `UART_BIT_CNT_STOP;
								tx		<= #1 `UART_STOP_BIT;
							end
							`UART_BIT_CNT_STOP : begin //send complete
								state	<= #1 `UART_STATE_IDLE;
								bit_cnt <= #1 `UART_BIT_CNT_START;
								tx_end	<= #1 `ENABLE;
							end
							default			   : begin //send data here
								bit_cnt <= #1 bit_cnt + 1'b1;
								sh_reg	<= #1 sh_reg >> 1'b1;
								tx		<= #1 sh_reg[`LSB];
							end
						endcase
						div_cnt <= #1 `UART_DIV_RATE;
					end else begin //backward counting
						div_cnt <= #1 div_cnt - 1'b1 ;
					end
				end
			endcase
		end
	end

endmodule
