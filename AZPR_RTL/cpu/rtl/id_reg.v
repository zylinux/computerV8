/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
//this module will set many singals to ID/EX depends on decode results
module id_reg (
	input  wire				   clk,
	input  wire				   reset,
	/********** decode results **********/
	input  wire [`AluOpBus]	   	alu_op,		   	// ALU o
	input  wire [`WordDataBus] 	alu_in_0,	   	// ALU  0
	input  wire [`WordDataBus] 	alu_in_1,	   	// ALU 1
	input  wire				   				br_flag,		  // branch flag
	input  wire [`MemOpBus]	   	mem_op,		   	// memory op
	input  wire [`WordDataBus] 	mem_wr_data,	// memory write data
	input  wire [`CtrlOpBus]   	ctrl_op,		  // control op
	input  wire [`RegAddrBus]  	dst_addr,	   	// gpr write address
	input  wire				   				gpr_we_,		  // gpr write
	input  wire [`IsaExpBus]   	exp_code,	   	// expception code
	/********** pipeline control input **********/
	input  wire				   stall,		   					// delay
	input  wire				   flush,		   					// flush
	/********** IF/ID input **********/
	input  wire [`WordAddrBus] 	if_pc,		   	// from if stage
	input  wire				   				if_en,		   	// from if stage
	/********** to ID/EX **********/
	output reg	[`WordAddrBus] 	id_pc,		   		// output id_pc
	output reg				   				id_en,		   		// output id_en
	output reg	[`AluOpBus]	   	id_alu_op,	   	// ALU op
	output reg	[`WordDataBus] 	id_alu_in_0,	  // ALU  0
	output reg	[`WordDataBus] 	id_alu_in_1,	  // ALU  1
	output reg				   				id_br_flag,	    //id branch flag
	output reg	[`MemOpBus]	   	id_mem_op,	   	//id memory op
	output reg	[`WordDataBus] 	id_mem_wr_data,	//id memory write data
	output reg	[`CtrlOpBus]   	id_ctrl_op,	  	//id control op
	output reg	[`RegAddrBus]  	id_dst_addr,	  //id gpr write address
	output reg				   				id_gpr_we_,	   	//id gpr write
	output reg [`IsaExpBus]	   	id_exp_code	  	//id expception code
);

	/********** pipeline reset **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			id_pc		   <= #1 `WORD_ADDR_W'h0;
			id_en		   <= #1 `DISABLE;
			id_alu_op	   <= #1 `ALU_OP_NOP;
			id_alu_in_0	   <= #1 `WORD_DATA_W'h0;
			id_alu_in_1	   <= #1 `WORD_DATA_W'h0;
			id_br_flag	   <= #1 `DISABLE;
			id_mem_op	   <= #1 `MEM_OP_NOP;
			id_mem_wr_data <= #1 `WORD_DATA_W'h0;
			id_ctrl_op	   <= #1 `CTRL_OP_NOP;
			id_dst_addr	   <= #1 `REG_ADDR_W'd0;
			id_gpr_we_	   <= #1 `DISABLE_;
			id_exp_code	   <= #1 `ISA_EXP_NO_EXP;
		end else begin
			/* update pipeline */
			if (stall == `DISABLE) begin
				if (flush == `ENABLE) begin // flush
				   id_pc		  <= #1 `WORD_ADDR_W'h0;
				   id_en		  <= #1 `DISABLE;
				   id_alu_op	  <= #1 `ALU_OP_NOP;
				   id_alu_in_0	  <= #1 `WORD_DATA_W'h0;
				   id_alu_in_1	  <= #1 `WORD_DATA_W'h0;
				   id_br_flag	  <= #1 `DISABLE;
				   id_mem_op	  <= #1 `MEM_OP_NOP;
				   id_mem_wr_data <= #1 `WORD_DATA_W'h0;
				   id_ctrl_op	  <= #1 `CTRL_OP_NOP;
				   id_dst_addr	  <= #1 `REG_ADDR_W'd0;
				   id_gpr_we_	  <= #1 `DISABLE_;
				   id_exp_code	  <= #1 `ISA_EXP_NO_EXP;
				end else begin				// next
				   id_pc		  <= #1 if_pc;
				   id_en		  <= #1 if_en;
				   id_alu_op	  <= #1 alu_op;
				   id_alu_in_0	  <= #1 alu_in_0;
				   id_alu_in_1	  <= #1 alu_in_1;
				   id_br_flag	  <= #1 br_flag;
				   id_mem_op	  <= #1 mem_op;
				   id_mem_wr_data <= #1 mem_wr_data;
				   id_ctrl_op	  <= #1 ctrl_op;
				   id_dst_addr	  <= #1 dst_addr;
				   id_gpr_we_	  <= #1 gpr_we_;
				   id_exp_code	  <= #1 exp_code;
				end
			end
		end
	end

endmodule
