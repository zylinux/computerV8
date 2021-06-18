;;; adjust RAM address
LOCATE	0x20000000

;;; define
UART_BASE_ADDR_H		EQU	0x6000			;UART Base Address High
UART_STATUS_OFFSET		EQU	0x0				;UART Status Register Offset
UART_DATA_OFFSET		EQU	0x4					;UART Data Register Offset
UART_RX_INTR_MASK		EQU	0x1					;UART Receive Interrupt Mask
UART_TX_INTR_MASK		EQU	0x2					;UART Transmit Interrupt Mask
GPIO_BASE_ADDR_H		EQU	0x8000			;GPIO Base Address High
GPIO_OUT_OFFSET			EQU	0x4					;GPIO Data Register Offset


	XORR	r0,r0,r0										;r0 = 0

	ORI		r0,r1,high(CLEAR_BUFFER)
	SHLLI	r1,r1,16
	ORI		r1,r1,low(CLEAR_BUFFER)			;CLEAR_BUFFER to r1

	ORI		r0,r2,high(SEND_CHAR)
	SHLLI	r2,r2,16
	ORI		r2,r2,low(SEND_CHAR)				;SEND_CHAR to r2

	ORI		r0,r3,high(SET_GPIO_OUT)
	SHLLI	r3,r3,16
	ORI		r3,r3,low(SET_GPIO_OUT)			;SET_GPIO_OUT to r3


;;; setup exception handler
	ORI		r0,r4,high(EXCEPT_HANDLER)
	SHLLI	r4,r4,16
	ORI		r4,r4,low(EXCEPT_HANDLER)
	WRCR	r4,c4

;;; UART clear buffer
	CALL	r1													;call CLEAR_BUFFER
	ANDR	r0,r0,r0										;NOP

;;; cause the exception overflow
	ORI		r0,r4,0x7FFF
	SHLLI	r4,r4,16
	ORI		r4,r4,0xFFFF
	ADDSI	r4,r4,1

;;; LED
	ORI		r0,r16,0x2
	SHLLI	r16,r16,16
	ORI		r16,r16,0xFFFF							;setup r16=0x0002FFFF
	CALL	r3													;call SET_GPIO_OUT
	ANDR	r0,r0,r0										;NOP

;; loop
LOOP:
	BE		r0,r0,LOOP									;loop
	ANDR	r0,r0,r0										;NOP


CLEAR_BUFFER:
	ORI		r0,r16,UART_BASE_ADDR_H			;UART Base Address
	SHLLI	r16,r16,16

_CHECK_UART_STATUS:
	LDW		r16,r17,UART_STATUS_OFFSET	;STATUS

	ANDI	r17,r17,UART_RX_INTR_MASK
	BE		r0,r17,_CLEAR_BUFFER_RETURN	;Receive Interrupt bit _CLEAR_BUFFER_RETURN
	ANDR	r0,r0,r0					;NOP

_RECEIVE_DATA:
	LDW		r16,r17,UART_DATA_OFFSET

	LDW		r16,r17,UART_STATUS_OFFSET	;STATUS
	XORI	r17,r17,UART_RX_INTR_MASK
	STW		r16,r17,UART_STATUS_OFFSET	;Receive Interrupt bit

	BNE		r0,r0,_CHECK_UART_STATUS		;_CHECK_UART_STATUS
	ANDR	r0,r0,r0										;NOP
_CLEAR_BUFFER_RETURN:
	JMP		r31													;call return
	ANDR	r0,r0,r0										;NOP


SEND_CHAR:
	ORI		r0,r17,UART_BASE_ADDR_H			;UART Base Address
	SHLLI	r17,r17,16
	STW		r17,r16,UART_DATA_OFFSET		;r16

_WAIT_SEND_DONE:
	LDW		r17,r18,UART_STATUS_OFFSET	;get STATUS
	ANDI	r18,r18,UART_TX_INTR_MASK
	BE		r0,r18,_WAIT_SEND_DONE
	ANDR	r0,r0,r0

	LDW		r17,r18,UART_STATUS_OFFSET
	XORI	r18,r18,UART_TX_INTR_MASK
	STW		r17,r18,UART_STATUS_OFFSET	;Transmit Interrupt bit

	JMP		r31													;call return
	ANDR	r0,r0,r0										;NOP

SET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	STW		r17,r16,GPIO_OUT_OFFSET
_SET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP


;;; exception handler
;; uart send exception code
EXCEPT_HANDLER:
	RDCR	c5,r24											;read special control register c5
	ANDI	r24,r24,0x7

	ADDUI	r24,r24,48

	ORR		r0,r24,r16									;set r16 data to send
	CALL	r2													;call SEND_CHAR
	ANDR	r0,r0,r0										;NOP

;;; LED
	ORI		r0,r16,0x1
	SHLLI	r16,r16,16
	ORI		r16,r16,0xFFFF							;r16=0x0001FFFF
	CALL	r3													;call SET_GPIO_OUT
	ANDR	r0,r0,r0										;NOP

;;; EXCEPT_LOOP
EXCEPT_LOOP:
	BE		r0,r0,EXCEPT_LOOP						;go to EXCEPT_LOOP
	ANDR	r0,r0,r0										;NOP
