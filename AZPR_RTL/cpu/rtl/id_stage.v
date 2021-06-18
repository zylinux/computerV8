/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
module id_stage (
	input  wire					 					clk,
	input  wire					 					reset,
	/********** GPR**********/
	input  wire [`WordDataBus]	 	gpr_rd_data_0,	 		//	0 gpr data
	input  wire [`WordDataBus]	 	gpr_rd_data_1,	 		//	1 gpr data
	output wire [`RegAddrBus]	 		gpr_rd_addr_0,	 		//	0 register address
	output wire [`RegAddrBus]	 		gpr_rd_addr_1,	 		//	1 register address
	/********** Data pass-through **********/
	// EX
	input  wire					 					ex_en,							// ex
	input  wire [`WordDataBus]		ex_fwd_data,	 			// ex Data pass-through after ALU caculation done , also output back here
	input  wire [`RegAddrBus]	 		ex_dst_addr,	 			// ex gpr address
	input  wire					 					ex_gpr_we_,	 				// ex gpr write
	// MEM
	input  wire [`WordDataBus]		mem_fwd_data,	 			//Data pass-through when the data access the MEM , also output back here
	/********** from ctrl register **********/
	input  wire [`CpuExeModeBus] 	exe_mode,		 				// cpu mode
	input  wire [`WordDataBus]	 	creg_rd_data,	 			// ctrl register
	output wire [`RegAddrBus]	 		creg_rd_addr,	 			// ctrl register address
	/********** ctrl **********/
	input  wire					 					stall,			 				// delay
	input  wire					 					flush,			 				// flush
	output wire [`WordAddrBus]	 	br_addr,		 				// branch address
	output wire					 					br_taken,		 				// branch taken
	output wire					 					ld_hazard,				 	// output load hazard to IF/ID and ID/EX
	/********** IF/ID from IF stage**********/
	input  wire [`WordAddrBus]	 	if_pc,							//input from if stage
	input  wire [`WordDataBus]	 	if_insn,						//input from if stage
	input  wire					 					if_en,							//input from if stage
	/********** ID/EX to EX stage**********/
	output wire [`WordAddrBus]	 	id_pc,			 				// id pc
	output wire					 					id_en,			 				// id pipelne enable
	output wire [`AluOpBus]		 		id_alu_op,					// id ALU op
	output wire [`WordDataBus]	 	id_alu_in_0,				// id ALU 0
	output wire [`WordDataBus]	 	id_alu_in_1,				// id ALU 1
	output wire					 					id_br_flag,	 				// id branch flag
	output wire [`MemOpBus]		 		id_mem_op,					// id memory op
	output wire [`WordDataBus]	 	id_mem_wr_data, 		// id memory data
	output wire [`CtrlOpBus]	 		id_ctrl_op,	 				// id ctrl op
	output wire [`RegAddrBus]	 		id_dst_addr,	 			//	id GPR address
	output wire					 					id_gpr_we_,	 				//	id GPR write
	output wire [`IsaExpBus]	 		id_exp_code	 				//	id
);

	wire  [`AluOpBus]			 		alu_op;		 							// ALU op
	wire  [`WordDataBus]		 	alu_in_0;		 						// ALU  0
	wire  [`WordDataBus]		 	alu_in_1;		 						// ALU  1
	wire						 					br_flag;		 						// O
	wire  [`MemOpBus]			 		mem_op;		 							//
	wire  [`WordDataBus]		 	mem_wr_data;	 					//
	wire  [`CtrlOpBus]			 	ctrl_op;		 						//
	wire  [`RegAddrBus]			 	dst_addr;		 						// GPR
	wire						 					gpr_we_;		 						// GPR
	wire  [`IsaExpBus]			 	exp_code;		 						// expception code

	decoder decoder (
		/********** IF/ID from IF**********/
		.if_pc					(if_pc),								//input pc
		.if_insn				(if_insn),							//input instruction
		.if_en					(if_en),								//input pipeline enable
		/********** GPR **********/
		.gpr_rd_data_0	(gpr_rd_data_0),  			//input 0
		.gpr_rd_data_1	(gpr_rd_data_1),  			//input 1
		.gpr_rd_addr_0	(gpr_rd_addr_0),  			//output 0
		.gpr_rd_addr_1	(gpr_rd_addr_1),  			//output 1
		/********** Data pass-through **********/
		// ID previous Data pass-through
		.id_en					(id_en),		  					//input id pipeline enable input
		.id_dst_addr		(id_dst_addr),	  			//input gpr destination address input
		.id_gpr_we_			(id_gpr_we_),	  				//input gpr write input
		.id_mem_op			(id_mem_op),	  				//input memory operation input
  	// EX afterward Data pass-through
		.ex_en					(ex_en),		  					//input ex pipeline enable input
		.ex_fwd_data		(ex_fwd_data),	  			//input Data pass-through input
		.ex_dst_addr		(ex_dst_addr),	  			//input gpr write input
		.ex_gpr_we_			(ex_gpr_we_),	  				//input memory operation input
		// MEM
		.mem_fwd_data		(mem_fwd_data),	  			//input Data pass-through
		/********** control register from ctrl module **********/
		.exe_mode				(exe_mode),		  				//input cpu mode
		.creg_rd_data		(creg_rd_data),	  			//input data
		.creg_rd_addr		(creg_rd_addr),	  			//output address
		/********** decode results all output to id_reg**********/
		.alu_op					(alu_op),		  					//output ALU op
		.alu_in_0				(alu_in_0),		  				//output ALU  0
		.alu_in_1				(alu_in_1),		  				//output ALU  1
		.br_addr				(br_addr),		  				//output branch address
		.br_taken				(br_taken),		  				//output branch taken ?
		.br_flag				(br_flag),		  				//output branch flag
		.mem_op					(mem_op),		  					//output memory op
		.mem_wr_data		(mem_wr_data),	  			//output memory data
		.ctrl_op				(ctrl_op),		  				//output ctrl op
		.dst_addr				(dst_addr),		  				//output gpr address
		.gpr_we_				(gpr_we_),		  				//output gpr write
		.exp_code				(exp_code),		  				//output expception code
		.ld_hazard			(ld_hazard)		  				//output load hazard
	);

	/********** id reg**********/
	//take above decoder results to process, then send out to next stage
	id_reg id_reg (
		.clk						(clk),
		.reset					(reset),
		/********** connect to decoder all input from above **********/
		.alu_op					(alu_op),		  				// input ALU op
		.alu_in_0				(alu_in_0),		  			// input ALU 0
		.alu_in_1				(alu_in_1),		  			// input ALU 1
		.br_flag				(br_flag),		  			// input branch flag
		.mem_op					(mem_op),		  				// input memory op
		.mem_wr_data		(mem_wr_data),				// input memory data
		.ctrl_op				(ctrl_op),		  			// input ctrl op
		.dst_addr				(dst_addr),		  			// input ctrl address
		.gpr_we_				(gpr_we_),		  			// input gpr write
		.exp_code				(exp_code),		  			// input expception code
		/********** input from ctrl module enable **********/
		.stall					(stall),		  				// delay
		.flush					(flush),		  				// flush
		/********** IF/ID input from if_stage module**********/
		.if_pc					(if_pc),		  				// input if pc
		.if_en					(if_en),		  				// input if en
		/********** ID/EX output to (((next ex_stage)))**********/
		.id_pc					(id_pc),		  				// output id pc
		.id_en					(id_en),		  				// output id en
		.id_alu_op			(id_alu_op),	  			// output ALU op
		.id_alu_in_0		(id_alu_in_0),	  		// output id ALU 0
		.id_alu_in_1		(id_alu_in_1),	  		// output id ALU  1
		.id_br_flag			(id_br_flag),	  			// output id branch flag
		.id_mem_op			(id_mem_op),	  			// output id memory op
		.id_mem_wr_data (id_mem_wr_data), 	// output id memory write
		.id_ctrl_op			(id_ctrl_op),	  			// output id ctrl op
		.id_dst_addr		(id_dst_addr),	  		// output id gpr address
		.id_gpr_we_			(id_gpr_we_),	  			// output id gpr write
		.id_exp_code		(id_exp_code)	  			// output id expception code
	);

endmodule
