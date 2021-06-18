/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/stddef.h"
`include "../../top/include/global_config.h"
/**********bus header**********/
`include "../include/bus.h"
/**********bus address arbiter**********/
module bus_arbiter (
	input  wire		   clk,
	input  wire		   reset,
	/********** masters 0-3 **********/
	//0
	input  wire		   m0_req_,
	output reg		   m0_grnt_,
	//1
	input  wire		   m1_req_,
	output reg		   m1_grnt_,
	//2
	input  wire		   m2_req_,
	output reg		   m2_grnt_,
	//3
	input  wire		   m3_req_,
	output reg		   m3_grnt_
);

	reg [`BusOwnerBus] owner;	 //[1:0]
	/**********bus masters grant**********/
	always @(*) begin
		m0_grnt_ = `DISABLE_;//1'b1
		m1_grnt_ = `DISABLE_;
		m2_grnt_ = `DISABLE_;
		m3_grnt_ = `DISABLE_;
		case (owner)
			`BUS_OWNER_MASTER_0 : begin
				m0_grnt_ = `ENABLE_;
			end
			`BUS_OWNER_MASTER_1 : begin
				m1_grnt_ = `ENABLE_;
			end
			`BUS_OWNER_MASTER_2 : begin
				m2_grnt_ = `ENABLE_;
			end
			`BUS_OWNER_MASTER_3 : begin
				m3_grnt_ = `ENABLE_;
			end
		endcase
	end

	/**********bus switch**********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			owner <= #1 `BUS_OWNER_MASTER_0;//2'h0
		end else begin
			case (owner)
				`BUS_OWNER_MASTER_0 : begin //2'h0
					if (m0_req_ == `ENABLE_) begin					//1'b0
						owner <= #1 `BUS_OWNER_MASTER_0;
					end else if (m1_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_1;
					end else if (m2_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_2;
					end else if (m3_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_3;
					end
				end
				`BUS_OWNER_MASTER_1 : begin //2'h1
					if (m1_req_ == `ENABLE_) begin					//1'b0
						owner <= #1 `BUS_OWNER_MASTER_1;
					end else if (m2_req_ == `ENABLE_) begin //1'b0
						owner <= #1 `BUS_OWNER_MASTER_2;
					end else if (m3_req_ == `ENABLE_) begin //1'b0
						owner <= #1 `BUS_OWNER_MASTER_3;
					end else if (m0_req_ == `ENABLE_) begin //1'b0
						owner <= #1 `BUS_OWNER_MASTER_0;
					end
				end
				`BUS_OWNER_MASTER_2 : begin //2'h2
					if (m2_req_ == `ENABLE_) begin					//1'b0
						owner <= #1 `BUS_OWNER_MASTER_2;
					end else if (m3_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_3;
					end else if (m0_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_0;
					end else if (m1_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_1;
					end
				end
				`BUS_OWNER_MASTER_3 : begin //2'h3
						if (m3_req_ == `ENABLE_) begin				//1'b0
						owner <= #1 `BUS_OWNER_MASTER_3;
					end else if (m0_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_0;
					end else if (m1_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_1;
					end else if (m2_req_ == `ENABLE_) begin
						owner <= #1 `BUS_OWNER_MASTER_2;
					end
				end
			endcase
		end
	end

endmodule
