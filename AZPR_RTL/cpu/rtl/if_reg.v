/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
module if_reg (
	input  wire				   				clk,
	input  wire				   				reset,
	/********** read data **********/
	input  wire [`WordDataBus] 	insn,
	/********** pipeline ctrl module**********/
	input  wire				   				stall,	   	// delay
	input  wire				   				flush,	   	// flush
	input  wire [`WordAddrBus] 	new_pc,	 		// new pc 30
	input  wire				   				br_taken,   // branch
	input  wire [`WordAddrBus] 	br_addr,	  // branch address 30
	/********** IF/ID **********/
	output reg	[`WordAddrBus] 	if_pc,	   	//pc 30
	output reg	[`WordDataBus] 	if_insn,	 	//32
	output reg				   				if_en	   		//
);

	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			if_pc	<= #1 `RESET_VECTOR;//30'h0
			if_insn <= #1 `ISA_NOP;//No Operation
			if_en	<= #1 `DISABLE;//0
		end else begin
			/* update pipe line registers*/
			if (stall == `DISABLE) begin
				if (flush == `ENABLE) begin							// flush and update if_pc to new_pc
					if_pc	<= #1 new_pc;
					if_insn <= #1 `ISA_NOP;
					if_en	<= #1 `DISABLE;
				end else if (br_taken == `ENABLE) begin // need to branch now.pc to branch address
					if_pc	<= #1 br_addr;
					if_insn <= #1 insn;
					if_en	<= #1 `ENABLE;
				end else begin													// normal pc update to next instruction address,+1
					if_pc	<= #1 if_pc + 1'd1;
					if_insn <= #1 insn;
					if_en	<= #1 `ENABLE;
				end
			end
		end
	end

endmodule
