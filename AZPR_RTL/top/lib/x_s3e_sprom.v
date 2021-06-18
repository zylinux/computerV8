/************************************/
/*this module is for SIMULATION only*/
/************************************/
/**********basic headers*************/
`include "../include/nettype.h"
`include "../include/stddef.h"
`include "../include/global_config.h"
/**********rom headers*************/
`include "../../io/rom/include/rom.h"
/**********this module is only for simulation, in real project please use FPGA IP**********/
module x_s3e_sprom (
	input wire				  clka,	 	//system clock
	input wire [`RomAddrBus]  addra, //rom address 11 bits
	output reg [`WordDataBus] douta	//rom data 32bits
);
	/**********like a array store data**********/
	reg [`WordDataBus] mem [0:`ROM_DEPTH-1];//ROM_DEPTH 2048
	/**********every postedge clock, output data**********/
	always @(posedge clka) begin
		douta <= #1 mem[addra];
	end
endmodule
