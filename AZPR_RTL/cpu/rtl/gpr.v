/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/cpu.h"

module gpr (
	input  wire				   clk,
	input  wire				   reset,
	/********** gpr read 0 **********/
	input  wire [`RegAddrBus]  rd_addr_0,
	output wire [`WordDataBus] rd_data_0,
	/********** gpr read 1 **********/
	input  wire [`RegAddrBus]  rd_addr_1,
	output wire [`WordDataBus] rd_data_1,
	/********** gpr write **********/
	input  wire				   we_,
	input  wire [`RegAddrBus]  wr_addr,
	input  wire [`WordDataBus] wr_data
);

	/********** gpr **********/
	reg [`WordDataBus]		   gpr [`REG_NUM-1:0]; // 32
	integer					   i;

	/********** (Write After Read) **********/
	//gpr 0, if you write and read same register, rd_data_0 = wr_data
	assign rd_data_0 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_0)) ?
					   wr_data : gpr[rd_addr_0];
	//gpr 1，if you write and read same register, rd_data_1 = wr_data
	assign rd_data_1 = ((we_ == `ENABLE_) && (wr_addr == rd_addr_1)) ?
					   wr_data : gpr[rd_addr_1];

	always @ (posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			for (i = 0; i < `REG_NUM; i = i + 1) begin
				gpr[i]		 <= #1 `WORD_DATA_W'h0;
			end
		end else begin
			if (we_ == `ENABLE_) begin
				gpr[wr_addr] <= #1 wr_data;
			end
		end
	end

endmodule
