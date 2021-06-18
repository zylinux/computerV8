/**********basic headers**********/
`include "../../../top/include/nettype.h"
`include "../../../top/include/stddef.h"
`include "../../../top/include/global_config.h"
/**********rom header**********/
`include "../include/rom.h"
/**********ROM module(use IP from different FPGA)**********/
module rom (
	/**********input**********/
	input  wire				   clk,		//system clock
	input  wire				   reset,	//system reset
	/********************/
	input  wire				   cs_,		//chip select
	input  wire				   as_,		//address select
	input  wire [`RomAddrBus]  addr,	//innput ROM address we want to access
	output wire [`WordDataBus] rd_data, //output ROM data to bus
	output reg				   rdy_		//output tell outside if ROM is ready
);


`ifdef SIMULATION
	x_s3e_sprom x_s3e_sprom (
		.clka  (clk),
		.addra (addr),
		.douta (rd_data)
	);
`else
	altera_sprom	x_s3e_sprom (
	.address ( addr ),
	.clock ( clk ),
	.q ( rd_data )
	);
`endif

	always @(posedge clk or `RESET_EDGE reset) begin//RESET_EDGE(negedge)
		if (reset == `RESET_ENABLE) begin//RESET_ENABLE(1'b0)
			rdy_ <= #1 `DISABLE_;//DISABLE_ (1'b1)
		end else begin
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin//ENABLE_(1'b0)
				rdy_ <= #1 `ENABLE_;
			end else begin
				rdy_ <= #1 `DISABLE_;
			end
		end
	end

endmodule
