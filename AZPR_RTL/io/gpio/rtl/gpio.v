/**********basic headers**********/
`include "../../../top/include/nettype.h"
`include "../../../top/include/stddef.h"
`include "../../../top/include/global_config.h"
/**********gpio header**********/
`include "../include/gpio.h"
module gpio (
	input  wire						clk,
	input  wire						reset,
	/**********bus related**********/
	input  wire						cs_,
	input  wire						as_,
	input  wire						rw,
	input  wire [`GpioAddrBus]		addr,		//[1:0]
	input  wire [`WordDataBus]		wr_data,//write data [31:0]
	output reg	[`WordDataBus]		rd_data,//read data [31:0]
	output reg						rdy_	 					//ready
	/**********gpio pins**********/
`ifdef GPIO_IN_CH	 //4
	, input wire [`GPIO_IN_CH-1:0]	gpio_in
`endif
`ifdef GPIO_OUT_CH	 //18
	, output reg [`GPIO_OUT_CH-1:0] gpio_out
`endif
`ifdef GPIO_IO_CH	 //16
	, inout wire [`GPIO_IO_CH-1:0]	gpio_io
`endif
);

`ifdef GPIO_IO_CH// input and output 16
	/**********in and out singal**********/
	wire [`GPIO_IO_CH-1:0]			io_in;	 	// 16 data in
	reg	 [`GPIO_IO_CH-1:0]			io_out;	 	// 16 data out
	reg	 [`GPIO_IO_CH-1:0]			io_dir;	 	// 16 dir
	reg	 [`GPIO_IO_CH-1:0]			io;		 		// input and output pin
	integer							i;		 //

	/**********GPIO_IO_CH**********/
	assign io_in	   = gpio_io;	//outside -> gpio_io -> io_in when io is z
	assign gpio_io	   = io;		//io_out -> io -> gpio_io -> outside

	/**********if io is input io[i] will be z, otherwise io is output**********/
	always @(*) begin
		for (i = 0; i < `GPIO_IO_CH; i = i + 1) begin : IO_DIR
			io[i] = (io_dir[i] == `GPIO_DIR_IN) ? 1'bz : io_out[i];
		end
	end

`endif

	/********** GPIO**********/
	always @(posedge clk or `RESET_EDGE reset) begin
		if (reset == `RESET_ENABLE) begin
			rd_data	 <= #1 `WORD_DATA_W'h0;
			rdy_	 <= #1 `DISABLE_;
`ifdef GPIO_OUT_CH	 //output port only default value, all 18bits are 0s
			gpio_out <= #1 {`GPIO_OUT_CH{`LOW}};
`endif
`ifdef GPIO_IO_CH	 	//input and output port default value,
			io_out	 <= #1 {`GPIO_IO_CH{`LOW}};				 //default value output all 16 bits are 0s
			io_dir	 <= #1 {`GPIO_IO_CH{`GPIO_DIR_IN}};//default value direction mode all are input mode
`endif
		end else begin
			//ready
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
				rdy_	 <= #1 `ENABLE_;//1'b0
			end else begin
				rdy_	 <= #1 `DISABLE_;
			end
			/********** read data **********/
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `READ)) begin
				case (addr)
`ifdef GPIO_IN_CH	//input port only
					`GPIO_ADDR_IN_DATA	: begin	//control register 0
						//rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IN_CH{1'b0}},
						//				gpio_in};
						rd_data	 <= #1 {{`WORD_DATA_W-1{1'b0}}, //modified by min zhang
										gpio_in[0]};
					end
`endif
`ifdef GPIO_OUT_CH	//output port only
					`GPIO_ADDR_OUT_DATA : begin //control register 1
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_OUT_CH{1'b0}},
										gpio_out};
					end
`endif
`ifdef GPIO_IO_CH	//input and output port
					`GPIO_ADDR_IO_DATA	: begin //control register 2
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IO_CH{1'b0}},
										io_in};
					 end
					`GPIO_ADDR_IO_DIR	: begin 	//control register 3
						rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IO_CH{1'b0}},
										io_dir};
					end
`endif
				endcase
			end else begin
				rd_data	 <= #1 `WORD_DATA_W'h0;
			end
			/********** write data **********/
			if ((cs_ == `ENABLE_) && (as_ == `ENABLE_) && (rw == `WRITE)) begin
				case (addr)
`ifdef GPIO_OUT_CH	//output only
					`GPIO_ADDR_OUT_DATA : begin //control register 1
						gpio_out <= #1 wr_data[`GPIO_OUT_CH-1:0];
					end
`endif
`ifdef GPIO_IO_CH	//input and output
					`GPIO_ADDR_IO_DATA	: begin //control register 2
						io_out	 <= #1 wr_data[`GPIO_IO_CH-1:0];
					 end
					`GPIO_ADDR_IO_DIR	: begin //control register 3
						io_dir	 <= #1 wr_data[`GPIO_IO_CH-1:0];
					end
`endif
				endcase
			end
		end
	end

endmodule
