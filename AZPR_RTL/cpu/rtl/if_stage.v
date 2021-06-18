/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/cpu.h"
module if_stage (
	input  wire				   clk,
	input  wire				   reset,
	/********** SPM**********/
	input  wire [`WordDataBus] 	spm_rd_data, 	//data read from SPM
	output wire [`WordAddrBus] 	spm_addr,			//data address to SPM
	output wire				   				spm_as_,			//address select signal to SPM
	output wire				   				spm_rw,				//read/write signal to SPM
	output wire [`WordDataBus] 	spm_wr_data, 	//data write to SPM
	/********** bus related master 0**********/
	input  wire [`WordDataBus] 	bus_rd_data, 	//busy read data
	input  wire				   				bus_rdy_,			//busy ready
	input  wire				   				bus_grnt_,		//bus grant
	output wire				   				bus_req_,			//request bus
	output wire [`WordAddrBus] 	bus_addr,			//request address
	output wire				   				bus_as_,			//request address select
	output wire				   				bus_rw,				//bus read/write
	output wire [`WordDataBus] 	bus_wr_data, 	//bus write data
	/********** pipeline control**********/
	input  wire				   				stall,				// delay from ctrl module
	input  wire				   				flush,				// flush from ctrl module
	input  wire [`WordAddrBus] 	new_pc,				// new pc from ctrl module when you flush
	input  wire				   				br_taken,			// branch from id_stage module
	input  wire [`WordAddrBus] 	br_addr,			// branch address from id_stage module
	output wire				   				busy,					// bus busy
	/********** IF/ID**********/
	output wire [`WordAddrBus] 	if_pc,				// pc register to id_stage
	output wire [`WordDataBus] 	if_insn,			// instruction data to id_stage
	output wire				   				if_en					// instruction enable to id_stage
);

	/********** connect bus_if to if_reg **********/
	wire [`WordDataBus]		   insn;

	/**********bus related**********/
	bus_if bus_if (
		.clk		 			(clk),
		.reset		 		(reset),
		/********** pipeline control from ctrl module **********/
		.stall		 		(stall),						// input from ctrl module
		.flush		 		(flush),						// input from ctrl module
		.busy		 			(busy),							// output busy
		/********** CPU get data and write data either from SPM or BUS as following**********/
		.addr		 			(if_pc),						// input will read this pc address from if_reg module
		.as_		 			(`ENABLE_),					// input 1'b0 address select always ENABLE_
		.rw			 			(`READ),						// input read only
		.wr_data	 		(`WORD_DATA_W'h0),	// input all 0's because read only
		.rd_data	 		(insn),							// ouput read data to if_reg module
		/********** SPM related above will use this **********/
		.spm_rd_data 	(spm_rd_data),
		.spm_addr	 		(spm_addr),
		.spm_as_	 		(spm_as_),
		.spm_rw		 		(spm_rw),
		.spm_wr_data 	(spm_wr_data),
		/********** bus related above will use this**********/
		.bus_rd_data 	(bus_rd_data),
		.bus_rdy_	 		(bus_rdy_),
		.bus_grnt_	 	(bus_grnt_),
		.bus_req_	 		(bus_req_),
		.bus_addr	 		(bus_addr),
		.bus_as_	 		(bus_as_),
		.bus_rw		 		(bus_rw),
		.bus_wr_data 	(bus_wr_data)
	);

	/********** IF register **********/
	//if_reg will change if_pc, pause, flush to new_pc,branch address, increase +1,etc
	if_reg if_reg (
		.clk		 			(clk),
		.reset				(reset),
		/********** **********/
		.insn		 			(insn),						// instruction from bus_if module (SPM or bus slaves)
		/********** pipeline control from ctrl module**********/
		.stall		 		(stall),					// from ctrl module
		.flush		 		(flush),					// from ctrl module
		.new_pc		 		(new_pc),					// from ctrl module
		.br_taken	 		(br_taken),				// from ID stage back to here
		.br_addr	 		(br_addr),				// from ID stage back to here
		/********** IF/ID**********/
		.if_pc		 		(if_pc),					// to bus to access bus_if module above to read next instruction
		.if_insn	 		(if_insn),				// to ID Stage instruction data
		.if_en		 		(if_en)						// to ID Stage pipeline is enable flag
	);

endmodule
