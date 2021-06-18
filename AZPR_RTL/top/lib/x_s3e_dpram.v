/************************************/
/*this module is for SIMULATION only*/
/************************************/
/**********basic headers*************/
`include "../include/nettype.h"
`include "../include/stddef.h"
`include "../include/global_config.h"
/**********spm headers*************/
`include "../../cpu/include/spm.h"
/**********this module is only for simulation, in real project we need to use FPGA ip**********/
module x_s3e_dpram (
	//port A
	input  wire				   clka,  		//system clock for port a
	input  wire [`SpmAddrBus]  addra, 	//ram address 12bits for port a
	input  wire [`WordDataBus] dina,  	//data 32bits for port a
	input  wire				   wea,	  		//write enable for port a
	output reg	[`WordDataBus] douta, 	//output ram data 32 bits for port a
	//port B
	input  wire				   clkb,  		//system clock for port b
	input  wire [`SpmAddrBus]  addrb, 	//ram address 12bits for port b
	input  wire [`WordDataBus] dinb,  	//data 32bits for port b
	input  wire				   web,	  		//write enable for port b
	output reg	[`WordDataBus] doutb  	//output ram data 32 bits for port b
);

	//this is like a array with aaaa[][]
	reg [`WordDataBus] mem [0:`SPM_DEPTH-1]; //SPM_DEPTH  4096

	always @(posedge clka) begin
		//read a, if b writing data in the meanwhile, a is accessing the same address data, data from b port will give to a directly
		if ((web == `ENABLE) && (addra == addrb)) begin
			douta	  <= #1 dinb;
		end else begin
			douta	  <= #1 mem[addra];
		end
		//write a
		if (wea == `ENABLE) begin
			mem[addra]<= #1 dina;
		end
	end

	always @(posedge clkb) begin
		//read b, if a writing data in the meanwhile, b is accessing the same address data, data from a port will give to b directly
		if ((wea == `ENABLE) && (addrb == addra)) begin
			doutb	  <= #1 dina;
		end else begin
			doutb	  <= #1 mem[addrb];
		end
		//write b
		if (web == `ENABLE) begin
			mem[addrb]<= #1 dinb;
		end
	end

endmodule
