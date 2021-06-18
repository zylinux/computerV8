/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/isa.h"
`include "../include/cpu.h"
`include "../../bus/include/bus.h"

module mem_ctrl (
	/********** EX/MEM **********/
	input  wire				   				ex_en,		   		// ex
	input  wire [`MemOpBus]	   	ex_mem_op,	   	// ex memory op
	input  wire [`WordDataBus] 	ex_mem_wr_data, // ex memory data
	input  wire [`WordDataBus] 	ex_out,		   		// ex out
	/********** memory access **********/
	input  wire [`WordDataBus] 	rd_data,		   	// date to read
	output wire [`WordAddrBus] 	addr,		  		 	// address
	output reg				   				as_,			   		// address select
	output reg				   				rw,			   			// read/write
	output wire [`WordDataBus] 	wr_data,		   	// data to write
	/********** memory access results **********/
	output reg [`WordDataBus]  	out,		   			//
	output reg				   				miss_align	   	// not aligned
);

	/********** ���M�� **********/
	wire [`ByteOffsetBus]	 offset;		   				// 1:0

	/********** out put  **********/
	assign wr_data = ex_mem_wr_data;		   			// data write to memory
	assign addr	   = ex_out[`WordAddrLoc];	   	// address
	assign offset  = ex_out[`ByteOffsetLoc];   	// offset

	/********** memory access control **********/
	always @(*) begin
		/* default */
		miss_align = `DISABLE;
		out		   = `WORD_DATA_W'h0;
		as_		   = `DISABLE_;
		rw		   = `READ;
		/* access */
		if (ex_en == `ENABLE) begin
			case (ex_mem_op)
				`MEM_OP_LDW : begin // read
					/*  */
					if (offset == `BYTE_OFFSET_WORD) begin // aligned if low 2bits == 00
						out			= rd_data;
						as_		   = `ENABLE_;
					end else begin						   // miss aligned
						miss_align	= `ENABLE;
					end
				end
				`MEM_OP_STW : begin // write
					/*  */
					if (offset == `BYTE_OFFSET_WORD) begin // aligned if low 2bits == 00
						rw			= `WRITE;
						as_		   = `ENABLE_;
					end else begin						   // miss aligned
						miss_align	= `ENABLE;
					end
				end
				default		: begin // no memory access
					out			= ex_out;
				end
			endcase
		end
	end

endmodule
