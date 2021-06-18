/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********cpu and bus headers**********/
`include "../include/cpu.h"
`include "../../bus/include/bus.h"
module bus_if (
	input  wire				   				clk,
	input  wire				   				reset,
	/**********pipeline control**********/
	input  wire				   				stall,		   		//delay
	input  wire				   				flush,		   		//refresh
	output reg				   				busy,		   			//busy
	/**********CPU**********/
	input  wire [`WordAddrBus] 	addr,						//address
	input  wire				   				as_,			   		//address select
	input  wire				   				rw,			   			//write/read
	input  wire [`WordDataBus] 	wr_data,		  	//write data
	output reg	[`WordDataBus] 	rd_data,		  	//read data
	/**********SPM**********/
	input  wire [`WordDataBus] 	spm_rd_data,		//SPM read data from SPM
	output wire [`WordAddrBus] 	spm_addr,	  		//SPM address
	output reg				   				spm_as_,		   	//SPM address select
	output wire				   				spm_rw,		   		//SPM write/read
	output wire [`WordDataBus] 	spm_wr_data,		//SPM write data
	/**********BUS**********/
	input  wire [`WordDataBus] 	bus_rd_data,		//bus read data
	input  wire				   				bus_rdy_,	   		//bus ready
	input  wire				  		 		bus_grnt_,	   	//bus grant
	output reg				   				bus_req_,	   		//bus request
	output reg	[`WordAddrBus] 	bus_addr,	  		//bus address
	output reg				   				bus_as_,		   	//bus address select
	output reg				   				bus_rw,		   		//bus read/write
	output reg	[`WordDataBus] 	bus_wr_data			//bus write data
);

	reg	 [`BusIfStateBus]	   state;		   		//bus state
	reg	 [`WordDataBus]		   rd_buf;		   	//read buffer
	wire [`BusSlaveIndexBus]   s_index;		  //slave index indicate which slave

	/********** which slave **********/
	assign s_index	   = addr[`BusSlaveIndexLoc];

	/**********write data to SPM**********/
	assign spm_addr	   = addr;
	assign spm_rw	   = rw;
	assign spm_wr_data = wr_data;

	/**********SPM access**********/
	always @(*) begin
		rd_data	 = `WORD_DATA_W'h0;
		spm_as_	 = `DISABLE_;//1'b1
		busy	 = `DISABLE;//1'b0
		case (state)
			`BUS_IF_STATE_IDLE	 : begin //IDIE
				//SPM RAM access
				if ((flush == `DISABLE) && (as_ == `ENABLE_)) begin
					if (s_index == `BUS_SLAVE_1) begin //SPM
						if (stall == `DISABLE) begin //delay
							spm_as_	 = `ENABLE_;
							if (rw == `READ) begin //read from SPM
								rd_data	 = spm_rd_data;
							end
						end
					end else begin
						busy	 = `ENABLE;
					end
				end
			end
			`BUS_IF_STATE_REQ	 : begin //request
				busy	 = `ENABLE;
			end
			`BUS_IF_STATE_ACCESS : begin //access
				if (bus_rdy_ == `ENABLE_) begin
					if (rw == `READ) begin //read from bus read
						rd_data	 = bus_rd_data;
					end
				end else begin					//
					busy	 = `ENABLE;
				end
			end
			`BUS_IF_STATE_STALL	 : begin //delay
				if (rw == `READ) begin //
					rd_data	 = rd_buf;//
				end
			end
		endcase
	end

   /**********BUS access**********/
   always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			state		<= #1 `BUS_IF_STATE_IDLE;
			bus_req_	<= #1 `DISABLE_;
			bus_addr	<= #1 `WORD_ADDR_W'h0;
			bus_as_		<= #1 `DISABLE_;
			bus_rw		<= #1 `READ;
			bus_wr_data <= #1 `WORD_DATA_W'h0;
			rd_buf		<= #1 `WORD_DATA_W'h0;
		end else begin
			case (state)
				`BUS_IF_STATE_IDLE	 : begin //idle

					if ((flush == `DISABLE) && (as_ == `ENABLE_)) begin

						if (s_index != `BUS_SLAVE_1) begin
							state		<= #1 `BUS_IF_STATE_REQ;
							bus_req_	<= #1 `ENABLE_;
							bus_addr	<= #1 addr;
							bus_rw		<= #1 rw;
							bus_wr_data <= #1 wr_data;
						end
					end
				end
				`BUS_IF_STATE_REQ	 : begin //request

					if (bus_grnt_ == `ENABLE_) begin
						state		<= #1 `BUS_IF_STATE_ACCESS;
						bus_as_		<= #1 `ENABLE_;
					end
				end
				`BUS_IF_STATE_ACCESS : begin //access

					bus_as_		<= #1 `DISABLE_;

					if (bus_rdy_ == `ENABLE_) begin
						bus_req_	<= #1 `DISABLE_;
						bus_addr	<= #1 `WORD_ADDR_W'h0;
						bus_rw		<= #1 `READ;
						bus_wr_data <= #1 `WORD_DATA_W'h0;

						if (bus_rw == `READ) begin
							rd_buf		<= #1 bus_rd_data;
						end

						if (stall == `ENABLE) begin
							state		<= #1 `BUS_IF_STATE_STALL;
						end else begin
							state		<= #1 `BUS_IF_STATE_IDLE;
						end
					end
				end
				`BUS_IF_STATE_STALL	 : begin //delay
					if (stall == `DISABLE) begin
						state		<= #1 `BUS_IF_STATE_IDLE;
					end
				end
			endcase
		end
	end

endmodule
