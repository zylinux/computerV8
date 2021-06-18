
`ifndef __UART_HEADER__
	`define __UART_HEADER__

/*
 * �y�����ɂ��āz
 * �EUART�̓`�b�v�S�̂̊������g�������ƂɃ{�[���[�g�𐶐����Ă��܂��B
 *	 �������g�����{�[���[�g���ύX�����ꍇ�́A
 *	 UART_DIV_RATE��UART_DIV_CNT_W��UartDivCntBus���ύX���ĉ������B
 * �EUART_DIV_RATE�͕������[�g�����`���Ă��܂��B
 *	 UART_DIV_RATE�͊������g�����{�[���[�g�Ŋ�����l�ɂȂ��܂��B
 * �EUART_DIV_CNT_W�͕����J�E���^�̕������`���Ă��܂��B
 *	 UART_DIV_CNT_W��UART_DIV_RATE��log2�����l�ɂȂ��܂��B
 * �EUartDivCntBus��UART_DIV_CNT_W�̃o�X�ł��B
 *	 UART_DIV_CNT_W-1:0�Ƃ��ĉ������B
 *
 * �y�����̗��z
 * �EUART�̃{�[���[�g��38,400baud�ŁA�`�b�v�S�̂̊������g����10MHz�̏ꍇ�A
 *	 UART_DIV_RATE��10,000,000��38,400��260�ƂȂ��܂��B
 *	 UART_DIV_CNT_W��log2(260)��9�ƂȂ��܂��B
 */

	/********** �����J�E���^ *********/
	`define UART_DIV_RATE	   9'd260  // frequency divider
	`define UART_DIV_CNT_W	   9	   //bit wide
	`define UartDivCntBus	   8:0	   //bit wide
	/**********bus**********/
	`define UartAddrBus		   0:0		//?
	`define UART_ADDR_W		   1			//
	`define UartAddrLoc		   0:0		//
	/**********control registers**********/
	`define UART_ADDR_STATUS   1'h0 //control register 0 : status
	`define UART_ADDR_DATA	   1'h1 //control register 1 : receive send data
	/********** �r�b�g�}�b�v **********/
	`define UartCtrlIrqRx	   0			//bit position in control register 0
	`define UartCtrlIrqTx	   1			//bit position in control register 0
	`define UartCtrlBusyRx	   2		//bit position in control register 0
	`define UartCtrlBusyTx	   3		//bit position in control register 0
	/**********bus status**********/
	`define UartStateBus	   0:0		//
	`define UART_STATE_IDLE	 1'b0 	//
	`define UART_STATE_TX	   1'b1 	//
	`define UART_STATE_RX	   1'b1 	//
	/**********bit count**********/
	`define UartBitCntBus	   3:0		//
	`define UART_BIT_CNT_W	   4		//
	`define UART_BIT_CNT_START 4'h0 //
	`define UART_BIT_CNT_MSB   4'h8 //
	`define UART_BIT_CNT_STOP  4'h9 //
	/**********start bit and stop bit**********/
	`define UART_START_BIT	   1'b0 //
	`define UART_STOP_BIT	   1'b1 	//

`endif
