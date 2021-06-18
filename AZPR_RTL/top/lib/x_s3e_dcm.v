/************************************/
/*this module is for SIMULATION only*/
/************************************/
/**********basic headers*************/
/**********basic headers**********/
`include "../include/nettype.h"

module x_s3e_dcm (
	input  wire CLKIN_IN,		 // main referece clock
	input  wire RST_IN,			 // main reset 
	output wire CLK0_OUT,		 // clock to the whole system
	output wire CLK180_OUT,		 // clock 180 the whole system
	output wire LOCKED_OUT		 // lock flag
);

	assign CLK0_OUT	  = CLKIN_IN;
	assign CLK180_OUT = ~CLKIN_IN;
	assign LOCKED_OUT = ~RST_IN;
   
endmodule
