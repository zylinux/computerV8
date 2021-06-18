/**********this header contains the signal configuration**********/
`ifndef __STDDEF_HEADER__
	`define __STDDEF_HEADER__
	//bit
	/********** high and low singal *********/
	`define HIGH				1'b1	 // High
	`define LOW					1'b0	 // Low
	/**********logic*********/
	//positive logic
	`define DISABLE						1'b0
	`define ENABLE						1'b1
	//negative logic
	`define DISABLE_					1'b1
	`define ENABLE_						1'b0
	/********** read and write singal *********/
	`define READ							1'b1
	`define WRITE							1'b0

	// byte and word
	/*******************/
	`define LSB								0		 	//Least Significant Bit
	/********** byte (8 bit) *********/
	`define BYTE_DATA_W				8			//data width 8 bits in a bytes
	`define BYTE_MSB					7		 	//Most Significant Byte the 7th bit in a byte
	`define ByteDataBus				7:0		//data bus bits in a byte
	/********** word (32 bit) *********/
	`define WORD_DATA_W				32		 	//data bits width in a word
	`define WORD_MSB					31		 	//Most Significant Bit in a word
	`define WordDataBus				31:0	 	//data bus bits in a word

	//address
	/**********word address*********/
	`define WORD_ADDR_W				30		 //word address bits width(because alignment)
	`define WORD_ADDR_MSB			29		 //word Most Significant Bit in a address
	`define WordAddrBus				29:0	 //word address bus bits in address
	/*******************/
	`define BYTE_OFFSET_W			2		//
	`define ByteOffsetBus			1:0	//
	/*******************/
	`define WordAddrLoc				31:2	//
	`define ByteOffsetLoc			1:0	//
	/*******************/
	`define BYTE_OFFSET_WORD	2'b00	//

`endif
