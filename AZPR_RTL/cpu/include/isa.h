`ifndef __ISA_HEADER__
	`define __ISA_HEADER__			 // Include Guard

//------------------------------------------------------------------------------
// ����
//------------------------------------------------------------------------------
	/********** ���� **********/
	`define ISA_NOP			   32'h0 // No Operation
	/********** �I�y�R�[�h **********/
	// �o�X
	`define ISA_OP_W		   6	 // �I�y�R�[�h��
	`define IsaOpBus		   5:0	 // �I�y�R�[�h�o�X
	`define IsaOpLoc		   31:26 // �I�y�R�[�h�̈ʒu
	// �I�y�R�[�h
	`define ISA_OP_ANDR		   6'h00 // ���W�X�^���m�̘_����
	`define ISA_OP_ANDI		   6'h01 // ���W�X�^�ƒ萔�̘_����
	`define ISA_OP_ORR		   6'h02 // ���W�X�^���m�̘_���a
	`define ISA_OP_ORI		   6'h03 // ���W�X�^�ƒ萔�̘_���a
	`define ISA_OP_XORR		   6'h04 // ���W�X�^���m�̔r���I�_���a
	`define ISA_OP_XORI		   6'h05 // ���W�X�^�ƒ萔�̔r���I�_���a
	`define ISA_OP_ADDSR	   6'h06 // ���W�X�^���m�̕����t�����Z
	`define ISA_OP_ADDSI	   6'h07 // ���W�X�^�ƒ萔�̕����t�����Z
	`define ISA_OP_ADDUR	   6'h08 // ���W�X�^���m�̕����Ȃ����Z
	`define ISA_OP_ADDUI	   6'h09 // ���W�X�^�ƒ萔�̕����Ȃ����Z
	`define ISA_OP_SUBSR	   6'h0a // ���W�X�^���m�̕����t�����Z
	`define ISA_OP_SUBUR	   6'h0b // ���W�X�^���m�̕����Ȃ����Z
	`define ISA_OP_SHRLR	   6'h0c // ���W�X�^���m�̘_���E�V�t�g
	`define ISA_OP_SHRLI	   6'h0d // ���W�X�^�ƒ萔�̘_���E�V�t�g
	`define ISA_OP_SHLLR	   6'h0e // ���W�X�^���m�̘_�����V�t�g
	`define ISA_OP_SHLLI	   6'h0f // ���W�X�^�ƒ萔�̘_�����V�t�g
	`define ISA_OP_BE		   6'h10 // ���W�X�^���m�̕����t�����r(==)
	`define ISA_OP_BNE		   6'h11 // ���W�X�^���m�̕����t�����r(!=)
	`define ISA_OP_BSGT		   6'h12 // ���W�X�^���m�̕����t�����r(<)
	`define ISA_OP_BUGT		   6'h13 // ���W�X�^���m�̕����Ȃ����r(<)
	`define ISA_OP_JMP		   6'h14 // ���W�X�^�w���̐��Ε���
	`define ISA_OP_CALL		   6'h15 // ���W�X�^�w���̃T�u���[�`���R�[��
	`define ISA_OP_LDW		   6'h16 // ���[�h�ǂݏo��
	`define ISA_OP_STW		   6'h17 // ���[�h��������
	`define ISA_OP_TRAP		   6'h18 // �g���b�v
	`define ISA_OP_RDCR		   6'h19 // ���䃌�W�X�^�̓ǂݏo��
	`define ISA_OP_WRCR		   6'h1a // ���䃌�W�X�^�ւ̏�������
	`define ISA_OP_EXRT		   6'h1b // ���O�����̕��A
	/********** ���W�X�^�A�h���X **********/
	// �o�X
	`define ISA_REG_ADDR_W	   5	 // ���W�X�^�A�h���X��
	`define IsaRegAddrBus	   4:0	 // ���W�X�^�A�h���X�o�X
	`define IsaRaAddrLoc	   25:21 // ���W�X�^Ra�̈ʒu
	`define IsaRbAddrLoc	   20:16 // ���W�X�^Rb�̈ʒu
	`define IsaRcAddrLoc	   15:11 // ���W�X�^Rc�̈ʒu
	/********** ���l **********/
	// �o�X
	`define ISA_IMM_W		   16	 // ���l�̕�
	`define ISA_EXT_W		   16	 // ���l�̕����g����
	`define ISA_IMM_MSB		   15	 // ���l�̍ŏ��ʃr�b�g
	`define IsaImmBus		   15:0	 // ���l�̃o�X
	`define IsaImmLoc		   15:0	 // ���l�̈ʒu

//------------------------------------------------------------------------------
// ���O
//------------------------------------------------------------------------------
	/********** ���O�R�[�h **********/
	// �o�X
	`define ISA_EXP_W		   3	 // ���O�R�[�h��
	`define IsaExpBus		   2:0	 // ���O�R�[�h�o�X
	// ���O
	`define ISA_EXP_NO_EXP	   3'h0	 // ���O�Ȃ�
	`define ISA_EXP_EXT_INT	   3'h1	 // �O�����荞��
	`define ISA_EXP_UNDEF_INSN 3'h2	 // �����`����
	`define ISA_EXP_OVERFLOW   3'h3	 // �Z�p�I�[�o�t���[
	`define ISA_EXP_MISS_ALIGN 3'h4	 // �A�h���X�~�X�A���C��
	`define ISA_EXP_TRAP	   3'h5	 // �g���b�v
	`define ISA_EXP_PRV_VIO	   3'h6	 // �����ᔽ

`endif
