/*
 -- ============================================================================
 -- FILE NAME	: global_config.h
 -- DESCRIPTION : �S�̐ݒ�
 -- ----------------------------------------------------------------------------
 -- Revision  Date		  Coding_by	 Comment
 -- 1.0.0	  2011/06/27  suito		 �V�K�쐬
 -- ============================================================================
*/

`ifndef __GLOBAL_CONFIG_HEADER__
	`define __GLOBAL_CONFIG_HEADER__
//------------------------------------------------------------------------------
//global setting here
//------------------------------------------------------------------------------
	/**********  **********/
//	`define TARGET_DEV_MFPGA_SPAR3E		//
	`define TARGET_DEV_AZPR_EV_BOARD	//

	/********** reset control **********/
//	`define POSITIVE_RESET				// Active High
	`define NEGATIVE_RESET				// Active Low

	/********** memory control**********/
	`define POSITIVE_MEMORY				// Active High
//	`define NEGATIVE_MEMORY				// Active Low

	/********** I/O module define**********/
	`define IMPLEMENT_TIMER				// TIMER module 
	`define IMPLEMENT_UART				// UART module 
	`define IMPLEMENT_GPIO				// General Purpose I/O module
	/********** SIMULATION**********/
	`timescale 1ns/1ps
	//`define SIMULATION	
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
	/**********  *********/
	// Active Low
	`ifdef POSITIVE_RESET
		`define RESET_EDGE	  posedge	//
		`define RESET_ENABLE  1'b1		//
		`define RESET_DISABLE 1'b0		//
	`endif
	// Active High (which is using now !)
	`ifdef NEGATIVE_RESET
		`define RESET_EDGE	  negedge	//
		`define RESET_ENABLE  1'b0		//
		`define RESET_DISABLE 1'b1		//
	`endif

	/********** *********/
	// Actoive High (which is using now)
	`ifdef POSITIVE_MEMORY
		`define MEM_ENABLE	  1'b1		//
		`define MEM_DISABLE	  1'b0		//
	`endif
	// Active Low
	`ifdef NEGATIVE_MEMORY
		`define MEM_ENABLE	  1'b0		//
		`define MEM_DISABLE	  1'b1		//
	`endif

`endif
