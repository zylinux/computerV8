/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/stddef.h"
`include "../../top/include/global_config.h"
/**********bus header**********/
`include "../include/bus.h"
/**********bus address decoder**********/
module bus_addr_dec (
	/**********WordAddrBus coming**********/
	input  wire [`WordAddrBus] s_addr,//[29:0]
	/**********interpret to cs signal**********/
	output reg				   s0_cs_, //cs0
	output reg				   s1_cs_, //cs1
	output reg				   s2_cs_, //cs2
	output reg				   s3_cs_, //cs3
	output reg				   s4_cs_, //cs4
	output reg				   s5_cs_, //cs5
	output reg				   s6_cs_, //cs6
	output reg				   s7_cs_  //cs7
);
	/********************/
	wire [`BusSlaveIndexBus] s_index = s_addr[`BusSlaveIndexLoc];// wire [2:0] s_index=s_addr[29:27]
	/********************/
	always @(*) begin
		/*init all to 1*/
		s0_cs_ = `DISABLE_;//1'b1
		s1_cs_ = `DISABLE_;
		s2_cs_ = `DISABLE_;
		s3_cs_ = `DISABLE_;
		s4_cs_ = `DISABLE_;
		s5_cs_ = `DISABLE_;
		s6_cs_ = `DISABLE_;
		s7_cs_ = `DISABLE_;
		/*if chosen, cs = 0*/
		case (s_index)
			`BUS_SLAVE_0 : begin
				s0_cs_	= `ENABLE_;//1'b0
			end
			`BUS_SLAVE_1 : begin //
				s1_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_2 : begin //
				s2_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_3 : begin //
				s3_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_4 : begin //
				s4_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_5 : begin //
				s5_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_6 : begin //
				s6_cs_	= `ENABLE_;
			end
			`BUS_SLAVE_7 : begin //
				s7_cs_	= `ENABLE_;
			end
		endcase
	end
endmodule
