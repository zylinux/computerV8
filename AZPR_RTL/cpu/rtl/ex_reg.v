/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"

module ex_reg (
	input  wire				   				clk,
	input  wire				   				reset,
	/********** ALU output results **********/
	input  wire [`WordDataBus] 	alu_out,		   	// alu out
	input  wire				   				alu_of,		   		// alu overflow
	/********** ctrl **********/
	input  wire				   				stall,		   		// delay
	input  wire				   				flush,		   		// flush
	input  wire				   				int_detect,	   	// interrupt detect
	/********** ID/EX **********/
	input  wire [`WordAddrBus] 	id_pc,		   		// �v���O�����J�E���^
	input  wire				   				id_en,		   		// �p�C�v���C���f�[�^�̗L��
	input  wire				   				id_br_flag,	   	// �����t���O
	input  wire [`MemOpBus]	   	id_mem_op,	   	// �������I�y���[�V����
	input  wire [`WordDataBus] 	id_mem_wr_data, // �������������݃f�[�^
	input  wire [`CtrlOpBus]   	id_ctrl_op,	   	// ���䃌�W�X�^�I�y���[�V����
	input  wire [`RegAddrBus]  	id_dst_addr,	 	// �ėp���W�X�^�������݃A�h���X
	input  wire				   				id_gpr_we_,	   	// �ėp���W�X�^�������ݗL��
	input  wire [`IsaExpBus]   	id_exp_code,	 	// ���O�R�[�h
	/********** EX/MEM **********/
	output reg	[`WordAddrBus] 	ex_pc,		   		// �v���O�����J�E���^
	output reg				   				ex_en,		   		// �p�C�v���C���f�[�^�̗L��
	output reg				   				ex_br_flag,	   	// �����t���O
	output reg	[`MemOpBus]	   	ex_mem_op,	   	// �������I�y���[�V����
	output reg	[`WordDataBus] 	ex_mem_wr_data, // �������������݃f�[�^
	output reg	[`CtrlOpBus]   	ex_ctrl_op,	   	// ���䃌�W�X�^�I�y���[�V����
	output reg	[`RegAddrBus]  	ex_dst_addr,	  // �ėp���W�X�^�������݃A�h���X
	output reg				   				ex_gpr_we_,	   	// �ėp���W�X�^�������ݗL��
	output reg	[`IsaExpBus]   	ex_exp_code,	  // ���O�R�[�h
	output reg	[`WordDataBus] 	ex_out		   		// ��������
);

	/********** pipeline register **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			ex_pc		   <= #1 `WORD_ADDR_W'h0;
			ex_en		   <= #1 `DISABLE;
			ex_br_flag	   <= #1 `DISABLE;
			ex_mem_op	   <= #1 `MEM_OP_NOP;
			ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
			ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
			ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
			ex_gpr_we_	   <= #1 `DISABLE_;
			ex_exp_code	   <= #1 `ISA_EXP_NO_EXP;
			ex_out		   <= #1 `WORD_DATA_W'h0;
		end else begin
			/* update */
			if (stall == `DISABLE) begin
				if (flush == `ENABLE) begin				  // flush
					ex_pc		   <= #1 `WORD_ADDR_W'h0;
					ex_en		   <= #1 `DISABLE;
					ex_br_flag	   <= #1 `DISABLE;
					ex_mem_op	   <= #1 `MEM_OP_NOP;
					ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
					ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
					ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
					ex_gpr_we_	   <= #1 `DISABLE_;
					ex_exp_code	   <= #1 `ISA_EXP_NO_EXP;
					ex_out		   <= #1 `WORD_DATA_W'h0;
				end else if (int_detect == `ENABLE) begin // interrupt
					ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 `MEM_OP_NOP;
					ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
					ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
					ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
					ex_gpr_we_	   <= #1 `DISABLE_;
					ex_exp_code	   <= #1 `ISA_EXP_EXT_INT;
					ex_out		   <= #1 `WORD_DATA_W'h0;
				end else if (alu_of == `ENABLE) begin	  // alu overflow
					ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 `MEM_OP_NOP;
					ex_mem_wr_data <= #1 `WORD_DATA_W'h0;
					ex_ctrl_op	   <= #1 `CTRL_OP_NOP;
					ex_dst_addr	   <= #1 `REG_ADDR_W'd0;
					ex_gpr_we_	   <= #1 `DISABLE_;
					ex_exp_code	   <= #1 `ISA_EXP_OVERFLOW;
					ex_out		   <= #1 `WORD_DATA_W'h0;
				end else begin							  // next one in pipeline
					ex_pc		   <= #1 id_pc;
					ex_en		   <= #1 id_en;
					ex_br_flag	   <= #1 id_br_flag;
					ex_mem_op	   <= #1 id_mem_op;
					ex_mem_wr_data <= #1 id_mem_wr_data;
					ex_ctrl_op	   <= #1 id_ctrl_op;
					ex_dst_addr	   <= #1 id_dst_addr;
					ex_gpr_we_	   <= #1 id_gpr_we_;
					ex_exp_code	   <= #1 id_exp_code;
					ex_out		   <= #1 alu_out;
				end
			end
		end
	end

endmodule
