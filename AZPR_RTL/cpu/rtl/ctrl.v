/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
`include "../../io/rom/include/rom.h"
`include "../include/spm.h"
module ctrl (
	input  wire					  				clk,
	input  wire					  				reset,
	/********** ���䃌�W�X�^�C���^�t�F�[�X **********/
	input  wire [`RegAddrBus]	  	creg_rd_addr, // �ǂݏo���A�h���X
	output reg	[`WordDataBus]	  creg_rd_data, // �ǂݏo���f�[�^
	output reg	[`CpuExeModeBus]  exe_mode,		// ��s���[�h
	/********** ���荞�� **********/
	input  wire [`CPU_IRQ_CH-1:0] irq,			// ���荞�ݗv��
	output reg					  				int_detect,	// ���荞�݌��o
	/********** ID/EX�p�C�v���C�����W�X�^ **********/
	input  wire [`WordAddrBus]	  id_pc,		// �v���O�����J�E���^
	/********** MEM/WB�p�C�v���C�����W�X�^ **********/
	input  wire [`WordAddrBus]	  mem_pc,		// �v���O�����J�E���^
	input  wire					  				mem_en,		// �p�C�v���C���f�[�^�̗L��
	input  wire					  				mem_br_flag,	// �����t���O
	input  wire [`CtrlOpBus]	  	mem_ctrl_op,	// ���䃌�W�X�^�I�y���[�V����
	input  wire [`RegAddrBus]	  	mem_dst_addr, // �������݃A�h���X
	input  wire [`IsaExpBus]	  	mem_exp_code, // ���O�R�[�h
	input  wire [`WordDataBus]	  mem_out,		// ��������
	/********** �p�C�v���C�������M�� **********/
	// �p�C�v���C���̏���
	input  wire					  				if_busy,		// IF�X�e�[�W�r�W�[
	input  wire					  				ld_hazard,	// ���[�h�n�U�[�h
	input  wire					  				mem_busy,		// MEM�X�e�[�W�r�W�[
	// �X�g�[���M��
	output wire					  				if_stall,		// IF�X�e�[�W�X�g�[��
	output wire					  				id_stall,		// ID�X�e�[�W�X�g�[��
	output wire					  				ex_stall,		// EX�X�e�[�W�X�g�[��
	output wire					  				mem_stall,	// MEM�X�e�[�W�X�g�[��
	// �t���b�V���M��
	output wire					  				if_flush,		// IF�X�e�[�W�t���b�V��
	output wire					  				id_flush,		// ID�X�e�[�W�t���b�V��
	output wire					  				ex_flush,		// EX�X�e�[�W�t���b�V��
	output wire					  				mem_flush,	// MEM�X�e�[�W�t���b�V��
	output reg	[`WordAddrBus]	  new_pc		// �V�����v���O�����J�E���^
);

	/********** ���䃌�W�X�^ **********/
	reg							 					int_en;		// 0�� : ���荞�ݗL��
	reg	 [`CpuExeModeBus]		 	pre_exe_mode;	// 1�� : ��s���[�h
	reg							 					pre_int_en;	// 1�� : ���荞�ݗL��
	reg	 [`WordAddrBus]			 	epc;			// 3�� : ���O�v���O�����J�E���^
	reg	 [`WordAddrBus]			 	exp_vector;	// 4�� : ���O�x�N�^
	reg	 [`IsaExpBus]			 		exp_code;		// 5�� : ���O�R�[�h
	reg							 					dly_flag;		// 6�� : �f�B���C�X���b�g�t���O
	reg	 [`CPU_IRQ_CH-1:0]		mask;			// 7�� : ���荞�݃}�X�N

	/********** ���M�� **********/
	reg [`WordAddrBus]		  	pre_pc;			// �O�̃v���O�����J�E���^
	reg						  					br_flag;			// �����t���O

	/********** �p�C�v���C�������M�� **********/
	// �X�g�[���M��
	wire   stall	 = if_busy | mem_busy;
	assign if_stall	 = stall | ld_hazard;
	assign id_stall	 = stall;
	assign ex_stall	 = stall;
	assign mem_stall = stall;
	// �t���b�V���M��
	reg	   flush;
	assign if_flush	 = flush;
	assign id_flush	 = flush | ld_hazard;
	assign ex_flush	 = flush;
	assign mem_flush = flush;

	/********** �p�C�v���C���t���b�V������ **********/
	always @(*) begin
		/* �f�t�H���g�l */
		new_pc = `WORD_ADDR_W'h0;
		flush  = `DISABLE;
		/* �p�C�v���C���t���b�V�� */
		if (mem_en == `ENABLE) begin // �p�C�v���C���̃f�[�^���L��
			if (mem_exp_code != `ISA_EXP_NO_EXP) begin		 // ���O����
				new_pc = exp_vector;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin // EXRT����
				new_pc = epc;
				flush  = `ENABLE;
			end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin // WRCR����
				new_pc = mem_pc;
				flush  = `ENABLE;
			end
		end
	end

	/********** ���荞�݂̌��o **********/
	always @(*) begin
		if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE)) begin
			int_detect = `ENABLE;
		end else begin
			int_detect = `DISABLE;
		end
	end

	/********** �ǂݏo���A�N�Z�X **********/
	always @(*) begin
		case (creg_rd_addr)
		   `CREG_ADDR_STATUS	 : begin // 0��:�X�e�[�^�X
			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
		   end
		   `CREG_ADDR_PRE_STATUS : begin // 1��:���O�����O�̃X�e�[�^�X
			   creg_rd_data = {{`WORD_DATA_W-2{1'b0}},
							   pre_int_en, pre_exe_mode};
		   end
		   `CREG_ADDR_PC		 : begin // 2��:�v���O�����J�E���^
			   creg_rd_data = {id_pc, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_EPC		 : begin // 3��:���O�v���O�����J�E���^
			   creg_rd_data = {epc, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_EXP_VECTOR : begin // 4��:���O�x�N�^
			   creg_rd_data = {exp_vector, `BYTE_OFFSET_W'h0};
		   end
		   `CREG_ADDR_CAUSE		 : begin // 5��:���O����
			   creg_rd_data = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}},
							   dly_flag, exp_code};
		   end
		   `CREG_ADDR_INT_MASK	 : begin // 6��:���荞�݃}�X�N
			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, mask};
		   end
		   `CREG_ADDR_IRQ		 : begin // 6��:���荞�݌���
			   creg_rd_data = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, irq};
		   end
		   `CREG_ADDR_ROM_SIZE	 : begin // 7��:ROM�̃T�C�Y
			   creg_rd_data = $unsigned(`ROM_SIZE);
		   end
		   `CREG_ADDR_SPM_SIZE	 : begin // 8��:SPM�̃T�C�Y
			   creg_rd_data = $unsigned(`SPM_SIZE);
		   end
		   `CREG_ADDR_CPU_INFO	 : begin // 9��:CPU�̏���
			   creg_rd_data = {`RELEASE_YEAR, `RELEASE_MONTH,
							   `RELEASE_VERSION, `RELEASE_REVISION};
		   end
		   default				 : begin // �f�t�H���g�l
			   creg_rd_data = `WORD_DATA_W'h0;
		   end
		endcase
	end

	/********** CPU�̐��� **********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			/* �񓯊����Z�b�g */
			exe_mode	 <= #1 `CPU_KERNEL_MODE;
			int_en		 <= #1 `DISABLE;
			pre_exe_mode <= #1 `CPU_KERNEL_MODE;
			pre_int_en	 <= #1 `DISABLE;
			exp_code	 <= #1 `ISA_EXP_NO_EXP;
			mask		 <= #1 {`CPU_IRQ_CH{`ENABLE}};
			dly_flag	 <= #1 `DISABLE;
			epc			 <= #1 `WORD_ADDR_W'h0;
			exp_vector	 <= #1 `WORD_ADDR_W'h0;
			pre_pc		 <= #1 `WORD_ADDR_W'h0;
			br_flag		 <= #1 `DISABLE;
		end else begin
			/* CPU�̏��Ԃ��X�V */
			if ((mem_en == `ENABLE) && (stall == `DISABLE)) begin
				/* PC�ƕ����t���O�̕ۑ� */
				pre_pc		 <= #1 mem_pc;
				br_flag		 <= #1 mem_br_flag;
				/* CPU�̃X�e�[�^�X���� */
				if (mem_exp_code != `ISA_EXP_NO_EXP) begin		 // ���O����
					exe_mode	 <= #1 `CPU_KERNEL_MODE;
					int_en		 <= #1 `DISABLE;
					pre_exe_mode <= #1 exe_mode;
					pre_int_en	 <= #1 int_en;
					exp_code	 <= #1 mem_exp_code;
					dly_flag	 <= #1 br_flag;
					epc			 <= #1 pre_pc;
				end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin // EXRT����
					exe_mode	 <= #1 pre_exe_mode;
					int_en		 <= #1 pre_int_en;
				end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin // WRCR����
				   /* ���䃌�W�X�^�ւ̏������� */
					case (mem_dst_addr)
						`CREG_ADDR_STATUS	  : begin // �X�e�[�^�X
							exe_mode	 <= #1 mem_out[`CregExeModeLoc];
							int_en		 <= #1 mem_out[`CregIntEnableLoc];
						end
						`CREG_ADDR_PRE_STATUS : begin // ���O�����O�̃X�e�[�^�X
							pre_exe_mode <= #1 mem_out[`CregExeModeLoc];
							pre_int_en	 <= #1 mem_out[`CregIntEnableLoc];
						end
						`CREG_ADDR_EPC		  : begin // ���O�v���O�����J�E���^
							epc			 <= #1 mem_out[`WordAddrLoc];
						end
						`CREG_ADDR_EXP_VECTOR : begin // ���O�x�N�^
							exp_vector	 <= #1 mem_out[`WordAddrLoc];
						end
						`CREG_ADDR_CAUSE	  : begin // ���O����
							dly_flag	 <= #1 mem_out[`CregDlyFlagLoc];
							exp_code	 <= #1 mem_out[`CregExpCodeLoc];
						end
						`CREG_ADDR_INT_MASK	  : begin // ���荞�݃}�X�N
							mask		 <= #1 mem_out[`CPU_IRQ_CH-1:0];
						end
					endcase
				end
			end
		end
	end

endmodule
