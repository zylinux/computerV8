
/**********basic headers**********/
`include "../include/nettype.h"
`include "../include/stddef.h"
`include "../include/global_config.h"
/* i use it now , but i need to replace it with FPGA IP*/
module clk_gen (
	input wire	clk_ref,   //main reference clock pin
	input wire	reset_sw,  //main reset pin
	output wire clk,	   //generated clock to whole system
	output wire clk_,	   //generated 180 clock to whole system
	output wire chip_reset //generated reset to whole system
);
	wire		locked;		//
	wire		dcm_reset;//1 means reset the clock module, 0 means normal
	assign dcm_reset  = (reset_sw == `RESET_ENABLE) ? `ENABLE : `DISABLE;//RESET_ENABLE  0,ENABLE 1

	assign chip_reset = ((reset_sw == `RESET_ENABLE) || (locked == `DISABLE)) ?//when reset is 0 or locked is 0 means not locked, chip_reset keep RESET_ENABLE(0)
							`RESET_ENABLE : `RESET_DISABLE;

`ifdef SIMULATION
	/********** Xilinx DCM (Digitl Clock Manager) **********/
	x_s3e_dcm x_s3e_dcm (
		.CLKIN_IN		 (clk_ref),	  	//main referece clock
		.RST_IN			 (dcm_reset), 	//reset when it is 1
		.CLK0_OUT		 (clk),		  		//clk
		.CLK180_OUT		 (clk_),	  	//180 clk
		.LOCKED_OUT		 (locked)	  	//locked 0 not locked, 1 locked means stable
   );

`else
	altera_dcm	altera_dcm_inst (
	.areset (dcm_reset),//1 reset
	.inclk0 ( clk_ref ),
	.c0 ( clk ),
	.c1 ( clk_ ),
	.locked (locked)//if locked output 1
	);

`endif



endmodule
