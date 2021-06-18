/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
// this module will decode the if_insn
module decoder (
	/********** IF/ID**********/
	input  wire [`WordAddrBus]	 	if_pc,			 			// if pc already +1 normally with no branch and no new pc load
	input  wire [`WordDataBus]	 	if_insn,		 			// if current instruction data
	input  wire					 					if_en,			 			// if pipeline flag
	/********** GPR registers**********/
	input  wire [`WordDataBus]	 	gpr_rd_data_0, 		// gpr 0 data
	input  wire [`WordDataBus]	 	gpr_rd_data_1, 		// gpr 1 data
	output wire [`RegAddrBus]	 		gpr_rd_addr_0, 		// gpr 0 address
	output wire [`RegAddrBus]	 		gpr_rd_addr_1, 		// gpr 1 address
	/********** data direct **********/
	// ID
	input  wire					 					id_en,						// pipeline enable
	input  wire [`RegAddrBus]	 		id_dst_addr,			// destination address
	input  wire					 					id_gpr_we_,				// write
	input  wire [`MemOpBus]		 		id_mem_op,				// memory operation
	// EX
	input  wire					 					ex_en,						// pipeline enable
	input  wire [`RegAddrBus]	 		ex_dst_addr,			// destination address
	input  wire					 					ex_gpr_we_,				// write
	input  wire [`WordDataBus]	 	ex_fwd_data,			// data direct
	// MEM
	input  wire [`WordDataBus]	 	mem_fwd_data,			// data direct
	/********** ctrl  **********/
	input  wire [`CpuExeModeBus] 	exe_mode,					// expception code
	input  wire [`WordDataBus]	 	creg_rd_data,			// ctrl register data
	output wire [`RegAddrBus]	 		creg_rd_addr,			// ctrl register address
	/********** decoder results **********/
	output reg	[`AluOpBus]		 		alu_op,						// ALU OP
	output reg	[`WordDataBus]	 	alu_in_0,					// ALU input  0
	output reg	[`WordDataBus]	 	alu_in_1,					// ALU input  1
	output reg	[`WordAddrBus]	 	br_addr,					// branch address
	output reg					 					br_taken,					// branch ok
	output reg					 					br_flag,					// branch flag
	output reg	[`MemOpBus]		 		mem_op,						// memory op
	output wire [`WordDataBus]	 	mem_wr_data,			// memory data to write
	output reg	[`CtrlOpBus]	 		ctrl_op,					//
	output reg	[`RegAddrBus]	 		dst_addr,					//
	output reg					 					gpr_we_,					//
	output reg	[`IsaExpBus]	 		exp_code,					// expception code
	output reg					 					ld_hazard					// load hazard
);

	/********** if_insn decode **********/
	wire [`IsaOpBus]	op		= if_insn[`IsaOpLoc];	  			// op
	wire [`RegAddrBus]	ra_addr = if_insn[`IsaRaAddrLoc]; // Ra
	wire [`RegAddrBus]	rb_addr = if_insn[`IsaRbAddrLoc]; // Rb
	wire [`RegAddrBus]	rc_addr = if_insn[`IsaRcAddrLoc]; // Rc
	wire [`IsaImmBus]	imm		= if_insn[`IsaImmLoc];	  		// immediate number
	/********** immediate number **********/
	// signed expansion ISA_EXT_W 16 ISA_IMM_MSB 15
	wire [`WordDataBus] imm_s = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
	// 0 expansion
	wire [`WordDataBus] imm_u = {{`ISA_EXT_W{1'b0}}, imm};
	/********** gpr and ctrl register address generate **********/
	assign gpr_rd_addr_0 = ra_addr; 																	// Ra address 0
	assign gpr_rd_addr_1 = rb_addr; 																	// Rb address 1
	assign creg_rd_addr	 = ra_addr; 																	// ctrl register
	/********** gpr data to read generate**********/
	reg			[`WordDataBus]	ra_data;						  										// usigned Ra
	wire signed [`WordDataBus]	s_ra_data = $signed(ra_data);	  			// signed Ra
	reg			[`WordDataBus]	rb_data;						  										// usigned Rb
	wire signed [`WordDataBus]	s_rb_data = $signed(rb_data);	  			// signed Rb
	assign mem_wr_data = rb_data; // write to
	/********** address generate**********/
	wire [`WordAddrBus] ret_addr  = if_pc + 1'b1;					 						// return address
	wire [`WordAddrBus] br_target = if_pc + imm_s[`WORD_ADDR_MSB:0]; 	//branch address
	wire [`WordAddrBus] jr_target = ra_data[`WordAddrLoc];		  	 		//jump address

	/********** Data pass-through **********/
	always @(*) begin
		/* Ra */
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) &&
			(id_dst_addr == ra_addr)) begin
			ra_data = ex_fwd_data;	 // from EX
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) &&
					 (ex_dst_addr == ra_addr)) begin
			ra_data = mem_fwd_data;	 // from MEM
		end else begin
			ra_data = gpr_rd_data_0; // read from gpr
		end
		/* Rb */
		if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) &&
			(id_dst_addr == rb_addr)) begin
			rb_data = ex_fwd_data;	 // from EX
		end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) &&
					 (ex_dst_addr == rb_addr)) begin
			rb_data = mem_fwd_data;	 // from MEM
		end else begin
			rb_data = gpr_rd_data_1; // read from gpr
		end
	end

	/********** load hazard test **********/
	always @(*) begin
		if ((id_en == `ENABLE) && (id_mem_op == `MEM_OP_LDW) &&
			((id_dst_addr == ra_addr) || (id_dst_addr == rb_addr))) begin
			ld_hazard = `ENABLE;  // load hazard enable
		end else begin
			ld_hazard = `DISABLE; // load hazard disable
		end
	end

	/********** op decode **********/
	always @(*) begin
		//default
		alu_op	 = `ALU_OP_NOP;
		alu_in_0 = ra_data;
		alu_in_1 = rb_data;
		br_taken = `DISABLE;
		br_flag	 = `DISABLE;
		br_addr	 = {`WORD_ADDR_W{1'b0}};
		mem_op	 = `MEM_OP_NOP;
		ctrl_op	 = `CTRL_OP_NOP;
		dst_addr = rb_addr;
		gpr_we_	 = `DISABLE_;
		exp_code = `ISA_EXP_NO_EXP;
		if (if_en == `ENABLE) begin
			case (op)
				/*logic*/
				`ISA_OP_ANDR  : begin // register logic and
					alu_op	 = `ALU_OP_AND;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ANDI  : begin // immediate logic and
					alu_op	 = `ALU_OP_AND;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ORR	  : begin // register logic or
					alu_op	 = `ALU_OP_OR;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ORI	  : begin // immediate logic or
					alu_op	 = `ALU_OP_OR;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_XORR  : begin // register logic xor
					alu_op	 = `ALU_OP_XOR;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_XORI  : begin // immediate logic xor
					alu_op	 = `ALU_OP_XOR;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				/*arithmetic*/
				`ISA_OP_ADDSR : begin // register add signed
					alu_op	 = `ALU_OP_ADDS;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDSI : begin // immediate add signed
					alu_op	 = `ALU_OP_ADDS;
					alu_in_1 = imm_s;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDUR : begin // register add unsigned
					alu_op	 = `ALU_OP_ADDU;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_ADDUI : begin // immediate add unsigned
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SUBSR : begin // register sub signed
					alu_op	 = `ALU_OP_SUBS;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SUBUR : begin // register sub unsigned
					alu_op	 = `ALU_OP_SUBU;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				/*shift*/
				`ISA_OP_SHRLR : begin // register shift logic right
					alu_op	 = `ALU_OP_SHRL;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHRLI : begin // immediate shift logic right
					alu_op	 = `ALU_OP_SHRL;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHLLR : begin // register shift logic left
					alu_op	 = `ALU_OP_SHLL;
					dst_addr = rc_addr;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_SHLLI : begin // immediate shift logic left
					alu_op	 = `ALU_OP_SHLL;
					alu_in_1 = imm_u;
					gpr_we_	 = `ENABLE_;
				end
				/*branch*/
				`ISA_OP_BE	  : begin // Ra == Rb register compare, jump enable
					br_addr	 = br_target;
					br_taken = (ra_data == rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BNE	  : begin // Ra != Rb register compare, jump enable
					br_addr	 = br_target;
					br_taken = (ra_data != rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BSGT  : begin // Ra < Rb register compare, jump enable
					br_addr	 = br_target;
					br_taken = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_BUGT  : begin // Ra < Rb register compare, jump enable
					br_addr	 = br_target;
					br_taken = (ra_data < rb_data) ? `ENABLE : `DISABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_JMP	  : begin // unconditional jump
					br_addr	 = jr_target;
					br_taken = `ENABLE;
					br_flag	 = `ENABLE;
				end
				`ISA_OP_CALL  : begin // function call
					alu_in_0 = {ret_addr, {`BYTE_OFFSET_W{1'b0}}};//construct a 32 bit address
					br_addr	 = jr_target;
					br_taken = `ENABLE;
					br_flag	 = `ENABLE;
					dst_addr = `REG_ADDR_W'd31;//return address need to be writen to 31 register
					gpr_we_	 = `ENABLE_;
				end
				/* memory access */
				`ISA_OP_LDW	  : begin // word read
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					mem_op	 = `MEM_OP_LDW;
					gpr_we_	 = `ENABLE_;
				end
				`ISA_OP_STW	  : begin // word write
					alu_op	 = `ALU_OP_ADDU;
					alu_in_1 = imm_s;
					mem_op	 = `MEM_OP_STW;
				end
				/* system trap */
				`ISA_OP_TRAP  : begin // trap
					exp_code = `ISA_EXP_TRAP;
				end
				/* special command */
				`ISA_OP_RDCR  : begin // read special control register
					if (exe_mode == `CPU_KERNEL_MODE) begin
						alu_in_0 = creg_rd_data;
						gpr_we_	 = `ENABLE_;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				`ISA_OP_WRCR  : begin // write specail control register
					if (exe_mode == `CPU_KERNEL_MODE) begin
						ctrl_op	 = `CTRL_OP_WRCR;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				`ISA_OP_EXRT  : begin // return from expception
					if (exe_mode == `CPU_KERNEL_MODE) begin
						ctrl_op	 = `CTRL_OP_EXRT;
					end else begin
						exp_code = `ISA_EXP_PRV_VIO;
					end
				end
				/* other*/
				default		  : begin // undefine
					exp_code = `ISA_EXP_UNDEF_INSN;
				end
			endcase
		end
	end

endmodule
