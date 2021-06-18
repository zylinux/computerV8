/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
module mem_reg (
	input  wire				   						clk,
	input  wire				   						reset,
	/********** memory access results **********/
	input  wire [`WordDataBus] 			out,			 			// from memory
	input  wire				   						miss_align,	 		// miss aligned
	/********** pipeline ctrl **********/
	input  wire				   						stall,		 			// delay
	input  wire				   						flush,		 			// flush
	/********** EX/MEM**********/
	input  wire [`WordAddrBus] 			ex_pc,		 			// ex pc
	input  wire				   						ex_en,		 			// ex pipeline enable
	input  wire				   						ex_br_flag,	 		// ex branch flag
	input  wire [`CtrlOpBus]   			ex_ctrl_op,	 		// ex control register op
	input  wire [`RegAddrBus]  			ex_dst_addr,	 	// ex gpr write address
	input  wire				   						ex_gpr_we_,	 		// ex gpr write
	input  wire [`IsaExpBus]   			ex_exp_code,	 	// ex expception code
	/********** MEM/WB**********/
	output reg	[`WordAddrBus] 			mem_pc,		 			// memory pc
	output reg				   						mem_en,		 			// memory pipeline enable
	output reg				   						mem_br_flag,	 	// memory branch flag
	output reg	[`CtrlOpBus]   			mem_ctrl_op,	 	// memory control register op
	output reg	[`RegAddrBus]  			mem_dst_addr, 	// memory gpr write address
	output reg				  		 				mem_gpr_we_,	 	// memory gpr write
	output reg	[`IsaExpBus]   			mem_exp_code, 	// memory expception code
	output reg	[`WordDataBus] 			mem_out		 			// memory out
);

	/********** pipeline registers **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			mem_pc		 <= #1 `WORD_ADDR_W'h0;
			mem_en		 <= #1 `DISABLE;
			mem_br_flag	 <= #1 `DISABLE;
			mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
			mem_dst_addr <= #1 `REG_ADDR_W'h0;
			mem_gpr_we_	 <= #1 `DISABLE_;
			mem_exp_code <= #1 `ISA_EXP_NO_EXP;
			mem_out		 <= #1 `WORD_DATA_W'h0;
		end else begin
			if (stall == `DISABLE) begin
				/* update */
				if (flush == `ENABLE) begin				  // flush
					mem_pc		 <= #1 `WORD_ADDR_W'h0;
					mem_en		 <= #1 `DISABLE;
					mem_br_flag	 <= #1 `DISABLE;
					mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
					mem_dst_addr <= #1 `REG_ADDR_W'h0;
					mem_gpr_we_	 <= #1 `DISABLE_;
					mem_exp_code <= #1 `ISA_EXP_NO_EXP;
					mem_out		 <= #1 `WORD_DATA_W'h0;
				end else if (miss_align == `ENABLE) begin // miss aligned
					mem_pc		 <= #1 ex_pc;
					mem_en		 <= #1 ex_en;
					mem_br_flag	 <= #1 ex_br_flag;
					mem_ctrl_op	 <= #1 `CTRL_OP_NOP;
					mem_dst_addr <= #1 `REG_ADDR_W'h0;
					mem_gpr_we_	 <= #1 `DISABLE_;
					mem_exp_code <= #1 `ISA_EXP_MISS_ALIGN;
					mem_out		 <= #1 `WORD_DATA_W'h0;
				end else begin							  // next one
					mem_pc		 <= #1 ex_pc;
					mem_en		 <= #1 ex_en;
					mem_br_flag	 <= #1 ex_br_flag;
					mem_ctrl_op	 <= #1 ex_ctrl_op;
					mem_dst_addr <= #1 ex_dst_addr;
					mem_gpr_we_	 <= #1 ex_gpr_we_;
					mem_exp_code <= #1 ex_exp_code;
					mem_out		 <= #1 out;
				end
			end
		end
	end

endmodule
