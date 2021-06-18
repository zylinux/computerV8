/**********basic headers**********/
`include "../../../top/include/nettype.h"
`include "../../../top/include/stddef.h"
`include "../../../top/include/global_config.h"
/**********uart header**********/
`include "../include/uart.h"

module uart_rx (
	input  wire				   clk,
	input  wire				   reset,
	/**********status**********/
	output wire				   rx_busy,
	output reg				   rx_end,
	output reg	[`ByteDataBus] rx_data,
	/********** UART rx pin**********/
	input  wire				   rx		// UART rx pin
);

	reg [`UartStateBus]		   state;	 //status
	reg [`UartDivCntBus]	   div_cnt;	 //divider count
	reg [`UartBitCntBus]	   bit_cnt;	 //bit count

	assign rx_busy = (state != `UART_STATE_IDLE) ? `ENABLE : `DISABLE;

	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin//reset
			rx_end	<= #1 `DISABLE;
			rx_data <= #1 `BYTE_DATA_W'h0;
			state	<= #1 `UART_STATE_IDLE;
			div_cnt <= #1 `UART_DIV_RATE / 2;
			bit_cnt <= #1 `UART_BIT_CNT_W'h0;
		end else begin
			//receive
			case (state)
				`UART_STATE_IDLE : begin //IDLE
					if (rx == `UART_START_BIT) begin //start
						state	<= #1 `UART_STATE_RX;
					end
					rx_end	<= #1 `DISABLE;
				end
				`UART_STATE_RX	 : begin //receiving
					if (div_cnt == {`UART_DIV_CNT_W{1'b0}}) begin //baudrate count
						//
						case (bit_cnt)
							`UART_BIT_CNT_STOP	: begin //receive stop
								state	<= #1 `UART_STATE_IDLE;
								bit_cnt <= #1 `UART_BIT_CNT_START;
								div_cnt <= #1 `UART_DIV_RATE / 2;
								//error detecting
								if (rx == `UART_STOP_BIT) begin
									rx_end	<= #1 `ENABLE;
								end
							end
							default				: begin //receiving data
								rx_data <= #1 {rx, rx_data[`BYTE_MSB:`LSB+1]};
								bit_cnt <= #1 bit_cnt + 1'b1;
								div_cnt <= #1 `UART_DIV_RATE;
							end
						endcase
					end else begin //backward count
						div_cnt <= #1 div_cnt - 1'b1;
					end
				end
			endcase
		end
	end

endmodule
