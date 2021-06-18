
`ifndef __CPU_HEADER__
	`define __CPU_HEADER__
//------------------------------------------------------------------------------
// Operation
//------------------------------------------------------------------------------
	/********** ���W�X�^ **********/
	`define REG_NUM				 32	  	// ���W�X�^��
	`define REG_ADDR_W			 5	  //bit wise
	`define RegAddrBus			 4:0  //gpr register address wide
	/********** CPU IRQ **********/
	`define CPU_IRQ_CH			 8	  // IRQ channel
	/********** ALU OP **********/
	//
	`define ALU_OP_W			 4	  // ALU�I�y�R�[�h��
	`define AluOpBus			 3:0  // ALU�I�y�R�[�h�o�X
	//
	`define ALU_OP_NOP			 4'h0 // No Operation
	`define ALU_OP_AND			 4'h1 // AND
	`define ALU_OP_OR			 4'h2 // OR
	`define ALU_OP_XOR			 4'h3 // XOR
	`define ALU_OP_ADDS			 4'h4 // �����t�����Z
	`define ALU_OP_ADDU			 4'h5 // �����Ȃ����Z
	`define ALU_OP_SUBS			 4'h6 // �����t�����Z
	`define ALU_OP_SUBU			 4'h7 // �����Ȃ����Z
	`define ALU_OP_SHRL			 4'h8 // �_���E�V�t�g
	`define ALU_OP_SHLL			 4'h9 // �_�����V�t�g
	/********** MEM OP **********/
	// �o�X
	`define MEM_OP_W			 2	  // �������I�y�R�[�h��
	`define MemOpBus			 1:0  // �������I�y�R�[�h�o�X
	// �I�y�R�[�h
	`define MEM_OP_NOP			 2'h0 // No Operation
	`define MEM_OP_LDW			 2'h1 // MEM LOAD
	`define MEM_OP_STW			 2'h2 // MEM STORE
	/********** CTRL OP **********/
	// �o�X
	`define CTRL_OP_W			 2	  // �����I�y�R�[�h��
	`define CtrlOpBus			 1:0  // �����I�y�R�[�h�o�X
	// �I�y�R�[�h
	`define CTRL_OP_NOP			 2'h0 // No Operation
	`define CTRL_OP_WRCR		 2'h1 //
	`define CTRL_OP_EXRT		 2'h2 // ���O�����̕��A

	/********** ���s���[�h **********/
	// �o�X
	`define CPU_EXE_MODE_W		 1	  // ���s���[�h��
	`define CpuExeModeBus		 0:0  // ���s���[�h�o�X
	// ���s���[�h
	`define CPU_KERNEL_MODE		 1'b0 // �J�[�l�����[�h
	`define CPU_USER_MODE		 1'b1 // ���[�U���[�h

//------------------------------------------------------------------------------
// ���䃌�W�X�^
//------------------------------------------------------------------------------
	/********** �A�h���X�}�b�v **********/
	`define CREG_ADDR_STATUS	 5'h0  // �X�e�[�^�X
	`define CREG_ADDR_PRE_STATUS 5'h1  // �O�̃X�e�[�^�X
	`define CREG_ADDR_PC		 5'h2  // �v���O�����J�E���^
	`define CREG_ADDR_EPC		 5'h3  // ���O�v���O�����J�E���^
	`define CREG_ADDR_EXP_VECTOR 5'h4  // ���O�x�N�^
	`define CREG_ADDR_CAUSE		 5'h5  // ���O�������W�X�^
	`define CREG_ADDR_INT_MASK	 5'h6  // ���荞�݃}�X�N
	`define CREG_ADDR_IRQ		 5'h7  // ���荞�ݗv��
	// �ǂݏo�����p�̈�
	`define CREG_ADDR_ROM_SIZE	 5'h1d // ROM�T�C�Y
	`define CREG_ADDR_SPM_SIZE	 5'h1e // SPM�T�C�Y
	`define CREG_ADDR_CPU_INFO	 5'h1f // CPU����
	/********** �r�b�g�}�b�v **********/
	`define CregExeModeLoc		 0	   // ���s���[�h�̈ʒu
	`define CregIntEnableLoc	 1	   // ���荞�ݗL���̈ʒu
	`define CregExpCodeLoc		 2:0   // ���O�R�[�h�̈ʒu
	`define CregDlyFlagLoc		 3	   // �f�B���C�X���b�g�t���O�̈ʒu

//------------------------------------------------------------------------------
// �o�X�C���^�t�F�[�X
//------------------------------------------------------------------------------
	/********** �o�X�C���^�t�F�[�X�̏��� **********/
	// �o�X
	`define BusIfStateBus		 1:0   // ���ԃo�X
	// ����
	`define BUS_IF_STATE_IDLE	 2'h0  // �A�C�h��
	`define BUS_IF_STATE_REQ	 2'h1  // �o�X���N�G�X�g
	`define BUS_IF_STATE_ACCESS	 2'h2  // �o�X�A�N�Z�X
	`define BUS_IF_STATE_STALL	 2'h3  // �X�g�[��

//------------------------------------------------------------------------------
// MISC
//------------------------------------------------------------------------------
	/********** �x�N�^ **********/
	`define RESET_VECTOR		 30'h0 // all 0's for reset address
	/********** �V�t�g�� **********/
	`define ShAmountBus			 4:0   // �V�t�g�ʃo�X
	`define ShAmountLoc			 4:0   // �V�t�g�ʂ̈ʒu
	/********** CPU release information *********/
	`define RELEASE_YEAR		 		8'd41 // year (YYYY - 1970)
	`define RELEASE_MONTH		 		8'd7  // month
	`define RELEASE_VERSION		 	8'd1  // version
	`define RELEASE_REVISION	 	8'd0  // revision


`endif
