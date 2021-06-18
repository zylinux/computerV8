/**********basic headers**********/
`include "../../../top/include/nettype.h"
`include "../../../top/include/stddef.h"
`include "../../../top/include/global_config.h"
/**********uart header**********/
`include "../include/uart.h"

module uart_ctrl (
	/**********system**********/
	input  wire				   clk,
	input  wire				   reset,
	/**********bus**********/
	input  wire				   cs_,//chip select
	input  wire				   as_,//address select
	input  wire				   rw,//write read
	input  wire [`UartAddrBus] addr,	 //
	input  wire [`WordDataBus] wr_data,	 //
	output reg	[`WordDataBus] rd_data,	 //
	output reg				   rdy_,	 //module is ready
	/**********irq**********/
	output reg				   irq_rx,	 // rx interrupt
	output reg				   irq_tx,	 // tx interrupt
	/********************/
	//rx
	input  wire				   rx_busy,	 //rx is busy ?
	input  wire				   rx_end,	 //rx is end ?
	input  wire [`ByteDataBus] rx_data,	 //rx data received in 8bit
	//tx
	input  wire				   tx_busy,	 // tx is busy ?
	input  wire				   tx_end,	 // tx is end ?
	output reg				   tx_start, // tx start ?
	output reg	[`ByteDataBus] tx_data	 //data to send in 8bit
);

	/**********rx**********/
	reg [`ByteDataBus]		   rx_buf;	 //receive buff

	/********** UART**********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/*init */
			rd_data	 <= #1 `WORD_DATA_W'h0;
			rdy_	 <= #1 `DISABLE_;
			irq_rx	 <= #1 `DISABLE;
			irq_tx	 <= #1 `DISABLE;
			rx_buf	 <= #1 `BYTE_DATA_W'h0;
			tx_start <= #1 `DISABLE;
			tx_data	 <= #1 `BYTE_DATA_W'h0;
	   end else begin
			/*address and ship are selected*/
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
				rdy_	 <= #1 `ENABLE_;
			end else begin
				rdy_	 <= #1 `DISABLE_;
			end
			//read
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `READ)) begin
				case (addr)
					`UART_ADDR_STATUS	 : begin //
						rd_data	 <= #1 {{`WORD_DATA_W-4{1'b0}},
										tx_busy, rx_busy, irq_tx, irq_rx};
					end
					`UART_ADDR_DATA		 : begin //
						rd_data	 <= #1 {{`BYTE_DATA_W*2{1'b0}}, rx_buf};
					end
				endcase
			end else begin
				rd_data	 <= #1 `WORD_DATA_W'h0;
			end
			//write
			// control register 0 : if sending finished, tx irq set
			if (tx_end == `ENABLE) begin
				irq_tx<= #1 `ENABLE;
			end else if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
						 (rw == `WRITE) && (addr == `UART_ADDR_STATUS)) begin
				irq_tx<= #1 wr_data[`UartCtrlIrqTx];
			end
			// control register 0 : if receiving finished, rx irq set
			if (rx_end == `ENABLE) begin
				irq_rx<= #1 `ENABLE;
			end else if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
						 (rw == `WRITE) && (addr == `UART_ADDR_STATUS)) begin
				irq_rx<= #1 wr_data[`UartCtrlIrqRx];
			end
			// control register 1
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) &&
				(rw == `WRITE) && (addr == `UART_ADDR_DATA)) begin //send data
				tx_start <= #1 `ENABLE;
				tx_data	 <= #1 wr_data[`BYTE_MSB:`LSB];
			end else begin
				tx_start <= #1 `DISABLE;
				tx_data	 <= #1 `BYTE_DATA_W'h0;
			end
			//receive data
			if (rx_end == `ENABLE) begin
				rx_buf	 <= #1 rx_data;
			end
		end
	end

endmodule
