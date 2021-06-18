/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
module mem_stage (
	input  wire				   								clk,
	input  wire				   								reset,
	/********** pipeline control **********/
	input  wire				   								stall,		   	// delay
	input  wire				   								flush,		   	// flush
	output wire				   								busy,		   		//
	/********** �t�H���[�f�B���O **********/
	output wire [`WordDataBus] 					fwd_data,
	/********** SPM **********/
	input  wire [`WordDataBus] 					spm_rd_data,
	output wire [`WordAddrBus] 					spm_addr,
	output wire				   								spm_as_,
	output wire				   								spm_rw,
	output wire [`WordDataBus] 					spm_wr_data,
	/********** bus **********/
	input  wire [`WordDataBus] 					bus_rd_data,	// �ǂݏo���f�[�^
	input  wire				   								bus_rdy_,	   	// ���f�B
	input  wire				   								bus_grnt_,	  // �o�X�O�����g
	output wire				   								bus_req_,	   	// �o�X���N�G�X�g
	output wire [`WordAddrBus] 					bus_addr,	   	// �A�h���X
	output wire				   								bus_as_,		  // �A�h���X�X�g���[�u
	output wire				   								bus_rw,		   	// �ǂ݁^����
	output wire [`WordDataBus] 					bus_wr_data,	// �������݃f�[�^
	/********** EX/MEM **********/
	input  wire [`WordAddrBus] 					ex_pc,		   	// �v���O�����J�E���^
	input  wire				   								ex_en,		   	// �p�C�v���C���f�[�^�̗L��
	input  wire				   								ex_br_flag,	  // �����t���O
	input  wire [`MemOpBus]	   					ex_mem_op,	  // �������I�y���[�V����
	input  wire [`WordDataBus] 					ex_mem_wr_data, // �������������݃f�[�^
	input  wire [`CtrlOpBus]   					ex_ctrl_op,	  // ���䃌�W�X�^�I�y���[�V����
	input  wire [`RegAddrBus]  					ex_dst_addr,	// �ėp���W�X�^�������݃A�h���X
	input  wire				   								ex_gpr_we_,	  // �ėp���W�X�^�������ݗL��
	input  wire [`IsaExpBus]   					ex_exp_code,	// ���O�R�[�h
	input  wire [`WordDataBus] 					ex_out,		   	// ��������
	/********** MEM/WB **********/
	output wire [`WordAddrBus] 					mem_pc,		   // �v���O�����J�E���^
	output wire				   								mem_en,		   // �p�C�v���C���f�[�^�̗L��
	output wire				   								mem_br_flag, // �����t���O
	output wire [`CtrlOpBus]   					mem_ctrl_op, // ���䃌�W�X�^�I�y���[�V����
	output wire [`RegAddrBus]  					mem_dst_addr,// �ėp���W�X�^�������݃A�h���X
	output wire				   								mem_gpr_we_, // �ėp���W�X�^�������ݗL��
	output wire [`IsaExpBus]   					mem_exp_code,// ���O�R�[�h
	output wire [`WordDataBus] 					mem_out		   // ��������
);

	/********** ���M�� **********/
	wire [`WordDataBus]		   rd_data;		   // �ǂݏo���f�[�^
	wire [`WordAddrBus]		   addr;		   // �A�h���X
	wire					   as_;			   // �A�h���X�L��
	wire					   rw;			   // �ǂ݁^����
	wire [`WordDataBus]		   wr_data;		   // �������݃f�[�^
	wire [`WordDataBus]		   out;			   // �������A�N�Z�X����
	wire					   miss_align;	   // �~�X�A���C��

	/********** ���ʂ̃t�H���[�f�B���O **********/
	assign fwd_data	 = out;

	/********** �������A�N�Z�X���䃆�j�b�g **********/
	mem_ctrl mem_ctrl (
		/********** EX/MEM�p�C�v���C�����W�X�^ **********/
		.ex_en			(ex_en),			   // �p�C�v���C���f�[�^�̗L��
		.ex_mem_op		(ex_mem_op),		   // �������I�y���[�V����
		.ex_mem_wr_data (ex_mem_wr_data),	   // �������������݃f�[�^
		.ex_out			(ex_out),			   // ��������
		/********** �������A�N�Z�X�C���^�t�F�[�X **********/
		.rd_data		(rd_data),			   // �ǂݏo���f�[�^
		.addr			(addr),				   // �A�h���X
		.as_			(as_),				   // �A�h���X�L��
		.rw				(rw),				   // �ǂ݁^����
		.wr_data		(wr_data),			   // �������݃f�[�^
		/********** �������A�N�Z�X���� **********/
		.out			(out),				   // �������A�N�Z�X����
		.miss_align		(miss_align)		   // �~�X�A���C��
	);

	/********** bus related because it needs to access memory or bus as master 1**********/
	bus_if bus_if (
		.clk		 		(clk),
		.reset			(reset),
		/********** pipeline control **********/
		.stall			(stall),				   	// delay
		.flush			(flush),				   	// flush
		.busy		 		(busy),				   		// busy
		/********** CPU **********/
		.addr		 		(addr),				   		// address
		.as_		 		(as_),					   	// address select
		.rw			 		(rw),					   		// read/write
		.wr_data		(wr_data),				  // write data
		.rd_data		(rd_data),				  // read data
		/********** SPM **********/
		.spm_rd_data (spm_rd_data),			//
		.spm_addr	 (spm_addr),			   	//
		.spm_as_	 (spm_as_),				   	//
		.spm_rw		 (spm_rw),				   	//
		.spm_wr_data (spm_wr_data),			//
		/********** bus related **********/
		.bus_rd_data (bus_rd_data),			//
		.bus_rdy_	 (bus_rdy_),			   	//
		.bus_grnt_	 (bus_grnt_),			  //
		.bus_req_	 (bus_req_),			   	//
		.bus_addr	 (bus_addr),			   	//
		.bus_as_	 (bus_as_),				   	//
		.bus_rw		 (bus_rw),				   	//
		.bus_wr_data (bus_wr_data)			// 
	);

	/********** MEM **********/
	mem_reg mem_reg (
		.clk		  		(clk),
		.reset		  	(reset),
		/**********  **********/
		.out		  		(out),				   		// out
		.miss_align		(miss_align),			  // miss aligned
		/********** pipeline control **********/
		.stall		  	(stall),				   	// delay
		.flush		  	(flush),				   	// flush
		/********** EX/MEM **********/
		.ex_pc		  	(ex_pc),				   	// ex pc
		.ex_en		  	(ex_en),				   	// ex enable
		.ex_br_flag	  (ex_br_flag),			  // ex branch flag
		.ex_ctrl_op	  (ex_ctrl_op),			  // ex ctrl op
		.ex_dst_addr  (ex_dst_addr),		  // ex gpr address to write
		.ex_gpr_we_	  (ex_gpr_we_),			  // ex gpr write
		.ex_exp_code  (ex_exp_code),		  // ex expception code
		/********** MEM/WB **********/
		.mem_pc		  	(mem_pc),				   	// memory pc
		.mem_en		  	(mem_en),				   	// memory enable
		.mem_br_flag  (mem_br_flag),		  // memory branch flag
		.mem_ctrl_op  (mem_ctrl_op),		  // memory ctrl op
		.mem_dst_addr (mem_dst_addr),		  // memory gpr address to write
		.mem_gpr_we_  (mem_gpr_we_),		  // memory gpr write
		.mem_exp_code (mem_exp_code),		  // memory expception code
		.mem_out	  	(mem_out)				   	// memory out
	);

endmodule
