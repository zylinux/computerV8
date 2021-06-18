/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/global_config.h"
`include "../../top/include/stddef.h"
/**********headers**********/
`include "../include/spm.h"
module spm (
	input  wire				   clk,
	/**********IF stage cpu **********/
	input  wire [`SpmAddrBus]  if_spm_addr,			//A [11:0]
	input  wire				   if_spm_as_,
	input  wire				   if_spm_rw,
	input  wire [`WordDataBus] if_spm_wr_data,
	output wire [`WordDataBus] if_spm_rd_data,
	/**********MEM stage cpu**********/
	input  wire [`SpmAddrBus]  mem_spm_addr,		//B [11:0]
	input  wire				   mem_spm_as_,
	input  wire				   mem_spm_rw,
	input  wire [`WordDataBus] mem_spm_wr_data,
	output wire [`WordDataBus] mem_spm_rd_data
);

	/********** A and B**********/
	reg						   wea;			// write A
	reg						   web;			// write B

	/********** write enable or disable **********/
	always @(*) begin
		/* A */
		if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE)) begin
			wea = `MEM_ENABLE;	//write enable
		end else begin
			wea = `MEM_DISABLE; //write disable
		end
		/* B */
		if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE)) begin
			web = `MEM_ENABLE;	//write enable
		end else begin
			web = `MEM_DISABLE; //write disable
		end
	end


	`ifdef SIMULATION
	/********** Xilinx FPGA Block RAM :********/
	x_s3e_dpram x_s3e_dpram (
		/**********A : IF **********/
		.clka  (clk),
		.addra (if_spm_addr),
		.dina  (if_spm_wr_data),
		.wea   (wea),
		.douta (if_spm_rd_data),
		/**********B : MEM **********/
		.clkb  (clk),
		.addrb (mem_spm_addr),
		.dinb  (mem_spm_wr_data),
		.web   (web),
		.doutb (mem_spm_rd_data)
	);

`else

	altera_dpram	x_s3e_dpram (
	.address_a ( if_spm_addr ),
	.address_b ( mem_spm_addr ),
	.clock_a ( clk ),
	.clock_b ( clk ),
	.data_a ( if_spm_wr_data ),
	.data_b ( mem_spm_wr_data ),
	.wren_a ( wea ),
	.wren_b ( web ),
	.q_a ( if_spm_rd_data ),
	.q_b ( mem_spm_rd_data )
	);


`endif






endmodule
