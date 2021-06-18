/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********cpu header**********/
`include "../include/cpu.h"
module alu (
	input  wire [`WordDataBus] in_0,  // in 0
	input  wire [`WordDataBus] in_1,  // in 1
	input  wire [`AluOpBus]	   op,	  // op
	output reg	[`WordDataBus] out,	  // out
	output reg				   of	  				// overflow
);

	/********** signed **********/
	wire signed [`WordDataBus] s_in_0 = $signed(in_0); //  0
	wire signed [`WordDataBus] s_in_1 = $signed(in_1); //  1
	wire signed [`WordDataBus] s_out  = $signed(out);  // out

	/********** arithmetic and logic **********/
	always @(*) begin
		case (op)
			`ALU_OP_AND	 : begin // AND
				out	  = in_0 & in_1;
			end
			`ALU_OP_OR	 : begin // OR
				out	  = in_0 | in_1;
			end
			`ALU_OP_XOR	 : begin // XOR
				out	  = in_0 ^ in_1;
			end
			`ALU_OP_ADDS : begin // add signed
				out	  = in_0 + in_1;
			end
			`ALU_OP_ADDU : begin // add unsigned
				out	  = in_0 + in_1;
			end
			`ALU_OP_SUBS : begin // sub signed
				out	  = in_0 - in_1;
			end
			`ALU_OP_SUBU : begin // sub unsigned
				out	  = in_0 - in_1;
			end
			`ALU_OP_SHRL : begin // right shift
				out	  = in_0 >> in_1[`ShAmountLoc];
			end
			`ALU_OP_SHLL : begin // left shift
				out	  = in_0 << in_1[`ShAmountLoc];
			end
			default		 : begin // default (No Operation)
				out	  = in_0;
			end
		endcase
	end

	/********** overflow detect **********/
	always @(*) begin
		case (op)
			`ALU_OP_ADDS : begin // add
				if (((s_in_0 > 0) && (s_in_1 > 0) && (s_out < 0)) ||
					((s_in_0 < 0) && (s_in_1 < 0) && (s_out > 0))) begin
					of = `ENABLE;
				end else begin
					of = `DISABLE;
				end
			end
			`ALU_OP_SUBS : begin // sub
				if (((s_in_0 < 0) && (s_in_1 > 0) && (s_out > 0)) ||
					((s_in_0 > 0) && (s_in_1 < 0) && (s_out < 0))) begin
					of = `ENABLE;
				end else begin
					of = `DISABLE;
				end
			end
			default		: begin // default
				of = `DISABLE;
			end
		endcase
	end

endmodule
