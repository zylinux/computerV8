/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
`include "../../bus/include/bus.h"
`include "../include/spm.h"
module cpu (
	input  wire					  clk,
	input  wire					  clk_,
	input  wire					  reset,
	/**********IF and MEM**********/
	// IF Stage takes 0 master
	input  wire [`WordDataBus]	  if_bus_rd_data,		//externel data to cpu to read
	input  wire					  				if_bus_rdy_,			//externel slave tells cpu slave ready
	input  wire					  				if_bus_grnt_,			//externel bus tells cpu that bus granted
	output wire					  				if_bus_req_,	   	//cpu instruction fetch internal generate request
	output wire [`WordAddrBus]	  if_bus_addr,	   	//cpu instruction fetch internal generate address
	output wire					  				if_bus_as_,	   		//cpu instruction fetch internal generate as singal
	output wire					  				if_bus_rw,	   		//cpu instruction fetch internal generate read/write singal
	output wire [`WordDataBus]	  if_bus_wr_data,  	//cpu instruction fetch internal generate data
	// MEM Stage takes 1 master
	input  wire [`WordDataBus]	  mem_bus_rd_data, 	//externel data to cpu to read
	input  wire					  				mem_bus_rdy_,	   	//externel slave tells cpu slave ready
	input  wire					  				mem_bus_grnt_,   	//externel bus tells cpu that bus granted
	output wire					  				mem_bus_req_,	   	//cpu memory internal generate request
	output wire [`WordAddrBus]	  mem_bus_addr,	   	//cpu memory internal generate address
	output wire					  				mem_bus_as_,	   	//cpu memory internal generate as singal
	output wire					  				mem_bus_rw,				//cpu memory internal generate read/write singal
	output wire [`WordDataBus]	  mem_bus_wr_data, 	//cpu memory internal generate data
	/**********irq**********/
	input  wire [`CPU_IRQ_CH-1:0] cpu_irq		   //8
);

	/********** �p�C�v���C�����W�X�^ **********/
	// IF/ID
	wire [`WordAddrBus]			 	if_pc;			 // �v���O�����J�E���^
	wire [`WordDataBus]			 	if_insn;		 // ����
	wire						 					if_en;			 // �p�C�v���C���f�[�^�̗L��
	// ID/EX
	wire [`WordAddrBus]			 	id_pc;			 // �v���O�����J�E���^
	wire						 					id_en;			 // �p�C�v���C���f�[�^�̗L��
	wire [`AluOpBus]			 		id_alu_op;		 // ALU�I�y���[�V����
	wire [`WordDataBus]			 	id_alu_in_0;	 // ALU���� 0
	wire [`WordDataBus]			 	id_alu_in_1;	 // ALU���� 1
	wire						 					id_br_flag;	 // �����t���O
	wire [`MemOpBus]			 		id_mem_op;		 // �������I�y���[�V����
	wire [`WordDataBus]			 	id_mem_wr_data; // �������������݃f�[�^
	wire [`CtrlOpBus]			 		id_ctrl_op;	 // �����I�y���[�V����
	wire [`RegAddrBus]			 	id_dst_addr;	 // GPR�������݃A�h���X
	wire						 					id_gpr_we_;	 // GPR�������ݗL��
	wire [`IsaExpBus]			 		id_exp_code;	 // ���O�R�[�h
	// EX/MEM
	wire [`WordAddrBus]			 	ex_pc;			 // �v���O�����J�E���^
	wire						 					ex_en;			 // �p�C�v���C���f�[�^�̗L��
	wire						 					ex_br_flag;	 // �����t���O
	wire [`MemOpBus]			 		ex_mem_op;		 // �������I�y���[�V����
	wire [`WordDataBus]			 	ex_mem_wr_data; // �������������݃f�[�^
	wire [`CtrlOpBus]			 		ex_ctrl_op;	 // ���䃌�W�X�^�I�y���[�V����
	wire [`RegAddrBus]			 	ex_dst_addr;	 // �ėp���W�X�^�������݃A�h���X
	wire						 					ex_gpr_we_;	 // �ėp���W�X�^�������ݗL��
	wire [`IsaExpBus]			 		ex_exp_code;	 // ���O�R�[�h
	wire [`WordDataBus]			 	ex_out;		 // ��������
	// MEM/WB
	wire [`WordAddrBus]			 	mem_pc;		 // �v���O�����J�E���^
	wire						 					mem_en;		 // �p�C�v���C���f�[�^�̗L��
	wire						 					mem_br_flag;	 // �����t���O
	wire [`CtrlOpBus]			 		mem_ctrl_op;	 // ���䃌�W�X�^�I�y���[�V����
	wire [`RegAddrBus]			 	mem_dst_addr;	 // �ėp���W�X�^�������݃A�h���X
	wire						 					mem_gpr_we_;	 // �ėp���W�X�^�������ݗL��
	wire [`IsaExpBus]			 		mem_exp_code;	 // ���O�R�[�h
	wire [`WordDataBus]			 	mem_out;		 // ��������

	/********** �p�C�v���C�������M�� **********/
	// stall delay
	wire						 if_stall;		 							// IF
	wire						 id_stall;		 							// ID
	wire						 ex_stall;		 							// EX
	wire						 mem_stall;		 							// MEM
	// flush
	wire						 if_flush;		 							// IF
	wire						 id_flush;		 							// ID
	wire						 ex_flush;		 							// EX
	wire						 mem_flush;		 							// MEM
	// if/mem
	wire						 if_busy;		 								// IF
	wire						 mem_busy;		 							// MEM
	// ���̑��̐����M��
	wire [`WordAddrBus]			 	new_pc;		 				// new PC
	wire [`WordAddrBus]			 	br_addr;		 			// branch address
	wire						 					br_taken;		 			// do branch
	wire						 					ld_hazard;		 		// load hazard
	/********** gpr **********/
	wire [`WordDataBus]			 gpr_rd_data_0;	 		// gpr 0
	wire [`WordDataBus]			 gpr_rd_data_1;	 		// gpr 1
	wire [`RegAddrBus]			 gpr_rd_addr_0;	 		// gpr address 0
	wire [`RegAddrBus]			 gpr_rd_addr_1;	 		// gpr address 1
	/********** control register **********/
	wire [`CpuExeModeBus]		 exe_mode;		 			//cpu mode
	wire [`WordDataBus]			 creg_rd_data;	 		//control register data
	wire [`RegAddrBus]			 creg_rd_addr;	 		//control register address
	/********** Interrupt Request **********/
	wire						 				int_detect;	  			//Interrupt detect
	/**********  **********/
	// IF to SPM
	wire [`WordDataBus]			 	if_spm_rd_data;  	//instruction fetch spm read data
	wire [`WordAddrBus]			 	if_spm_addr;	  	//instruction fetch spm address
	wire						 					if_spm_as_;	  		//instruction fetch spm address select
	wire						 					if_spm_rw;		  	//instruction fetch spm read/write
	wire [`WordDataBus]			 	if_spm_wr_data;  	//instruction fetch spm write data
	// MEM to SPM
	wire [`WordDataBus]			 	mem_spm_rd_data; 	//memory spm read data
	wire [`WordAddrBus]			 	mem_spm_addr;	  	//memory spm address
	wire						 					mem_spm_as_;	  	//memory spm address select
	wire						 					mem_spm_rw;	  		//memory spm read/write
	wire [`WordDataBus]			 mem_spm_wr_data; 	//memory spm write data
	/********** data pass through **********/
	wire [`WordDataBus]			 ex_fwd_data;	  		// EX data pass through
	wire [`WordDataBus]			 mem_fwd_data;	  	// MEM data pass through

	//instruction fetch stage
	//will read instructions from spm or bus(rom access via bus)
	if_stage if_stage (
		.clk						(clk),
		.reset					(reset),
		/********** SPM **********/
		//connected to SPM module
		.spm_rd_data		(if_spm_rd_data),
		.spm_addr				(if_spm_addr),
		.spm_as_				(if_spm_as_),
		.spm_rw					(if_spm_rw),
		.spm_wr_data		(if_spm_wr_data),
		/********** bus **********/
		//connected to outside bus
		.bus_rd_data		(if_bus_rd_data),
		.bus_rdy_				(if_bus_rdy_),
		.bus_grnt_			(if_bus_grnt_),
		.bus_req_				(if_bus_req_),
		.bus_addr				(if_bus_addr),
		.bus_as_				(if_bus_as_),
		.bus_rw					(if_bus_rw),
		.bus_wr_data		(if_bus_wr_data),
		/********** control from outside **********/
		//connected to ctrl module
		.stall					(if_stall),
		.flush					(if_flush),
		.new_pc					(new_pc),
		//connected to id_stage module
		.br_taken				(br_taken),
		.br_addr				(br_addr),
		//connected to ctrl module
		.busy						(if_busy),
		/********** IF/ID output to id Stage**********/
		//connected to id_stage module
		.if_pc					(if_pc),
		.if_insn				(if_insn),
		.if_en					(if_en)
	);

	id_stage id_stage (
		.clk						(clk),
		.reset					(reset),
		/********** GPR **********/
		.gpr_rd_data_0	(gpr_rd_data_0),	//gpr 0 (32 regisers)
		.gpr_rd_data_1	(gpr_rd_data_1),	//gpr 1 (32 regisers)
		.gpr_rd_addr_0	(gpr_rd_addr_0),	//gpr address 0 (32 regisers)
		.gpr_rd_addr_1	(gpr_rd_addr_1),	//gpr address 1 (32 regisers)
		/********** data pass through input **********/
		// EX data pass through
		.ex_en					(ex_en),					// ex_stage enable
		.ex_fwd_data		(ex_fwd_data),		// ex_stage forward data
		.ex_dst_addr		(ex_dst_addr),		// ex_stage gpr destination address
		.ex_gpr_we_			(ex_gpr_we_),			// ex_stage gpr write
		// MEM data pass through
		.mem_fwd_data		(mem_fwd_data),		// mem_stage forward data
		/********** control registers total actually has 32 of them **********/
		.exe_mode				(exe_mode),				// cpu mode
		.creg_rd_data		(creg_rd_data),		// control register data
		.creg_rd_addr		(creg_rd_addr),		// control register 5bits address 0-32
		/********** pipeline control **********/
	   .stall		   		(id_stall),		   	// stall delay
		.flush					(id_flush),				// flush
		.br_addr				(br_addr),				// branch address
		.br_taken				(br_taken),				// branch
		.ld_hazard			(ld_hazard),			// load hazard
		/**********  IF/ID inputs from if_stage**********/
		.if_pc					(if_pc),					// instruction fetch pc
		.if_insn				(if_insn),				// instruction fetch instruction
		.if_en					(if_en),					// instruction fetch enable
		/********** ID/EX outputs to ex_stage **********/
		.id_pc					(id_pc),					// instruction decode pc
		.id_en					(id_en),					// instruction decode enable
		.id_alu_op			(id_alu_op),			// instruction decode ALU op
		.id_alu_in_0		(id_alu_in_0),		// instruction decode ALU 0
		.id_alu_in_1		(id_alu_in_1),		// instruction decode ALU 1
		.id_br_flag			(id_br_flag),			// instruction decode branch flag
		.id_mem_op			(id_mem_op),			// instruction decode memory op
		.id_mem_wr_data (id_mem_wr_data),	// instruction decode memory write data
		.id_ctrl_op			(id_ctrl_op),			// instruction decode ctrl op
		.id_dst_addr		(id_dst_addr),		// GPR write address
		.id_gpr_we_			(id_gpr_we_),			// GPR write enable
		.id_exp_code		(id_exp_code)			// instruction decode expception code
	);

	ex_stage ex_stage (
		.clk						(clk),
		.reset					(reset),
		/********** from ctrl module **********/
		.stall					(ex_stall),					// delay
		.flush					(ex_flush),					// flush
		.int_detect			(int_detect),				// Interrupt detect
		/********** output back to id_stage **********/
		.fwd_data				(ex_fwd_data),			// mem forward data
		/********** ID/EX inputs from id_stage **********/
		.id_pc					(id_pc),						// id pc
		.id_en					(id_en),						// id enable
		.id_alu_op			(id_alu_op),				// id ALU op
		.id_alu_in_0		(id_alu_in_0),			// id ALU 0
		.id_alu_in_1		(id_alu_in_1),			// id ALU  1
		.id_br_flag			(id_br_flag),				// id branch flag
		.id_mem_op			(id_mem_op),				// id memory op
		.id_mem_wr_data (id_mem_wr_data),		// id memory write date
		.id_ctrl_op			(id_ctrl_op),				// id ctrl op
		.id_dst_addr		(id_dst_addr),			// id destination address
		.id_gpr_we_			(id_gpr_we_),				// id gpr write
		.id_exp_code		(id_exp_code),			// id expception code
		/********** EX/MEM outputs to Mem**********/
		.ex_pc					(ex_pc),						// ex pc
		.ex_en					(ex_en),						// ex enable
		.ex_br_flag			(ex_br_flag),				// ex branch flag
		.ex_mem_op			(ex_mem_op),				// ex memory op
		.ex_mem_wr_data (ex_mem_wr_data),		// ex memory write date
		.ex_ctrl_op			(ex_ctrl_op),				// ex ctrl op
		.ex_dst_addr		(ex_dst_addr),			// ex destination address
		.ex_gpr_we_			(ex_gpr_we_),				// ex gpr write
		.ex_exp_code		(ex_exp_code),			// ex expception code
		.ex_out					(ex_out)						// ex out
	);

	mem_stage mem_stage (
		.clk						(clk),
		.reset					(reset),
		/********** ctrl module **********/
		.stall					(mem_stall),				// input
		.flush					(mem_flush),				// input
		.busy						(mem_busy),					// ouput
		/********** ouput to id_stage **********/
		.fwd_data				(mem_fwd_data),			//
		/********** to SPM **********/
		.spm_rd_data		(mem_spm_rd_data),	// load data
		.spm_addr				(mem_spm_addr),			// data address
		.spm_as_				(mem_spm_as_),			// address select
		.spm_rw					(mem_spm_rw),				// data read/write
		.spm_wr_data		(mem_spm_wr_data),	// store data
		/********** to bus **********/
		.bus_rd_data		(mem_bus_rd_data),	// bus load data
		.bus_rdy_				(mem_bus_rdy_),			// bus ready
		.bus_grnt_			(mem_bus_grnt_),		// bus grant
		.bus_req_				(mem_bus_req_),			// bus request
		.bus_addr				(mem_bus_addr),			// bus address
		.bus_as_				(mem_bus_as_),			// bus address select
		.bus_rw					(mem_bus_rw),				// bus read/write
		.bus_wr_data		(mem_bus_wr_data),	// bus write data
		/********** EX/MEM from ex_stage**********/
		.ex_pc					(ex_pc),						// ex pc
		.ex_en					(ex_en),						// ex enable
		.ex_br_flag			(ex_br_flag),				// ex branch flag
		.ex_mem_op			(ex_mem_op),				// ex memory op
		.ex_mem_wr_data (ex_mem_wr_data),		// ex memory write data
		.ex_ctrl_op			(ex_ctrl_op),				// ex ctrl op
		.ex_dst_addr		(ex_dst_addr),			// ex destination address
		.ex_gpr_we_			(ex_gpr_we_),				// ex gpr write
		.ex_exp_code		(ex_exp_code),			// ex expception
		.ex_out					(ex_out),						// ex out
		/********** MEM/WB to WB **********/
		.mem_pc					(mem_pc),						// mem pc
		.mem_en					(mem_en),						// mem enable
		.mem_br_flag		(mem_br_flag),			// mem branch flag
		.mem_ctrl_op		(mem_ctrl_op),			// mem ctrl op
		.mem_dst_addr		(mem_dst_addr),			// mem destination address
		.mem_gpr_we_		(mem_gpr_we_),			// mem gpr write
		.mem_exp_code		(mem_exp_code),			// mem expception
		.mem_out				(mem_out)						// mem out
	);

	ctrl ctrl (
		.clk			(clk),
		.reset			(reset),
		/********** control registers **********/
		.creg_rd_addr	(creg_rd_addr),			//control register address
		.creg_rd_data	(creg_rd_data),			//control register data
		.exe_mode			(exe_mode),					//cpu mode
		/********** Interrupt **********/
		.irq					(cpu_irq),					//
		.int_detect		(int_detect),				//
		/********** ID/EX  **********/
		.id_pc				(id_pc),						// �v���O�����J�E���^
		/********** MEM/WB **********/
		.mem_pc				(mem_pc),						// �v���O�����J�E���^
		.mem_en				(mem_en),						// �p�C�v���C���f�[�^�̗L��
		.mem_br_flag	(mem_br_flag),			// �����t���O
		.mem_ctrl_op	(mem_ctrl_op),			// ���䃌�W�X�^�I�y���[�V����
		.mem_dst_addr	(mem_dst_addr),			// �ėp���W�X�^�������݃A�h���X
		.mem_exp_code	(mem_exp_code),			// ���O�R�[�h
		.mem_out			(mem_out),					// ��������
		/********** �p�C�v���C�������M�� **********/
		// �p�C�v���C���̏���
		.if_busy			(if_busy),					// IF�X�e�[�W�r�W�[
		.ld_hazard		(ld_hazard),				// Load�n�U�[�h
		.mem_busy			(mem_busy),					// MEM�X�e�[�W�r�W�[
		// �X�g�[���M��
		.if_stall			(if_stall),					// IF�X�e�[�W�X�g�[��
		.id_stall			(id_stall),					// ID�X�e�[�W�X�g�[��
		.ex_stall			(ex_stall),					// EX�X�e�[�W�X�g�[��
		.mem_stall		(mem_stall),				// MEM�X�e�[�W�X�g�[��
		// �t���b�V���M��
		.if_flush			(if_flush),					// IF�X�e�[�W�t���b�V��
		.id_flush			(id_flush),					// ID�X�e�[�W�t���b�V��
		.ex_flush			(ex_flush),					// EX�X�e�[�W�t���b�V��
		.mem_flush		(mem_flush),				// MEM�X�e�[�W�t���b�V��
		// �V�����v���O�����J�E���^
		.new_pc				(new_pc)						// �V�����v���O�����J�E���^
	);
	//32 32bits general purpose registers
	gpr gpr (
		.clk	   		(clk),
		.reset	   	(reset),
		/********** gpr 0 **********/
		.rd_addr_0 	(gpr_rd_addr_0),
		.rd_data_0 	(gpr_rd_data_0),
		/********** gpr 1 **********/
		.rd_addr_1 	(gpr_rd_addr_1),
		.rd_data_1 	(gpr_rd_data_1),
		/********** mem Stage write gpr**********/
		.we_	   		(mem_gpr_we_),
		.wr_addr   	(mem_dst_addr),
		.wr_data   	(mem_out)
	);
	//internal ram of cpu, has 2 interfaces to instruction fetch stage and memory operation
	//4096 32bits ram
	spm spm (
		.clk			 (clk_),
		/********** cpu IF stage**********/
		.if_spm_addr	 		(if_spm_addr[`SpmAddrLoc]),  	//
		.if_spm_as_		 		(if_spm_as_),				  				//
		.if_spm_rw		 		(if_spm_rw),				  				//
		.if_spm_wr_data	 	(if_spm_wr_data),			  			//
		.if_spm_rd_data	 	(if_spm_rd_data),			  			//
		/********** cpu MEM stage**********/
		.mem_spm_addr	 		(mem_spm_addr[`SpmAddrLoc]), 	//
		.mem_spm_as_	 		(mem_spm_as_),				  			//
		.mem_spm_rw		 		(mem_spm_rw),				  				//
		.mem_spm_wr_data 	(mem_spm_wr_data),			  		//
		.mem_spm_rd_data 	(mem_spm_rd_data)			  			//
	);

endmodule
